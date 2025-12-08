import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_entity.dart';

/// States for ProjectCubit
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// Loading projects
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// Projects loaded successfully
class ProjectLoaded extends ProjectState {
  final List<ProjectEntity> projects;
  final ProjectEntity? selectedProject;

  const ProjectLoaded({required this.projects, this.selectedProject});

  @override
  List<Object?> get props => [projects, selectedProject];
}

/// Project error
class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

/// No token configured
class ProjectNoToken extends ProjectState {
  const ProjectNoToken();
}

