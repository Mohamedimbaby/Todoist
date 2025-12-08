import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../presentation/cubits/board/board_cubit.dart';
import '../../presentation/pages/projects/projects_page.dart';
import '../../presentation/pages/board/board_page.dart';
import '../../presentation/pages/task_detail/task_detail_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/sync/sync_page.dart';
import 'app_routes.dart';

/// Application router configuration using GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.projects,
    debugLogDiagnostics: false,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  static final List<RouteBase> _routes = [
    // Projects Page (Home)
    GoRoute(
      path: AppRoutes.projects,
      name: 'projects',
      builder: (context, state) => const ProjectsPage(),
    ),

    // Sync Settings Page
    GoRoute(
      path: AppRoutes.sync,
      name: 'sync',
      builder: (context, state) => const SyncPage(),
    ),

    // Board Page
    GoRoute(
      path: AppRoutes.board,
      name: 'board',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final project = extra[RouteExtra.project] as ProjectEntity;

        return BoardPage(project: project);
      },
    ),

    // Task Detail Page
    GoRoute(
      path: AppRoutes.taskDetail,
      name: 'taskDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final task = extra[RouteExtra.task] as TaskEntity;
        final boardCubit = extra[RouteExtra.boardCubit] as BoardCubit?;

        return TaskDetailPage(
          task: task,
          projectId: task.projectId,
          boardCubit: boardCubit,
        );
      },
    ),

    // History Page
    GoRoute(
      path: AppRoutes.history,
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),
  ];

  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.projects),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
