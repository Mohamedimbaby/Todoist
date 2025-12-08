import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/data/models/timer_model.dart';
import 'package:tasktime/data/repositories/timer_repository_impl.dart';

class MockBox extends Mock implements Box<TimerModel> {}

void main() {
  late MockBox mockBox;
  late TimerRepositoryImpl repository;

  setUp(() {
    mockBox = MockBox();
    repository = TimerRepositoryImpl(timersBox: mockBox);
  });

  setUpAll(() {
    registerFallbackValue(TimerModel(
      id: '',
      taskId: '',
      isRunning: false,
      accumulatedSeconds: 0,
    ));
  });

  final testModel = TimerModel(
    id: '1',
    taskId: 'task-1',
    isRunning: true,
    accumulatedSeconds: 100,
    startTimestamp: DateTime.now(),
  );

  group('TimerRepositoryImpl', () {
    test('getAllTimers returns list of entities', () async {
      when(() => mockBox.values).thenReturn([testModel]);

      final result = await repository.getAllTimers();

      expect(result.length, 1);
      expect(result.first.taskId, 'task-1');
    });

    test('getTimerForTask returns timer when found', () async {
      when(() => mockBox.values).thenReturn([testModel]);

      final result = await repository.getTimerForTask('task-1');

      expect(result, isNotNull);
      expect(result!.taskId, 'task-1');
    });

    test('getTimerForTask returns null when not found', () async {
      when(() => mockBox.values).thenReturn([]);

      final result = await repository.getTimerForTask('unknown');

      expect(result, isNull);
    });

    test('getRunningTimer returns running timer', () async {
      when(() => mockBox.values).thenReturn([testModel]);

      final result = await repository.getRunningTimer();

      expect(result, isNotNull);
      expect(result!.isRunning, true);
    });

    test('getRunningTimer returns null when no running timer', () async {
      final stoppedTimer = TimerModel(
        id: '1',
        taskId: 'task-1',
        isRunning: false,
        accumulatedSeconds: 100,
      );
      when(() => mockBox.values).thenReturn([stoppedTimer]);

      final result = await repository.getRunningTimer();

      expect(result, isNull);
    });

    test('startTimer creates new timer', () async {
      when(() => mockBox.values).thenReturn([]);
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      final result = await repository.startTimer('task-1');

      expect(result.taskId, 'task-1');
      expect(result.isRunning, true);
      verify(() => mockBox.put(any(), any())).called(1);
    });

    test('stopTimer stops running timer', () async {
      when(() => mockBox.values).thenReturn([testModel]);
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      final result = await repository.stopTimer('task-1');

      expect(result.isRunning, false);
    });

    test('stopAllTimers stops all running timers', () async {
      when(() => mockBox.values).thenReturn([testModel]);
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await repository.stopAllTimers();

      verify(() => mockBox.put(any(), any())).called(1);
    });
  });
}
