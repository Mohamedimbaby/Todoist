import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/domain/entities/timer_entity.dart';
import 'package:tasktime/domain/repositories/timer_repository.dart';
import 'package:tasktime/domain/usecases/timer_usecases.dart';

class MockTimerRepository extends Mock implements TimerRepository {}

void main() {
  late MockTimerRepository mockRepository;
  late StartTimerUseCase startTimerUseCase;
  late StopTimerUseCase stopTimerUseCase;
  late GetRunningTimerUseCase getRunningTimerUseCase;

  setUp(() {
    mockRepository = MockTimerRepository();
    startTimerUseCase = StartTimerUseCase(mockRepository);
    stopTimerUseCase = StopTimerUseCase(mockRepository);
    getRunningTimerUseCase = GetRunningTimerUseCase(mockRepository);
  });

  final testTimer = TimerEntity(
    id: '1',
    taskId: 'task-1',
    isRunning: true,
    startTimestamp: DateTime.now(),
  );

  group('StartTimerUseCase', () {
    test('should stop all timers and start new one', () async {
      when(() => mockRepository.stopAllTimers()).thenAnswer((_) async {});
      when(() => mockRepository.startTimer('task-1'))
          .thenAnswer((_) async => testTimer);

      final result = await startTimerUseCase('task-1');

      expect(result.isRunning, true);
      expect(result.taskId, 'task-1');
      verify(() => mockRepository.stopAllTimers()).called(1);
      verify(() => mockRepository.startTimer('task-1')).called(1);
    });
  });

  group('StopTimerUseCase', () {
    test('should stop timer for task', () async {
      final stoppedTimer = testTimer.copyWith(isRunning: false);
      when(() => mockRepository.stopTimer('task-1'))
          .thenAnswer((_) async => stoppedTimer);

      final result = await stopTimerUseCase('task-1');

      expect(result.isRunning, false);
      verify(() => mockRepository.stopTimer('task-1')).called(1);
    });
  });

  group('GetRunningTimerUseCase', () {
    test('should return running timer', () async {
      when(() => mockRepository.getRunningTimer())
          .thenAnswer((_) async => testTimer);

      final result = await getRunningTimerUseCase();

      expect(result, testTimer);
      verify(() => mockRepository.getRunningTimer()).called(1);
    });

    test('should return null when no timer running', () async {
      when(() => mockRepository.getRunningTimer())
          .thenAnswer((_) async => null);

      final result = await getRunningTimerUseCase();

      expect(result, isNull);
    });
  });
}

