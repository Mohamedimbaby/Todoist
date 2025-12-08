import 'package:hive/hive.dart';
import '../../domain/entities/sync_action_entity.dart';
import '../../domain/repositories/sync_repository.dart';
import '../models/sync_action_model.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';
import '../providers/todoist_task_provider.dart';

/// Implementation of SyncRepository using Hive
/// Handles syncing with proper local/remote ID mapping
class SyncRepositoryImpl implements SyncRepository {
  final Box<SyncActionModel> _syncBox;
  final TodoistTaskProvider? _taskProvider;
  final Box<TaskModel> _tasksBox;
  final Box<CommentModel>? _commentsBox;

  SyncRepositoryImpl({
    required Box<SyncActionModel> syncBox,
    required Box<TaskModel> taskBox,
    TodoistTaskProvider? taskProvider,
    Box<CommentModel>? commentsBox,
  })  : _syncBox = syncBox,
        _taskProvider = taskProvider,
        _tasksBox = taskBox,
        _commentsBox = commentsBox;

  @override
  Future<List<SyncActionEntity>> getPendingSyncActions() async {
    final actions = _syncBox.values.map((m) => m.toEntity()).toList();
    actions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return actions;
  }

  @override
  Future<void> addSyncAction(SyncActionEntity action) async {
    await _syncBox.put(action.id, SyncActionModel.fromEntity(action));
  }

  @override
  Future<void> removeSyncAction(String id) async {
    await _syncBox.delete(id);
  }

  @override
  Future<void> updateSyncAction(SyncActionEntity action) async {
    await _syncBox.put(action.id, SyncActionModel.fromEntity(action));
  }

  @override
  Future<void> clearSyncQueue() async {
    await _syncBox.clear();
  }

  @override
  Future<int> getSyncActionCount() async {
    return _syncBox.length;
  }

  @override
  Future<bool> hasPendingSyncActions() async {
    return _syncBox.isNotEmpty;
  }

  @override
  Future<void> executeSyncQueue() async {
    final provider = _taskProvider;
    if (provider == null) return;

    final actions = await getPendingSyncActions();
    for (final action in actions) {
      try {
        await _executeAction(action, provider);
        await removeSyncAction(action.id);
      } catch (e) {
        final updated = action.copyWith(
          retryCount: action.retryCount + 1,
          errorMessage: e.toString(),
        );
        await updateSyncAction(updated);
      }
    }
  }

  Future<void> _executeAction(
    SyncActionEntity action,
    TodoistTaskProvider provider,
  ) async {
    switch (action.type) {
      case SyncActionType.createTask:
        await _handleCreateTask(action, provider);
        break;
      case SyncActionType.updateTask:
        await _handleUpdateTask(action, provider);
        break;
      case SyncActionType.completeTask:
        await _handleCompleteTask(action, provider);
        break;
      case SyncActionType.deleteTask:
        await provider.deleteTask(action.entityId);
        break;
      case SyncActionType.createComment:
        await _handleCreateComment(action);
        break;
      case SyncActionType.deleteComment:
        // entityId should be the todoistId for comments
        break;
      default:
        break;
    }
  }

  /// Handle create task - updates local task with remote ID
  Future<void> _handleCreateTask(
    SyncActionEntity action,
    TodoistTaskProvider provider,
  ) async {
    final localId = action.entityId;

    final response = await provider.createTask(
      content: action.payload['content'] as String,
      description: action.payload['description'] as String?,
      projectId: action.payload['project_id'] as String?,
      priority: action.payload['priority'] as int?,
    );

    final remoteId = response['id'].toString();

    final localTask = _tasksBox.get(localId);
    if (localTask != null) {
      final updatedTask = TaskModel(
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
      await _tasksBox.put(localId, updatedTask);
    }
  }

  /// Handle update task - uses todoistId for API call
  Future<void> _handleUpdateTask(
    SyncActionEntity action,
    TodoistTaskProvider provider,
  ) async {
    final entityId = action.entityId;
    final remoteId = await _getRemoteTaskId(entityId);

    if (action.payload['reopen'] == true) {
      await provider.reopenTask(remoteId);
    } else {
      await provider.updateTask(remoteId, action.payload);
    }

    _updateTaskSyncStatus(entityId);
  }

  /// Handle complete task
  Future<void> _handleCompleteTask(
    SyncActionEntity action,
    TodoistTaskProvider provider,
  ) async {
    final entityId = action.entityId;
    final remoteId = await _getRemoteTaskId(entityId);

    await provider.completeTask(remoteId);
    _updateTaskSyncStatus(entityId);
  }

  /// Handle create comment - updates local comment with remote ID
  Future<void> _handleCreateComment(SyncActionEntity action) async {
    final commentsBox = _commentsBox;
    if (commentsBox == null) return;

    final localId = action.entityId;
    final taskLocalId = action.payload['task_id'] as String?;

    String? remoteTaskId;
    if (taskLocalId != null) {
      remoteTaskId = await _getRemoteTaskId(taskLocalId);
    }

    final apiPayload = Map<String, dynamic>.from(action.payload);
    if (remoteTaskId != null) {
      apiPayload['task_id'] = remoteTaskId;
    }
    // TODO: Add actual API call for comment creation
    // For now, just update the local comment as synced
    final localComment = commentsBox.get(localId);
    if (localComment != null) {
      final updated = CommentModel(
        id: localId,
        taskId: localComment.taskId,
        projectId: localComment.projectId,
        content: localComment.content,
        todoistId: localId, // Would be set from API response
        postedAt: localComment.postedAt,
        attachment: localComment.attachment,
        isSynced: true,
      );
      await commentsBox.put(localId, updated);
    }
  }

  /// Get remote task ID from local ID
  Future<String> _getRemoteTaskId(String localOrRemoteId) async {
    if (_isNumericId(localOrRemoteId)) {
      return localOrRemoteId;
    }

    final task = _tasksBox.get(localOrRemoteId);
    if (task?.todoistId != null) {
      return task!.todoistId!;
    }

    return localOrRemoteId;
  }

  bool _isNumericId(String id) {
    return int.tryParse(id) != null;
  }

  void _updateTaskSyncStatus(String localId) {
    final task = _tasksBox.get(localId);
    if (task != null && !task.isSynced) {
      final updated = TaskModel(
        id: task.id,
        content: task.content,
        description: task.description,
        column: task.column,
        priority: task.priority,
        projectId: task.projectId,
        todoistId: task.todoistId,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        isSynced: true,
      );
      _tasksBox.put(localId, updated);
    }
  }
}
