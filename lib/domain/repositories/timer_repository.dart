import '../entities/timer_entity.dart';

/// Abstract timer repository interface
abstract class TimerRepository {
  /// Get timer for a task
  Future<TimerEntity?> getTimerForTask(String taskId);

  /// Get all timers
  Future<List<TimerEntity>> getAllTimers();

  /// Get currently running timer
  Future<TimerEntity?> getRunningTimer();

  /// Start timer for a task
  Future<TimerEntity> startTimer(String taskId);

  /// Stop timer for a task
  Future<TimerEntity> stopTimer(String taskId);

  /// Stop all running timers
  Future<void> stopAllTimers();

  /// Create or update timer
  Future<TimerEntity> saveTimer(TimerEntity timer);

  /// Delete timer
  Future<void> deleteTimer(String taskId);

  /// Get total tracked time for a task
  Future<int> getTotalTrackedSeconds(String taskId);
}

