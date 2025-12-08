import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/domain/entities/timer_entity.dart';

void main() {
  group('TimerEntity', () {
    final now = DateTime.now();
    final timer = TimerEntity(
      id: '1',
      taskId: 'task-1',
      isRunning: true,
      accumulatedSeconds: 100,
      startTimestamp: now,
    );

    test('should create TimerEntity with all properties', () {
      expect(timer.id, '1');
      expect(timer.taskId, 'task-1');
      expect(timer.isRunning, true);
      expect(timer.accumulatedSeconds, 100);
      expect(timer.startTimestamp, now);
    });

    test('copyWith should create new instance with updated values', () {
      final updated = timer.copyWith(
        isRunning: false,
        accumulatedSeconds: 200,
      );

      expect(updated.id, '1');
      expect(updated.isRunning, false);
      expect(updated.accumulatedSeconds, 200);
      expect(updated.taskId, 'task-1');
    });

    test('equality check works correctly', () {
      final timer2 = TimerEntity(
        id: '1',
        taskId: 'task-1',
        isRunning: true,
        accumulatedSeconds: 100,
        startTimestamp: now,
      );

      expect(timer, equals(timer2));
    });

    test('different timers are not equal', () {
      final timer2 = timer.copyWith(id: '2');
      expect(timer, isNot(equals(timer2)));
    });

    test('copyWith clearStartTimestamp sets startTimestamp to null', () {
      final stopped = timer.copyWith(
        isRunning: false,
        clearStartTimestamp: true,
      );

      expect(stopped.startTimestamp, isNull);
      expect(stopped.isRunning, false);
      expect(stopped.id, timer.id);
    });

    test('props returns correct values', () {
      expect(timer.props.contains('1'), true);
      expect(timer.props.contains('task-1'), true);
    });
  });
}
