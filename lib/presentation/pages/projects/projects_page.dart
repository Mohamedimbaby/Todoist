import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/project/project_cubit.dart';
import '../../cubits/project/project_state.dart';
import '../../widgets/projects/projects_list.dart';
import '../../widgets/projects/no_token_view.dart';
import '../../widgets/dialogs/add_project_dialog.dart';

/// Projects page - initial screen showing all Todoist projects
class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectCubit>().loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProjectCubit>().loadProjects(),
          ),
        ],
      ),
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectNoToken) {
            return const NoTokenView();
          }

          if (state is ProjectError) {
            return _buildErrorView(context, state.message);
          }

          if (state is ProjectLoaded) {
            return ProjectsList(projects: state.projects);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoaded) {
            return FloatingActionButton(
              onPressed: () => _showAddProjectDialog(context),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProjectCubit>().loadProjects(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProjectCubit>(),
        child: const AddProjectDialog(),
      ),
    );
  }
}

