import '../entities/timer_entity.dart';
import '../repositories/timer_repository.dart';

/// Use case for starting a timer
class StartTimerUseCase {
  final TimerRepository _repository;

  StartTimerUseCase(this._repository);

  Future<TimerEntity> call(String taskId) async {
    // Stop any running timer first (single concurrent timer)
    await _repository.stopAllTimers();
    return _repository.startTimer(taskId);
  }
}

/// Use case for stopping a timer
class StopTimerUseCase {
  final TimerRepository _repository;

  StopTimerUseCase(this._repository);

  Future<TimerEntity> call(String taskId) => _repository.stopTimer(taskId);
}

/// Use case for getting timer for a task
class GetTimerForTaskUseCase {
  final TimerRepository _repository;

  GetTimerForTaskUseCase(this._repository);

  Future<TimerEntity?> call(String taskId) =>
      _repository.getTimerForTask(taskId);
}

/// Use case for getting the running timer
class GetRunningTimerUseCase {
  final TimerRepository _repository;

  GetRunningTimerUseCase(this._repository);

  Future<TimerEntity?> call() => _repository.getRunningTimer();
}

/// Use case for getting total tracked time
class GetTotalTrackedTimeUseCase {
  final TimerRepository _repository;

  GetTotalTrackedTimeUseCase(this._repository);

  Future<int> call(String taskId) => _repository.getTotalTrackedSeconds(taskId);
}

