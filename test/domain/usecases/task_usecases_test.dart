import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/domain/entities/task_entity.dart';
import 'package:tasktime/domain/repositories/task_repository.dart';
import 'package:tasktime/domain/usecases/task_usecases.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepository;
  late GetAllTasksUseCase getAllTasksUseCase;
  late CreateTaskUseCase createTaskUseCase;
  late MoveTaskUseCase moveTaskUseCase;
  late DeleteTaskUseCase deleteTaskUseCase;

  setUp(() {
    mockRepository = MockTaskRepository();
    getAllTasksUseCase = GetAllTasksUseCase(mockRepository);
    createTaskUseCase = CreateTaskUseCase(mockRepository);
    moveTaskUseCase = MoveTaskUseCase(mockRepository);
    deleteTaskUseCase = DeleteTaskUseCase(mockRepository);
  });

  final testTask = TaskEntity(
    id: '1',
    content: 'Test Task',
    column: 'To Do',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('GetAllTasksUseCase', () {
    test('should return list of tasks from repository', () async {
      when(() => mockRepository.getAllTasks())
          .thenAnswer((_) async => [testTask]);

      final result = await getAllTasksUseCase();

      expect(result, [testTask]);
      verify(() => mockRepository.getAllTasks()).called(1);
    });
  });

  group('CreateTaskUseCase', () {
    test('should create task via repository', () async {
      when(() => mockRepository.createTask(testTask))
          .thenAnswer((_) async => testTask);

      final result = await createTaskUseCase(testTask);

      expect(result, testTask);
      verify(() => mockRepository.createTask(testTask)).called(1);
    });
  });

  group('MoveTaskUseCase', () {
    test('should move task to new column', () async {
      final movedTask = testTask.copyWith(column: 'In Progress');
      when(() => mockRepository.moveTask('1', 'In Progress'))
          .thenAnswer((_) async => movedTask);

      final result = await moveTaskUseCase('1', 'In Progress');

      expect(result.column, 'In Progress');
      verify(() => mockRepository.moveTask('1', 'In Progress')).called(1);
    });
  });

  group('DeleteTaskUseCase', () {
    test('should delete task via repository', () async {
      when(() => mockRepository.deleteTask('1')).thenAnswer((_) async {});

      await deleteTaskUseCase('1');

      verify(() => mockRepository.deleteTask('1')).called(1);
    });
  });
}

