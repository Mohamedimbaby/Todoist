import 'package:hive/hive.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';
import '../providers/todoist_api_provider.dart';

/// Implementation of ProjectRepository using Hive and Todoist API
class ProjectRepositoryImpl implements ProjectRepository {
  final Box<ProjectModel> _projectsBox;
  final TodoistApiProvider? _apiProvider;

  ProjectRepositoryImpl({
    required Box<ProjectModel> projectsBox,
    TodoistApiProvider? apiProvider,
  })  : _projectsBox = projectsBox,
        _apiProvider = apiProvider;

  @override
  Future<List<ProjectEntity>> getAllProjects() async {
    return _projectsBox.values.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProjectEntity?> getProjectById(String id) async {
    final model = _projectsBox.get(id);
    return model?.toEntity();
  }

  @override
  Future<ProjectEntity> saveProject(ProjectEntity project) async {
    await _projectsBox.put(project.id, ProjectModel.fromEntity(project));
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    await _projectsBox.delete(id);
  }

  @override
  Future<List<ProjectEntity>> fetchRemoteProjects() async {
    if (_apiProvider == null) return [];
    final data = await _apiProvider.getProjects();
    return data.map((json) => ProjectModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<ProjectEntity> createRemoteProject(String name) async {
    if (_apiProvider == null) throw Exception('API not configured');
    final data = await _apiProvider.createProject(name);
    return ProjectModel.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteRemoteProject(String id) async {
    if (_apiProvider == null) return;
    await _apiProvider.deleteProject(id);
  }

  @override
  Future<void> syncProjects() async {
    if (_apiProvider == null) return;
    final remoteProjects = await fetchRemoteProjects();
    await _projectsBox.clear();
    for (final project in remoteProjects) {
      await saveProject(project);
    }
  }
}
