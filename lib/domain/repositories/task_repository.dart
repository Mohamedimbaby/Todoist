import '../entities/task_entity.dart';

/// Abstract task repository interface
abstract class TaskRepository {
  /// Get all tasks
  Future<List<TaskEntity>> getAllTasks();

  /// Get tasks by column
  Future<List<TaskEntity>> getTasksByColumn(String column);

  /// Get task by ID
  Future<TaskEntity?> getTaskById(String id);

  /// Create a new task
  Future<TaskEntity> createTask(TaskEntity task);

  /// Update an existing task
  Future<TaskEntity> updateTask(TaskEntity task);

  /// Delete a task
  Future<void> deleteTask(String id);

  /// Move task to a different column
  Future<TaskEntity> moveTask(String id, String newColumn);

  /// Mark task as complete
  Future<void> completeTask(String id);

  /// Get unsynced tasks
  Future<List<TaskEntity>> getUnsyncedTasks();

  /// Mark task as synced
  Future<void> markTaskSynced(String id, String todoistId);
}

