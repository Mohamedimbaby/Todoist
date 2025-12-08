import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../di/injection.dart';
import '../../../domain/entities/project_entity.dart';
import '../../cubits/board/board_cubit.dart';
import '../../cubits/board/board_state.dart';
import '../../cubits/timer/timer_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../cubits/language/language_cubit.dart';
import '../../widgets/board/board_content.dart';
import '../../widgets/board/board_drawer.dart';
import '../../widgets/dialogs/add_board_task_dialog.dart';

/// Board page showing Kanban columns for a project
class BoardPage extends StatelessWidget {
  final ProjectEntity project;

  const BoardPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Get the singleton TimerCubit and load timers
    final timerCubit = getIt<TimerCubit>();
    timerCubit.loadTimers();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = getIt<BoardCubit>();
            cubit.setProject(project);
            cubit.loadTasks();
            return cubit;
          },
        ),
        // Use BlocProvider.value to prevent closing the singleton
        BlocProvider.value(value: timerCubit),
      ],
      child: _BoardPageContent(project: project),
    );
  }
}

class _BoardPageContent extends StatelessWidget {
  final ProjectEntity project;

   _BoardPageContent({required this.project});
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ThemeCubit>()),
        BlocProvider.value(value: context.read<LanguageCubit>()),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(context),
        drawer: BoardDrawer(
          project: project,
          onChangeProject: () {
            _scaffoldKey.currentState?.closeDrawer();
            context.go(AppRoutes.projects);
          },
        ),
        body: BlocConsumer<BoardCubit, BoardState>(
          listener: _handleStateChanges,
          builder: (context, state) => _buildBody(context, state),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(project.name),
      actions: [
        BlocBuilder<BoardCubit, BoardState>(
          builder: (context, state) {
            if (state is BoardLoaded && state.pendingSyncCount > 0) {
              return _buildSyncBadge(context, state.pendingSyncCount);
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: const Icon(Icons.sync),
          tooltip: 'Sync now',
          onPressed: () => context.read<BoardCubit>().syncNow(),
        ),
      ],
    );
  }

  Widget _buildSyncBadge(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text('$count pending'),
        backgroundColor: Colors.orange.shade100,
        labelStyle: TextStyle(color: Colors.orange.shade800, fontSize: 12),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, BoardState state) {
    if (state is BoardError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          action: state.previousState != null
              ? SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    // Return to previous state
                    if (state.previousState != null) {
                      context.read<BoardCubit>().loadTasks();
                    }
                  },
                )
              : null,
        ),
      );
    }

    if (state is BoardRefreshBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context, BoardState state) {
    if (state is BoardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BoardLoaded) {
      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => context.read<BoardCubit>().refresh(),
            child: BoardContent(state: state),
          ),
          if (state.operationMessage != null)
            _buildOperationOverlay(state.operationMessage!),
        ],
      );
    }

    if (state is BoardRefreshBlocked) {
      return RefreshIndicator(
        onRefresh: () => context.read<BoardCubit>().refresh(),
        child: BoardContent(state: state.currentState),
      );
    }

    if (state is BoardError && state.previousState != null) {
      return RefreshIndicator(
        onRefresh: () => context.read<BoardCubit>().refresh(),
        child: BoardContent(state: state.previousState!),
      );
    }

    if (state is BoardError) {
      return _buildErrorView(context, state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildOperationOverlay(String message) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
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
            onPressed: () => context.read<BoardCubit>().loadTasks(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<BoardCubit>(),
        child: const AddBoardTaskDialog(),
      ),
    );
  }
}
