import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/timer_entity.dart';
import '../../domain/repositories/timer_repository.dart';
import '../models/timer_model.dart';

/// Implementation of TimerRepository using Hive
class TimerRepositoryImpl implements TimerRepository {
  final Box<TimerModel> _timersBox;

  TimerRepositoryImpl({required Box<TimerModel> timersBox})
      : _timersBox = timersBox;

  @override
  Future<TimerEntity?> getTimerForTask(String taskId) async {
    try {
      final model = _timersBox.values.firstWhere(
        (timer) => timer.taskId == taskId,
      );
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TimerEntity>> getAllTimers() async {
    return _timersBox.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<TimerEntity?> getRunningTimer() async {
    try {
      final model = _timersBox.values.firstWhere((timer) => timer.isRunning);
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<TimerEntity> startTimer(String taskId) async {
    var timer = await getTimerForTask(taskId);
    if (timer == null) {
      timer = TimerEntity(
        id: const Uuid().v4(),
        taskId: taskId,
        startTimestamp: DateTime.now(),
        isRunning: true,
      );
    } else {
      timer = timer.copyWith(
        startTimestamp: DateTime.now(),
        isRunning: true,
      );
    }
    await saveTimer(timer);
    return timer;
  }

  @override
  Future<TimerEntity> stopTimer(String taskId) async {
    final timer = await getTimerForTask(taskId);
    if (timer == null) {
      // No timer exists, create a stopped one
      final newTimer = TimerEntity(
        id: const Uuid().v4(),
        taskId: taskId,
        isRunning: false,
      );
      await saveTimer(newTimer);
      return newTimer;
    }
    if (!timer.isRunning) {
      // Timer exists but not running, just return it
      return timer;
    }
    final elapsed = timer.currentElapsedSeconds;
    final stopped = timer.copyWith(
      accumulatedSeconds: elapsed,
      isRunning: false,
      clearStartTimestamp: true,
    );
    await saveTimer(stopped);
    return stopped;
  }

  @override
  Future<void> stopAllTimers() async {
    final runningTimers = _timersBox.values.where((m) => m.isRunning).toList();
    for (final model in runningTimers) {
      await stopTimer(model.taskId);
    }
  }

  @override
  Future<TimerEntity> saveTimer(TimerEntity timer) async {
    await _timersBox.put(timer.taskId, TimerModel.fromEntity(timer));
    return timer;
  }

  @override
  Future<void> deleteTimer(String taskId) async {
    await _timersBox.delete(taskId);
  }

  @override
  Future<int> getTotalTrackedSeconds(String taskId) async {
    final timer = await getTimerForTask(taskId);
    return timer?.currentElapsedSeconds ?? 0;
  }
}
