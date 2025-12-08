import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/sync_action_entity.dart';
import '../../domain/repositories/sync_repository.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';
import '../providers/secure_storage_provider.dart';

/// Service responsible for syncing local changes to Todoist API
class SyncService {
  final SyncRepository _syncRepository;
  final SecureStorageProvider _secureStorage;
  final Dio _dio;
  final Box<TaskModel> _tasksBox;
  final Box<CommentModel>? _commentsBox;

  bool _isSyncing = false;

  SyncService({
    required SyncRepository syncRepository,
    required SecureStorageProvider secureStorage,
    required Dio dio,
    required Box<TaskModel> tasksBox,
    Box<CommentModel>? commentsBox,
  })  : _syncRepository = syncRepository,
        _secureStorage = secureStorage,
        _dio = dio,
        _tasksBox = tasksBox,
        _commentsBox = commentsBox;

  Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<bool> hasPendingActions() async {
    return await _syncRepository.hasPendingSyncActions();
  }

  Future<int> getPendingCount() async {
    return await _syncRepository.getSyncActionCount();
  }

  Future<SyncResult> syncNow() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    final hasNet = await hasInternet();
    if (!hasNet) {
      return SyncResult(success: false, message: 'No internet connection');
    }

    final token = await _secureStorage.getTodoistToken();
    if (token == null) {
      return SyncResult(success: false, message: 'No API token configured');
    }

    _isSyncing = true;
    int synced = 0;
    int failed = 0;

    try {
      final actions = await _syncRepository.getPendingSyncActions();

      for (final action in actions) {
        try {
          await _executeAction(action, token);
          await _syncRepository.removeSyncAction(action.id);
          synced++;
        } catch (e) {
          failed++;
        }
      }

      return SyncResult(
        success: failed == 0,
        message: 'Synced $synced, failed $failed',
        syncedCount: synced,
        failedCount: failed,
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _executeAction(SyncActionEntity action, String token) async {
    final headers = {'Authorization': 'Bearer $token'};

    switch (action.type) {
      case SyncActionType.createTask:
        final response = await _dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.tasks}',
          data: action.payload,
          options: Options(headers: headers),
        );
        // Update local task with remote ID
        await _updateTaskWithRemoteId(action.entityId, response.data);
        break;

      case SyncActionType.updateTask:
        final remoteId = await _getRemoteTaskId(action.entityId);
        if (action.payload['reopen'] == true) {
          await _dio.post(
            '${ApiConstants.baseUrl}${ApiConstants.tasks}/$remoteId/reopen',
            options: Options(headers: headers),
          );
        } else {
          await _dio.post(
            '${ApiConstants.baseUrl}${ApiConstants.tasks}/$remoteId',
            data: action.payload,
            options: Options(headers: headers),
          );
        }
        break;

      case SyncActionType.completeTask:
        final remoteId = await _getRemoteTaskId(action.entityId);
        await _dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.tasks}/$remoteId/close',
          options: Options(headers: headers),
        );
        break;

      case SyncActionType.deleteTask:
        final remoteId = await _getRemoteTaskId(action.entityId);
        await _dio.delete(
          '${ApiConstants.baseUrl}${ApiConstants.tasks}/$remoteId',
          options: Options(headers: headers),
        );
        break;

      case SyncActionType.createProject:
        await _dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.projects}',
          data: action.payload,
          options: Options(headers: headers),
        );
        break;

      case SyncActionType.deleteProject:
        await _dio.delete(
          '${ApiConstants.baseUrl}${ApiConstants.projects}/${action.entityId}',
          options: Options(headers: headers),
        );
        break;

      case SyncActionType.createComment:
        await _handleCreateComment(action, headers);
        break;

      case SyncActionType.updateComment:
        await _dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.comments}/${action.entityId}',
          data: action.payload,
          options: Options(headers: headers),
        );
        break;

      case SyncActionType.deleteComment:
        await _dio.delete(
          '${ApiConstants.baseUrl}${ApiConstants.comments}/${action.entityId}',
          options: Options(headers: headers),
        );
        break;
    }
  }

  /// Handle create comment - resolve task_id to remote ID
  Future<void> _handleCreateComment(
    SyncActionEntity action,
    Map<String, String> headers,
  ) async {
    // Get task_id from payload and resolve to remote ID
    final localTaskId = action.payload['task_id'] as String?;
    
    if (localTaskId == null) {
      throw Exception('Comment missing task_id');
    }

    // Resolve local task ID to remote ID
    final remoteTaskId = await _getRemoteTaskId(localTaskId);

    // Check if we got a valid remote ID (should be numeric)
    final isValidRemoteId = int.tryParse(remoteTaskId) != null;
    
    if (!isValidRemoteId) {
      // Task hasn't been synced yet - skip this action, retry later
      throw TaskNotSyncedException(
        'Task $localTaskId not synced yet. Comment sync will retry.',
      );
    }

    // Build API payload with resolved remote task ID
    final apiPayload = <String, dynamic>{
      'task_id': remoteTaskId,
      'content': action.payload['content'],
    };

    if (action.payload['project_id'] != null) {
      apiPayload['project_id'] = action.payload['project_id'];
    }

    if (action.payload['attachment'] != null) {
      apiPayload['attachment'] = action.payload['attachment'];
    }

    // Create comment on API
    final response = await _dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.comments}',
      data: apiPayload,
      options: Options(headers: headers),
    );

    // Update local comment with remote ID
    await _updateCommentWithRemoteId(action.entityId, response.data);
  }

  /// Get remote task ID from local ID
  Future<String> _getRemoteTaskId(String localOrRemoteId) async {
    // Already a remote ID (numeric)?
    if (int.tryParse(localOrRemoteId) != null) {
      return localOrRemoteId;
    }

    // Look up task by local ID (as Hive key)
    final task = _tasksBox.get(localOrRemoteId);
    if (task?.todoistId != null) {
      return task!.todoistId!;
    }

    // Maybe the ID is stored differently - search by todoistId field
    final taskByTodoistId = _tasksBox.values
        .where((t) => t.todoistId == localOrRemoteId)
        .firstOrNull;
    if (taskByTodoistId != null) {
      return localOrRemoteId; // It's already the remote ID
    }

    // Search all tasks for matching id field
    final taskById = _tasksBox.values
        .where((t) => t.id == localOrRemoteId)
        .firstOrNull;
    if (taskById?.todoistId != null) {
      return taskById!.todoistId!;
    }

    // No remote ID found - return original
    return localOrRemoteId;
  }

  /// Update local task with remote ID after API create
  Future<void> _updateTaskWithRemoteId(
    String localId,
    Map<String, dynamic> apiResponse,
  ) async {
    final remoteId = apiResponse['id'].toString();
    final localTask = _tasksBox.get(localId);

    if (localTask != null) {
      final updated = TaskModel(
        id: localId,
        content: localTask.content,
        description: localTask.description,
        column: localTask.column,
        priority: localTask.priority,
        projectId: localTask.projectId,
        todoistId: remoteId,
        createdAt: localTask.createdAt,
        updatedAt: DateTime.now(),
        isSynced: true,
      );
      await _tasksBox.put(localId, updated);
    }
  }

  /// Update local comment with remote ID after API create
  Future<void> _updateCommentWithRemoteId(
    String localId,
    Map<String, dynamic> apiResponse,
  ) async {
    final commentsBox = _commentsBox;
    if (commentsBox == null) return;

    final remoteId = apiResponse['id'].toString();
    final localComment = commentsBox.get(localId);

    if (localComment != null) {
      final updated = CommentModel(
        id: localId,
        taskId: localComment.taskId,
        projectId: localComment.projectId,
        content: localComment.content,
        todoistId: remoteId,
        postedAt: localComment.postedAt,
        attachment: localComment.attachment,
        isSynced: true,
      );
      await commentsBox.put(localId, updated);
    }
  }

  Future<FetchResult> fetchTasksFromApi(String projectId) async {
    final hasPending = await hasPendingActions();
    if (hasPending) {
      return FetchResult(
        success: false,
        message: 'Cannot refresh. You have unsynced changes.',
        tasks: [],
      );
    }

    final hasNet = await hasInternet();
    if (!hasNet) {
      return FetchResult(
        success: false,
        message: 'No internet connection',
        tasks: [],
      );
    }

    final token = await _secureStorage.getTodoistToken();
    if (token == null) {
      return FetchResult(
        success: false,
        message: 'No API token configured',
        tasks: [],
      );
    }

    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.tasks}',
        queryParameters: {'project_id': projectId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final tasksData = response.data as List<dynamic>;
      return FetchResult(
        success: true,
        message: 'Fetched ${tasksData.length} tasks',
        tasks: tasksData.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      return FetchResult(
        success: false,
        message: 'Failed to fetch: $e',
        tasks: [],
      );
    }
  }

  /// Fetch comments for a task from API (uses remote task ID)
  Future<CommentsFetchResult> fetchCommentsFromApi(String taskId) async {
    final hasNet = await hasInternet();
    if (!hasNet) {
      return CommentsFetchResult(
        success: false,
        message: 'No internet connection',
        comments: [],
      );
    }

    final token = await _secureStorage.getTodoistToken();
    if (token == null) {
      return CommentsFetchResult(
        success: false,
        message: 'No API token configured',
        comments: [],
      );
    }

    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.comments}',
        queryParameters: {'task_id': taskId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final commentsData = response.data as List<dynamic>;
      return CommentsFetchResult(
        success: true,
        message: 'Fetched ${commentsData.length} comments',
        comments: commentsData.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      return CommentsFetchResult(
        success: false,
        message: 'Failed to fetch comments: $e',
        comments: [],
      );
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.failedCount = 0,
  });
}

class FetchResult {
  final bool success;
  final String message;
  final List<Map<String, dynamic>> tasks;

  FetchResult({
    required this.success,
    required this.message,
    required this.tasks,
  });
}

class CommentsFetchResult {
  final bool success;
  final String message;
  final List<Map<String, dynamic>> comments;

  CommentsFetchResult({
    required this.success,
    required this.message,
    required this.comments,
  });
}

/// Exception when trying to sync a comment for a task not yet synced
class TaskNotSyncedException implements Exception {
  final String message;
  TaskNotSyncedException(this.message);
  
  @override
  String toString() => message;
}
