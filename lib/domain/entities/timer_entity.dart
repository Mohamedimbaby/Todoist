import 'package:equatable/equatable.dart';

/// Timer entity for tracking time on tasks
class TimerEntity extends Equatable {
  final String id;
  final String taskId;
  final DateTime? startTimestamp;
  final int accumulatedSeconds;
  final bool isRunning;

  const TimerEntity({
    required this.id,
    required this.taskId,
    this.startTimestamp,
    this.accumulatedSeconds = 0,
    this.isRunning = false,
  });

  /// Get current elapsed seconds including running time
  int get currentElapsedSeconds {
    if (!isRunning || startTimestamp == null) {
      return accumulatedSeconds;
    }
    final runningSeconds = DateTime.now().difference(startTimestamp!).inSeconds;
    return accumulatedSeconds + runningSeconds;
  }

  TimerEntity copyWith({
    String? id,
    String? taskId,
    DateTime? startTimestamp,
    bool clearStartTimestamp = false,
    int? accumulatedSeconds,
    bool? isRunning,
  }) {
    return TimerEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTimestamp: clearStartTimestamp ? null : (startTimestamp ?? this.startTimestamp),
      accumulatedSeconds: accumulatedSeconds ?? this.accumulatedSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        startTimestamp,
        accumulatedSeconds,
        isRunning,
      ];
}

