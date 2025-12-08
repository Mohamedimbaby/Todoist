import 'package:equatable/equatable.dart';

/// Task entity representing a Kanban task
class TaskEntity extends Equatable {
  final String id;
  final String content;
  final String description;
  final String column;
  final int priority;
  final String? projectId;
  final String? todoistId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const TaskEntity({
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

  TaskEntity copyWith({
    String? id,
    String? content,
    String? description,
    String? column,
    int? priority,
    String? projectId,
    String? todoistId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      description: description ?? this.description,
      column: column ?? this.column,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      todoistId: todoistId ?? this.todoistId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        description,
        column,
        priority,
        projectId,
        todoistId,
        createdAt,
        updatedAt,
        isSynced,
      ];
}

