import 'package:equatable/equatable.dart';
import '../../../domain/entities/timer_entity.dart';

/// States for TimerCubit
abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TimerInitial extends TimerState {
  const TimerInitial();
}

/// Timer loaded state
class TimerLoaded extends TimerState {
  final TimerEntity? runningTimer;
  final Map<String, TimerEntity> timersByTaskId;

  const TimerLoaded({
    this.runningTimer,
    required this.timersByTaskId,
  });

  @override
  List<Object?> get props => [runningTimer, timersByTaskId];
}

/// Timer ticking state (for live updates)
class TimerTicking extends TimerState {
  final String taskId;
  final int elapsedSeconds;
  final Map<String, TimerEntity> timersByTaskId;

  const TimerTicking({
    required this.taskId,
    required this.elapsedSeconds,
    required this.timersByTaskId,
  });

  @override
  List<Object?> get props => [taskId, elapsedSeconds, timersByTaskId];
}

/// Timer error state
class TimerError extends TimerState {
  final String message;

  const TimerError(this.message);

  @override
  List<Object?> get props => [message];
}

