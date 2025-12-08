import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/data/models/task_model.dart';
import 'package:tasktime/domain/entities/task_entity.dart';

void main() {
  group('TaskModel', () {
    final now = DateTime.now();
    final model = TaskModel(
      id: '1',
      content: 'Test Task',
      description: 'Description',
      column: 'To Do',
      projectId: 'project-1',
      priority: 2,
      createdAt: now,
      updatedAt: now,
      todoistId: 'remote-1',
      isSynced: true,
    );

    test('should create TaskModel with all properties', () {
      expect(model.id, '1');
      expect(model.content, 'Test Task');
      expect(model.todoistId, 'remote-1');
      expect(model.isSynced, true);
    });

    test('toEntity converts to TaskEntity correctly', () {
      final entity = model.toEntity();

      expect(entity, isA<TaskEntity>());
      expect(entity.id, '1');
      expect(entity.content, 'Test Task');
      expect(entity.todoistId, 'remote-1');
    });

    test('fromEntity creates model from entity', () {
      final entity = TaskEntity(
        id: '2',
        content: 'New Task',
        column: 'Done',
        createdAt: now,
        updatedAt: now,
      );

      final newModel = TaskModel.fromEntity(entity);

      expect(newModel.id, '2');
      expect(newModel.content, 'New Task');
      expect(newModel.column, 'Done');
    });
  });
}
