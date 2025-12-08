import 'package:equatable/equatable.dart';
import '../../../domain/entities/comment_entity.dart';

/// Base state for CommentsCubit
abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

/// Loading state - only for first load
class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

/// Comments loaded successfully
class CommentsLoaded extends CommentsState {
  final String taskId;
  final List<CommentEntity> comments;
  final int pendingSyncCount;
  final String? operationMessage;

  const CommentsLoaded({
    required this.taskId,
    required this.comments,
    this.pendingSyncCount = 0,
    this.operationMessage,
  });

  CommentsLoaded copyWith({
    String? taskId,
    List<CommentEntity>? comments,
    int? pendingSyncCount,
    String? operationMessage,
    bool clearMessage = false,
  }) {
    return CommentsLoaded(
      taskId: taskId ?? this.taskId,
      comments: comments ?? this.comments,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      operationMessage:
          clearMessage ? null : (operationMessage ?? this.operationMessage),
    );
  }

  @override
  List<Object?> get props =>
      [taskId, comments, pendingSyncCount, operationMessage];
}

/// Error state
class CommentsError extends CommentsState {
  final String message;
  final CommentsLoaded? previousState;

  const CommentsError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Refresh blocked due to pending sync
class CommentsRefreshBlocked extends CommentsState {
  final String message;
  final CommentsLoaded currentState;

  const CommentsRefreshBlocked({
    required this.message,
    required this.currentState,
  });

  @override
  List<Object?> get props => [message, currentState];
}

