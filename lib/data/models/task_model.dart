import 'package:hive/hive.dart';
import 'package:tasktime/core/constants/app_constants.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String column;

  @HiveField(4)
  final int priority;

  @HiveField(5)
  final String? projectId;

  @HiveField(6)
  final String? todoistId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isSynced;

  TaskModel({
    required this.id,
    required this.content,
    this.description = '',
    required this.column,
    this.priority = 1,
    this.projectId,
    this.todoistId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      content: entity.content,
      description: entity.description,
      column: entity.column,
      priority: entity.priority,
      projectId: entity.projectId,
      todoistId: entity.todoistId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      content: map['content'] as String,
      description: map['description'] as String,
      column: map['column'] as String? ?? AppConstants.columnTodo,
      priority: map['priority'] as int,
      projectId: map['project_id'] as String?,
      createdAt: map["created_at"] ?? "",
      updatedAt: map["updated_at"] ?? "",
      isSynced: true
    );
  }
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      content: content,
      description: description,
      column: column,
      priority: priority,
      projectId: projectId,
      todoistId: todoistId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }
}

