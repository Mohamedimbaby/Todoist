import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Use case for getting all tasks
class GetAllTasksUseCase {
  final TaskRepository _repository;

  GetAllTasksUseCase(this._repository);

  Future<List<TaskEntity>> call() => _repository.getAllTasks();
}

/// Use case for getting tasks by column
class GetTasksByColumnUseCase {
  final TaskRepository _repository;

  GetTasksByColumnUseCase(this._repository);

  Future<List<TaskEntity>> call(String column) =>
      _repository.getTasksByColumn(column);
}

/// Use case for creating a task
class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  Future<TaskEntity> call(TaskEntity task) => _repository.createTask(task);
}

/// Use case for updating a task
class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  Future<TaskEntity> call(TaskEntity task) => _repository.updateTask(task);
}

/// Use case for deleting a task
class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteTask(id);
}

/// Use case for moving a task between columns
class MoveTaskUseCase {
  final TaskRepository _repository;

  MoveTaskUseCase(this._repository);

  Future<TaskEntity> call(String id, String newColumn) =>
      _repository.moveTask(id, newColumn);
}

/// Use case for completing a task
class CompleteTaskUseCase {
  final TaskRepository _repository;

  CompleteTaskUseCase(this._repository);

  Future<void> call(String id) => _repository.completeTask(id);
}

