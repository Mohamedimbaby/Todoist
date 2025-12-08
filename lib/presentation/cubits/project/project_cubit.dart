import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/providers/secure_storage_provider.dart';
import '../../../data/providers/todoist_api_provider.dart';
import '../../../data/models/project_model.dart';
import '../../../domain/entities/project_entity.dart';
import '../../../di/injection.dart';
import 'project_state.dart';

/// Cubit for managing Todoist projects
class ProjectCubit extends Cubit<ProjectState> {
  final SecureStorageProvider _secureStorage;
  TodoistApiProvider? _apiProvider;

  ProjectCubit({required SecureStorageProvider secureStorage})
      : _secureStorage = secureStorage,
        super(const ProjectInitial());

  /// Load all projects from Todoist
  Future<void> loadProjects() async {
    emit(const ProjectLoading());

    try {
      final token = await _secureStorage.getTodoistToken();
      if (token == null || token.isEmpty) {
        emit(const ProjectNoToken());
        return;
      }

      _apiProvider = TodoistApiProvider(
        dio: getIt<Dio>(),
        token: token,
      );

      final data = await _apiProvider!.getProjects();
      final projects = data
          .map((json) => ProjectModel.fromJson(json).toEntity())
          .toList();

      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  /// Select a project
  void selectProject(ProjectEntity project) {
    final current = state;
    if (current is ProjectLoaded) {
      emit(ProjectLoaded(
        projects: current.projects,
        selectedProject: project,
      ));
    }
  }

  /// Clear selected project
  void clearSelection() {
    final current = state;
    if (current is ProjectLoaded) {
      emit(ProjectLoaded(projects: current.projects));
    }
  }

  /// Create a new project
  Future<void> createProject(String name) async {
    if (_apiProvider == null) return;

    try {
      await _apiProvider!.createProject(name);
      await loadProjects();
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}

