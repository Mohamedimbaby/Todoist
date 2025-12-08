import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../../domain/repositories/comments_repository.dart';
import '../../../data/services/sync_service.dart';
import 'comments_state.dart';

/// Cubit for managing comments - OFFLINE FIRST
/// Never calls API directly, uses repository for local storage
class CommentsCubit extends Cubit<CommentsState> {
  final CommentsRepository _commentsRepository;
  final SyncService _syncService;

  String? _currentLocalTaskId;
  String? _currentRemoteTaskId;
  bool _isFirstLoad = true;

  CommentsCubit({
    required CommentsRepository commentsRepository,
    required SyncService syncService,
  })  : _commentsRepository = commentsRepository,
        _syncService = syncService,
        super(const CommentsInitial());

  /// Load comments from local storage
  /// [localTaskId] - Local UUID used for Hive storage
  /// [remoteTaskId] - Todoist API ID (optional, for API calls)
  Future<void> loadComments(String localTaskId, {String? remoteTaskId}) async {
    _currentLocalTaskId = localTaskId;
    _currentRemoteTaskId = remoteTaskId;

    if (state is CommentsInitial || _isFirstLoad) {
      emit(const CommentsLoading());
    }

    try {
      final localComments =
          await _commentsRepository.getLocalComments(localTaskId);
      final pendingCount =
          await _commentsRepository.getPendingCommentSyncCount();

      // First load with no local data - fetch from API
      if (_isFirstLoad && localComments.isEmpty) {
        await _fetchAndSaveFromApi();
        _isFirstLoad = false;
        return;
      }

      _isFirstLoad = false;
      emit(CommentsLoaded(
        taskId: localTaskId,
        comments: localComments,
        pendingSyncCount: pendingCount,
      ));

      // Try to sync in background
      _trySyncInBackground();
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  /// Fetch comments from API and save locally
  Future<void> _fetchAndSaveFromApi() async {
    if (_currentLocalTaskId == null) return;

    // Use provided remote ID, or try to resolve it
    String? remoteId = _currentRemoteTaskId;
    remoteId ??= await _commentsRepository.getRemoteTaskId(_currentLocalTaskId!);

    if (remoteId == null) {
      // Task not synced yet, show local data only
      final localComments =
          await _commentsRepository.getLocalComments(_currentLocalTaskId!);
      emit(CommentsLoaded(
        taskId: _currentLocalTaskId!,
        comments: localComments,
        pendingSyncCount: 0,
      ));
      return;
    }

    // Use remote ID for API call
    final result = await _syncService.fetchCommentsFromApi(remoteId);

    if (result.success) {
      // Save with local task ID for consistency
      await _commentsRepository.saveCommentsFromApi(
          _currentLocalTaskId!, result.comments);
      final comments =
          await _commentsRepository.getLocalComments(_currentLocalTaskId!);
      final pendingCount =
          await _commentsRepository.getPendingCommentSyncCount();

      emit(CommentsLoaded(
        taskId: _currentLocalTaskId!,
        comments: comments,
        pendingSyncCount: pendingCount,
      ));
    } else {
      // API failed - show local data if any
      final localComments =
          await _commentsRepository.getLocalComments(_currentLocalTaskId!);
      emit(CommentsLoaded(
        taskId: _currentLocalTaskId!,
        comments: localComments,
        pendingSyncCount: 0,
      ));
    }
  }

  /// Pull to refresh - only if no pending sync
  Future<void> refreshComments() async {
    if (_currentLocalTaskId == null) return;

    final hasPending = await _commentsRepository
        .hasPendingCommentSyncActions(_currentLocalTaskId!);

    if (hasPending) {
      final currentState = state;
      if (currentState is CommentsLoaded) {
        emit(CommentsRefreshBlocked(
          message: 'Unsynced changes exist. Please sync first.',
          currentState: currentState,
        ));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
      }
      return;
    }

    _showOperationMessage('Refreshing...');
    await _fetchAndSaveFromApi();
  }

  /// Add a comment - OPTIMISTIC UI
  Future<void> addComment(String content, {String? projectId}) async {
    if (_currentLocalTaskId == null) return;

    _showOperationMessage('Adding comment...');

    try {
      final comment = CommentEntity(
        id: const Uuid().v4(),
        taskId: _currentLocalTaskId!,
        projectId: projectId,
        content: content,
        postedAt: DateTime.now(),
        isSynced: false,
      );

      await _commentsRepository.addLocalComment(comment);

      final comments =
          await _commentsRepository.getLocalComments(_currentLocalTaskId!);
      final pendingCount =
          await _commentsRepository.getPendingCommentSyncCount();

      emit(CommentsLoaded(
        taskId: _currentLocalTaskId!,
        comments: comments,
        pendingSyncCount: pendingCount,
      ));

      _trySyncInBackground();
    } catch (e) {
      _showError('Failed to add comment: $e');
    }
  }

  /// Delete a comment - OPTIMISTIC UI
  Future<void> deleteComment(String commentId) async {
    if (_currentLocalTaskId == null) return;

    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    // Optimistic update - remove from UI immediately
    final updatedComments = currentState.comments
        .where((c) => c.id != commentId)
        .toList();

    emit(currentState.copyWith(
      comments: updatedComments,
      operationMessage: 'Deleting...',
    ));

    try {
      await _commentsRepository.deleteLocalComment(commentId);

      final comments =
          await _commentsRepository.getLocalComments(_currentLocalTaskId!);
      final pendingCount =
          await _commentsRepository.getPendingCommentSyncCount();

      emit(CommentsLoaded(
        taskId: _currentLocalTaskId!,
        comments: comments,
        pendingSyncCount: pendingCount,
      ));

      _trySyncInBackground();
    } catch (e) {
      // Revert on error
      await loadComments(_currentLocalTaskId!, remoteTaskId: _currentRemoteTaskId);
      _showError('Failed to delete comment');
    }
  }

  /// Try to sync in background
  Future<void> _trySyncInBackground() async {
    final result = await _syncService.syncNow();
    if (result.syncedCount > 0 && _currentLocalTaskId != null) {
      final pendingCount =
          await _commentsRepository.getPendingCommentSyncCount();
      final currentState = state;
      if (currentState is CommentsLoaded) {
        emit(currentState.copyWith(pendingSyncCount: pendingCount));
      }
    }
  }

  void _showOperationMessage(String message) {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      emit(currentState.copyWith(operationMessage: message));
    }
  }

  void _showError(String message) {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      emit(CommentsError(message, previousState: currentState));
    } else {
      emit(CommentsError(message));
    }
  }
}
