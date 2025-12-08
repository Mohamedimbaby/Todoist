import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

/// Use case for getting all local projects
class GetAllProjectsUseCase {
  final ProjectRepository _repository;

  GetAllProjectsUseCase(this._repository);

  Future<List<ProjectEntity>> call() => _repository.getAllProjects();
}

/// Use case for getting a project by ID
class GetProjectByIdUseCase {
  final ProjectRepository _repository;

  GetProjectByIdUseCase(this._repository);

  Future<ProjectEntity?> call(String id) => _repository.getProjectById(id);
}

/// Use case for saving a project locally
class SaveProjectUseCase {
  final ProjectRepository _repository;

  SaveProjectUseCase(this._repository);

  Future<ProjectEntity> call(ProjectEntity project) =>
      _repository.saveProject(project);
}

/// Use case for deleting a project locally
class DeleteLocalProjectUseCase {
  final ProjectRepository _repository;

  DeleteLocalProjectUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteProject(id);
}

/// Use case for fetching remote projects
class FetchRemoteProjectsUseCase {
  final ProjectRepository _repository;

  FetchRemoteProjectsUseCase(this._repository);

  Future<List<ProjectEntity>> call() => _repository.fetchRemoteProjects();
}

/// Use case for creating a remote project
class CreateRemoteProjectUseCase {
  final ProjectRepository _repository;

  CreateRemoteProjectUseCase(this._repository);

  Future<ProjectEntity> call(String name) =>
      _repository.createRemoteProject(name);
}

/// Use case for deleting a remote project
class DeleteRemoteProjectUseCase {
  final ProjectRepository _repository;

  DeleteRemoteProjectUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteRemoteProject(id);
}

/// Use case for syncing projects
class SyncProjectsUseCase {
  final ProjectRepository _repository;

  SyncProjectsUseCase(this._repository);

  Future<void> call() => _repository.syncProjects();
}

