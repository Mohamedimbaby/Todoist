import 'package:equatable/equatable.dart';

/// Comment entity for task comments
class CommentEntity extends Equatable {
  final String id;
  final String taskId;
  final String? projectId;
  final String content;
  final String? todoistId;
  final DateTime postedAt;
  final String? attachment;
  final bool isSynced;

  const CommentEntity({
    required this.id,
    required this.taskId,
    this.projectId,
    required this.content,
    this.todoistId,
    required this.postedAt,
    this.attachment,
    this.isSynced = false,
  });

  CommentEntity copyWith({
    String? id,
    String? taskId,
    String? projectId,
    String? content,
    String? todoistId,
    DateTime? postedAt,
    String? attachment,
    bool? isSynced,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      content: content ?? this.content,
      todoistId: todoistId ?? this.todoistId,
      postedAt: postedAt ?? this.postedAt,
      attachment: attachment ?? this.attachment,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        projectId,
        content,
        todoistId,
        postedAt,
        attachment,
        isSynced,
      ];
}
