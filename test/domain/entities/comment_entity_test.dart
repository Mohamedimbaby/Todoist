import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/domain/entities/comment_entity.dart';

void main() {
  group('CommentEntity', () {
    final now = DateTime.now();
    final comment = CommentEntity(
      id: 'comment-1',
      taskId: 'task-1',
      content: 'Test Comment',
      postedAt: now,
      projectId: 'project-1',
      isSynced: true,
    );

    test('should create CommentEntity with all properties', () {
      expect(comment.id, 'comment-1');
      expect(comment.taskId, 'task-1');
      expect(comment.content, 'Test Comment');
      expect(comment.postedAt, now);
      expect(comment.projectId, 'project-1');
      expect(comment.isSynced, true);
    });

    test('copyWith should create new instance with updated values', () {
      final updated = comment.copyWith(
        content: 'Updated Comment',
        isSynced: false,
      );

      expect(updated.id, 'comment-1');
      expect(updated.content, 'Updated Comment');
      expect(updated.isSynced, false);
      expect(updated.taskId, 'task-1');
    });

    test('equality check works correctly', () {
      final comment2 = CommentEntity(
        id: 'comment-1',
        taskId: 'task-1',
        content: 'Test Comment',
        postedAt: now,
        projectId: 'project-1',
        isSynced: true,
      );

      expect(comment, equals(comment2));
    });

    test('different comments are not equal', () {
      final comment2 = comment.copyWith(id: 'comment-2');
      expect(comment, isNot(equals(comment2)));
    });

    test('default isSynced is false', () {
      final newComment = CommentEntity(
        id: 'c1',
        taskId: 't1',
        content: 'New',
        postedAt: now,
      );

      expect(newComment.isSynced, false);
    });
  });
}

