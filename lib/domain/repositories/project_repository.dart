import '../entities/project_entity.dart';

/// Abstract project repository interface
abstract class ProjectRepository {
  /// Get all local projects
  Future<List<ProjectEntity>> getAllProjects();

  /// Get project by ID
  Future<ProjectEntity?> getProjectById(String id);

  /// Save project locally
  Future<ProjectEntity> saveProject(ProjectEntity project);

  /// Delete project locally
  Future<void> deleteProject(String id);

  /// Fetch projects from Todoist API
  Future<List<ProjectEntity>> fetchRemoteProjects();

  /// Create project on Todoist
  Future<ProjectEntity> createRemoteProject(String name);

  /// Delete project on Todoist
  Future<void> deleteRemoteProject(String id);

  /// Sync local projects with remote
  Future<void> syncProjects();
}

