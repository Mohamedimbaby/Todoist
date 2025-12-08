import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_entity.dart';
import '../../../domain/entities/task_entity.dart';

/// Base state for BoardCubit
abstract class BoardState extends Equatable {
  const BoardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BoardInitial extends BoardState {
  const BoardInitial();
}

/// Loading state - only for first load
class BoardLoading extends BoardState {
  const BoardLoading();
}

/// Board loaded with tasks
class BoardLoaded extends BoardState {
  final ProjectEntity project;
  final List<TaskEntity> todoTasks;
  final List<TaskEntity> inProgressTasks;
  final List<TaskEntity> doneTasks;
  final int pendingSyncCount;
  final String? operationMessage; // For small overlay message

  const BoardLoaded({
    required this.project,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.doneTasks,
    this.pendingSyncCount = 0,
    this.operationMessage,
  });

  List<TaskEntity> get allTasks => [
        ...todoTasks,
        ...inProgressTasks,
        ...doneTasks,
      ];

  BoardLoaded copyWith({
    ProjectEntity? project,
    List<TaskEntity>? todoTasks,
    List<TaskEntity>? inProgressTasks,
    List<TaskEntity>? doneTasks,
    int? pendingSyncCount,
    String? operationMessage,
    bool clearMessage = false,
  }) {
    return BoardLoaded(
      project: project ?? this.project,
      todoTasks: todoTasks ?? this.todoTasks,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      doneTasks: doneTasks ?? this.doneTasks,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      operationMessage: clearMessage ? null : (operationMessage ?? this.operationMessage),
    );
  }

  @override
  List<Object?> get props => [
        project,
        todoTasks,
        inProgressTasks,
        doneTasks,
        pendingSyncCount,
        operationMessage,
      ];
}

/// Error state
class BoardError extends BoardState {
  final String message;
  final BoardLoaded? previousState;

  const BoardError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Refresh blocked due to pending sync
class BoardRefreshBlocked extends BoardState {
  final String message;
  final BoardLoaded currentState;

  const BoardRefreshBlocked({
    required this.message,
    required this.currentState,
  });

  @override
  List<Object?> get props => [message, currentState];
}
