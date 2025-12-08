import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/data/models/history_model.dart';
import 'package:tasktime/data/repositories/history_repository_impl.dart';
import 'package:tasktime/domain/entities/history_entity.dart';

class MockBox extends Mock implements Box<HistoryModel> {}

void main() {
  late MockBox mockBox;
  late HistoryRepositoryImpl repository;

  setUp(() {
    mockBox = MockBox();
    repository = HistoryRepositoryImpl(historyBox: mockBox);
  });

  setUpAll(() {
    registerFallbackValue(HistoryModel(
      id: '',
      taskId: '',
      taskContent: '',
      totalTrackedSeconds: 0,
      completedAt: DateTime.now(),
    ));
  });

  final now = DateTime.now();
  final testModel = HistoryModel(
    id: '1',
    taskId: 'task-1',
    taskContent: 'Completed Task',
    totalTrackedSeconds: 3600,
    completedAt: now,
  );

  group('HistoryRepositoryImpl', () {
    test('getAllHistory returns list of records', () async {
      when(() => mockBox.values).thenReturn([testModel]);

      final result = await repository.getAllHistory();

      expect(result.length, 1);
      expect(result.first.taskContent, 'Completed Task');
    });

    test('createHistoryRecord saves to box', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      final entity = HistoryEntity(
        id: '1',
        taskId: 'task-1',
        taskContent: 'New Record',
        totalTrackedSeconds: 1800,
        completedAt: now,
      );

      final result = await repository.createHistoryRecord(entity);

      expect(result.taskContent, 'New Record');
      verify(() => mockBox.put(any(), any())).called(1);
    });

    test('getHistoryByDateRange filters correctly', () async {
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));
      when(() => mockBox.values).thenReturn([testModel]);

      final result =
          await repository.getHistoryByDateRange(yesterday, tomorrow);

      expect(result.length, 1);
    });

    test('getTotalTrackedTime sums all durations', () async {
      final model2 = HistoryModel(
        id: '2',
        taskId: 'task-2',
        taskContent: 'Task 2',
        totalTrackedSeconds: 1800,
        completedAt: now,
      );
      when(() => mockBox.values).thenReturn([testModel, model2]);

      final result = await repository.getTotalTrackedTime();

      expect(result, 5400);
    });
  });
}
