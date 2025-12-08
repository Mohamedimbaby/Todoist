import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../cubits/project/project_cubit.dart';

/// View shown when no Todoist token is configured
class NoTokenView extends StatelessWidget {
  const NoTokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Connect to Todoist',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your Todoist API token to sync your projects and tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openSyncSettings(context),
              icon: const Icon(Icons.link),
              label: const Text('Connect Todoist'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSyncSettings(BuildContext context) async {
    final projectCubit = context.read<ProjectCubit>();
    await context.push(AppRoutes.sync);
    // Refresh projects when returning from sync page
    projectCubit.loadProjects();
  }
}
