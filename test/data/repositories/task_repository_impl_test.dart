import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/core/constants/app_constants.dart';
import 'package:tasktime/data/models/task_model.dart';
import 'package:tasktime/data/repositories/task_repository_impl.dart';
import 'package:tasktime/domain/entities/task_entity.dart';

class MockBox extends Mock implements Box<TaskModel> {}

void main() {
  late MockBox mockBox;
  late TaskRepositoryImpl repository;

  setUp(() {
    mockBox = MockBox();
    repository = TaskRepositoryImpl(tasksBox: mockBox);
  });

  setUpAll(() {
    registerFallbackValue(TaskModel(
      id: '',
      content: '',
      column: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  final testModel = TaskModel(
    id: '1',
    content: 'Test Task',
    column: 'To Do',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('TaskRepositoryImpl', () {
    test('getAllTasks returns list of entities', () async {
      when(() => mockBox.values).thenReturn([testModel]);

      final result = await repository.getAllTasks();

      expect(result.length, 1);
      expect(result.first.content, 'Test Task');
    });

    test('getTasksByColumn filters by column', () async {
      when(() => mockBox.values).thenReturn([testModel]);

      final result = await repository.getTasksByColumn('To Do');

      expect(result.length, 1);
      expect(result.first.column, 'To Do');
    });

    test('createTask saves to box', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      final task = TaskEntity(
        id: '1',
        content: 'New Task',
        column: AppConstants.columnTodo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createTask(task);

      expect(result.content, 'New Task');
      verify(() => mockBox.put(any(), any())).called(1);
    });

    test('deleteTask removes from box', () async {
      when(() => mockBox.delete('1')).thenAnswer((_) async {});

      await repository.deleteTask('1');

      verify(() => mockBox.delete('1')).called(1);
    });
  });
}

