import 'package:hive/hive.dart';
import '../../domain/entities/comment_entity.dart';

part 'comment_model.g.dart';

@HiveType(typeId: 2)
class CommentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String? projectId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final String? todoistId;

  @HiveField(5)
  final DateTime postedAt;

  @HiveField(6)
  final String? attachment;

  @HiveField(7)
  final bool isSynced;

  CommentModel({
    required this.id,
    required this.taskId,
    this.projectId,
    required this.content,
    this.todoistId,
    required this.postedAt,
    this.attachment,
    this.isSynced = false,
  });

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      taskId: entity.taskId,
      projectId: entity.projectId,
      content: entity.content,
      todoistId: entity.todoistId,
      postedAt: entity.postedAt,
      attachment: entity.attachment,
      isSynced: entity.isSynced,
    );
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      taskId: taskId,
      projectId: projectId,
      content: content,
      todoistId: todoistId,
      postedAt: postedAt,
      attachment: attachment,
      isSynced: isSynced,
    );
  }
}
