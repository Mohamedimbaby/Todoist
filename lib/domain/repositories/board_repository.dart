import '../entities/task_entity.dart';

/// Repository interface for board operations (local-first)
abstract class BoardRepository {
  /// Get all tasks for a project from local storage
  Future<List<TaskEntity>> getTasksForProject(String projectId);

  /// Check if cache is expired for a project
  Future<bool> isCacheExpired(String projectId);

  /// Update the last fetch time for a project
  Future<void> updateLastFetchTime(String projectId);

  /// Create a task locally and queue sync
  Future<TaskEntity> createTask(TaskEntity task);

  /// Update task priority (move between columns) locally and queue sync
  Future<TaskEntity> updateTaskPriority(String taskId, int newPriority);

  /// Complete a task locally and queue sync
  Future<TaskEntity> completeTask(String taskId);

  /// Reopen a completed task locally and queue sync
  Future<TaskEntity> reopenTask(String taskId, int priority);

  /// Delete a task locally and queue sync
  Future<void> deleteTask(String taskId);

  /// Save tasks from API to local storage (for refresh)
  Future<void> saveTasksFromApi(List<Map<String, dynamic>> apiTasks);

  /// Check if there are pending sync actions
  Future<bool> hasPendingSyncActions();

  /// Get pending sync actions count
  Future<int> getPendingSyncCount();
}
