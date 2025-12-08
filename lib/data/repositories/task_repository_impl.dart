import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository using Hive
class TaskRepositoryImpl implements TaskRepository {
  final Box<TaskModel> _tasksBox;

  TaskRepositoryImpl({required Box<TaskModel> tasksBox})
      : _tasksBox = tasksBox;

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    return _tasksBox.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByColumn(String column) async {
    return _tasksBox.values
        .where((model) => model.column == column)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final model = _tasksBox.get(id);
    return model?.toEntity();
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    final id = task.id.isEmpty ? const Uuid().v4() : task.id;
    final now = DateTime.now();
    final newTask = task.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    await _tasksBox.put(id, TaskModel.fromEntity(newTask));
    return newTask;
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _tasksBox.put(task.id, TaskModel.fromEntity(updatedTask));
    return updatedTask;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  @override
  Future<TaskEntity> moveTask(String id, String newColumn) async {
    final model = _tasksBox.get(id);
    if (model == null) throw Exception('Task not found');
    final entity = model.toEntity();
    final updatedTask = entity.copyWith(
      column: newColumn,
      updatedAt: DateTime.now(),
    );
    await _tasksBox.put(id, TaskModel.fromEntity(updatedTask));
    return updatedTask;
  }

  @override
  Future<void> completeTask(String id) async {
    await moveTask(id, AppConstants.columnDone);
  }

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() async {
    return _tasksBox.values
        .where((model) => !model.isSynced)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> markTaskSynced(String id, String todoistId) async {
    final model = _tasksBox.get(id);
    if (model == null) return;
    final entity = model.toEntity();
    final synced = entity.copyWith(isSynced: true, todoistId: todoistId);
    await _tasksBox.put(id, TaskModel.fromEntity(synced));
  }
}

