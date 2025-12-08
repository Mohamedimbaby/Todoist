import '../entities/comment_entity.dart';

/// Repository interface for comments (offline-first)
abstract class CommentsRepository {
  /// Get all comments for a task from local storage
  Future<List<CommentEntity>> getLocalComments(String taskId);

  /// Add a comment locally and queue sync
  Future<CommentEntity> addLocalComment(CommentEntity comment);

  /// Delete a comment locally and queue sync
  Future<void> deleteLocalComment(String commentId);

  /// Save comments from API to local storage
  Future<void> saveCommentsFromApi(
      String localTaskId, List<Map<String, dynamic>> apiComments);

  /// Check if there are pending comment sync actions
  Future<bool> hasPendingCommentSyncActions(String taskId);

  /// Get pending sync count for comments
  Future<int> getPendingCommentSyncCount();

  /// Get the remote Todoist task ID for API calls
  Future<String?> getRemoteTaskId(String localTaskId);
}
