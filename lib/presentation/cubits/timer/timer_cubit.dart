import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/timer_entity.dart';
import '../../../domain/repositories/timer_repository.dart';
import 'timer_state.dart';

/// Cubit for managing task timers
class TimerCubit extends Cubit<TimerState> {
  final TimerRepository _timerRepository;
  Timer? _tickTimer;

  TimerCubit({required TimerRepository timerRepository})
      : _timerRepository = timerRepository,
        super(const TimerInitial());

  /// Load all timers
  Future<void> loadTimers() async {
    if (isClosed) return;
    try {
      final timers = await _timerRepository.getAllTimers();
      final timersByTaskId = {for (var t in timers) t.taskId: t};
      final running = await _timerRepository.getRunningTimer();
      if (isClosed) return;
      emit(TimerLoaded(runningTimer: running, timersByTaskId: timersByTaskId));
      if (running != null) {
        _startTicking(running.taskId, timersByTaskId);
      }
    } catch (e) {
      if (isClosed) return;
      emit(TimerError(e.toString()));
    }
  }

  /// Start timer for a task (stops any running timer)
  Future<void> startTimer(String taskId) async {
    if (isClosed) return;
    try {
      _stopTicking();
      await _timerRepository.stopAllTimers();
      final timer = await _timerRepository.startTimer(taskId);
      final timers = await _timerRepository.getAllTimers();
      final timersByTaskId = {for (var t in timers) t.taskId: t};
      if (isClosed) return;
      emit(TimerLoaded(runningTimer: timer, timersByTaskId: timersByTaskId));
      _startTicking(taskId, timersByTaskId);
    } catch (e) {
      if (isClosed) return;
      emit(TimerError(e.toString()));
    }
  }

  /// Stop timer for a task (safe - won't throw if not running)
  Future<void> stopTimer(String taskId) async {
    if (isClosed) return;
    try {
      _stopTicking();
      // Check if timer exists and is running before stopping
      final timer = await _timerRepository.getTimerForTask(taskId);
      if (timer != null && timer.isRunning) {
        await _timerRepository.stopTimer(taskId);
      }
      await loadTimers();
    } catch (e) {
      // Ignore errors - timer might not exist
      if (isClosed) return;
      await loadTimers();
    }
  }

  /// Get elapsed seconds for a task
  int getElapsedSeconds(String taskId) {
    final current = state;
    if (current is TimerLoaded) {
      return current.timersByTaskId[taskId]?.currentElapsedSeconds ?? 0;
    }
    if (current is TimerTicking && current.taskId == taskId) {
      return current.elapsedSeconds;
    }
    return 0;
  }

  void _startTicking(String taskId, Map<String, TimerEntity> timersByTaskId) {
    _stopTicking();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) {
        _stopTicking();
        return;
      }
      final timer = timersByTaskId[taskId];
      if (timer != null && timer.isRunning) {
        emit(TimerTicking(
          taskId: taskId,
          elapsedSeconds: timer.currentElapsedSeconds,
          timersByTaskId: timersByTaskId,
        ));
      }
    });
  }

  void _stopTicking() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  @override
  Future<void> close() {
    _stopTicking();
    return super.close();
  }
}
