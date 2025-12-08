import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/domain/entities/task_entity.dart';

void main() {
  group('TaskEntity', () {
    final now = DateTime.now();
    final task = TaskEntity(
      id: '1',
      content: 'Test Task',
      description: 'Description',
      column: 'To Do',
      projectId: 'project-1',
      priority: 2,
      createdAt: now,
      updatedAt: now,
    );

    test('should create TaskEntity with all properties', () {
      expect(task.id, '1');
      expect(task.content, 'Test Task');
      expect(task.description, 'Description');
      expect(task.column, 'To Do');
      expect(task.projectId, 'project-1');
      expect(task.priority, 2);
    });

    test('copyWith should create new instance with updated values', () {
      final updated = task.copyWith(
        content: 'Updated Task',
        column: 'In Progress',
      );

      expect(updated.id, '1');
      expect(updated.content, 'Updated Task');
      expect(updated.column, 'In Progress');
      expect(updated.description, 'Description');
    });

    test('copyWith with no params returns identical values', () {
      final copy = task.copyWith();

      expect(copy.id, task.id);
      expect(copy.content, task.content);
      expect(copy.column, task.column);
    });

    test('equality check works correctly', () {
      final task2 = TaskEntity(
        id: '1',
        content: 'Test Task',
        description: 'Description',
        column: 'To Do',
        projectId: 'project-1',
        priority: 2,
        createdAt: now,
        updatedAt: now,
      );

      expect(task, equals(task2));
    });

    test('different tasks are not equal', () {
      final task2 = task.copyWith(id: '2');
      expect(task, isNot(equals(task2)));
    });

    test('props returns correct values', () {
      expect(task.props.contains('1'), true);
      expect(task.props.contains('Test Task'), true);
    });
  });
}

