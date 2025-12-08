import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/sync_action_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../models/comment_model.dart';
import '../models/task_model.dart';

/// Implementation of CommentsRepository - offline-first with sync queue
class CommentsRepositoryImpl implements CommentsRepository {
  final Box<CommentModel> _commentsBox;
  final Box<TaskModel> _tasksBox;
  final SyncRepository _syncRepository;

  CommentsRepositoryImpl({
    required Box<CommentModel> commentsBox,
    required Box<TaskModel> tasksBox,
    required SyncRepository syncRepository,
  })  : _commentsBox = commentsBox,
        _tasksBox = tasksBox,
        _syncRepository = syncRepository;

  @override
  Future<List<CommentEntity>> getLocalComments(String taskId) async {
    return _commentsBox.values
        .where((c) => c.taskId == taskId)
        .map((c) => c.toEntity())
        .toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  @override
  Future<CommentEntity> addLocalComment(CommentEntity comment) async {
    final id = comment.id.isEmpty ? const Uuid().v4() : comment.id;
    final now = DateTime.now();

    // Resolve task ID to remote ID for sync payload
    final remoteTaskId = await getRemoteTaskId(comment.taskId);

    final newComment = comment.copyWith(
      id: id,
      postedAt: now,
      isSynced: false,
    );

    await _commentsBox.put(id, CommentModel.fromEntity(newComment));

    // Use remote task ID in sync payload for API
    await _syncRepository.addSyncAction(SyncActionEntity(
      id: const Uuid().v4(),
      type: SyncActionType.createComment,
      entityId: id,
      payload: {
        'task_id': remoteTaskId ?? comment.taskId,
        'local_task_id': comment.taskId, // Keep local ID for reference
        'project_id': newComment.projectId,
        'content': newComment.content,
        if (newComment.attachment != null) 'attachment': newComment.attachment,
      },
      createdAt: now,
    ));

    return newComment;
  }

  @override
  Future<void> deleteLocalComment(String commentId) async {
    final model = _commentsBox.get(commentId);
    if (model == null) return;

    await _commentsBox.delete(commentId);

    // Only sync delete if comment was synced to API
    if (model.todoistId != null) {
      await _syncRepository.addSyncAction(SyncActionEntity(
        id: const Uuid().v4(),
        type: SyncActionType.deleteComment,
        entityId: model.todoistId!,
        payload: {},
        createdAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> saveCommentsFromApi(
      String localTaskId, List<Map<String, dynamic>> apiComments) async {
    // Remove existing synced comments for this task
    final existingKeys = _commentsBox.keys
        .where((key) {
          final model = _commentsBox.get(key);
          return model?.taskId == localTaskId && model?.isSynced == true;
        })
        .toList();

    for (final key in existingKeys) {
      await _commentsBox.delete(key);
    }

    // Save new comments from API
    for (final json in apiComments) {
      final todoistId = json['id'].toString();

      // Check if we have unsynced local version
      final localVersion = _commentsBox.values
          .where((c) => c.todoistId == todoistId && !c.isSynced)
          .firstOrNull;

      if (localVersion != null) continue;

      final comment = CommentEntity(
        id: const Uuid().v4(),
        taskId: localTaskId, // Store with local task ID for consistency
        projectId: json['project_id']?.toString(),
        content: json['content'] as String,
        todoistId: todoistId,
        postedAt: DateTime.parse(json['posted_at'] as String),
        attachment: json['attachment']?['file_url'] as String?,
        isSynced: true,
      );

      await _commentsBox.put(comment.id, CommentModel.fromEntity(comment));
    }
  }

  @override
  Future<bool> hasPendingCommentSyncActions(String taskId) async {
    final actions = await _syncRepository.getPendingSyncActions();
    return actions.any((a) =>
        a.type == SyncActionType.createComment ||
        a.type == SyncActionType.deleteComment);
  }

  @override
  Future<int> getPendingCommentSyncCount() async {
    final actions = await _syncRepository.getPendingSyncActions();
    return actions
        .where((a) =>
            a.type == SyncActionType.createComment ||
            a.type == SyncActionType.deleteComment)
        .length;
  }

  @override
  Future<String?> getRemoteTaskId(String localTaskId) async {
    // Check if already a remote ID (numeric)
    if (int.tryParse(localTaskId) != null) {
      return localTaskId;
    }

    // Look up the task by local ID
    final task = _tasksBox.get(localTaskId);
    return task?.todoistId;
  }
}
