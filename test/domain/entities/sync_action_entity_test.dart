import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/domain/entities/sync_action_entity.dart';

void main() {
  group('SyncActionEntity', () {
    final now = DateTime.now();
    final action = SyncActionEntity(
      id: 'action-1',
      type: SyncActionType.createTask,
      entityId: 'task-1',
      payload: {'content': 'Test Task'},
      createdAt: now,
    );

    test('should create SyncActionEntity with all properties', () {
      expect(action.id, 'action-1');
      expect(action.type, SyncActionType.createTask);
      expect(action.entityId, 'task-1');
      expect(action.payload, {'content': 'Test Task'});
      expect(action.createdAt, now);
    });

    test('SyncActionType enum has all required types', () {
      expect(SyncActionType.values, contains(SyncActionType.createTask));
      expect(SyncActionType.values, contains(SyncActionType.updateTask));
      expect(SyncActionType.values, contains(SyncActionType.deleteTask));
      expect(SyncActionType.values, contains(SyncActionType.completeTask));
      expect(SyncActionType.values, contains(SyncActionType.createProject));
      expect(SyncActionType.values, contains(SyncActionType.deleteProject));
      expect(SyncActionType.values, contains(SyncActionType.createComment));
      expect(SyncActionType.values, contains(SyncActionType.deleteComment));
    });

    test('equality check works correctly', () {
      final action2 = SyncActionEntity(
        id: 'action-1',
        type: SyncActionType.createTask,
        entityId: 'task-1',
        payload: {'content': 'Test Task'},
        createdAt: now,
      );

      expect(action, equals(action2));
    });

    test('different actions are not equal', () {
      final action2 = SyncActionEntity(
        id: 'action-2',
        type: SyncActionType.updateTask,
        entityId: 'task-1',
        payload: {},
        createdAt: now,
      );
      expect(action, isNot(equals(action2)));
    });

    test('props returns correct values', () {
      expect(action.props.contains('action-1'), true);
      expect(action.props.contains(SyncActionType.createTask), true);
    });
  });
}

