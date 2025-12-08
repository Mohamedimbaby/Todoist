import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../di/injection.dart';
import '../../../domain/entities/task_entity.dart';
import '../../cubits/board/board_cubit.dart';
import '../../cubits/comments/comments_cubit.dart';
import '../../cubits/comments/comments_state.dart';
import '../../cubits/timer/timer_cubit.dart';
import '../../widgets/task_detail/task_info_card.dart';
import '../../widgets/task_detail/task_timer_section.dart';
import '../../widgets/comments/comments_section.dart';

/// Task detail page with timer and comments
class TaskDetailPage extends StatelessWidget {
  final TaskEntity task;
  final String? projectId;
  final BoardCubit? boardCubit;

  const TaskDetailPage({
    super.key,
    required this.task,
    this.projectId,
    this.boardCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<CommentsCubit>()
            ..loadComments(task.id, remoteTaskId: task.todoistId),
        ),
        BlocProvider.value(value: getIt<TimerCubit>()),
        if (boardCubit != null)
          BlocProvider.value(value: boardCubit!),
      ],
      child: _TaskDetailContent(
        task: task,
        projectId: projectId,
        boardCubit: boardCubit,
      ),
    );
  }
}

class _TaskDetailContent extends StatefulWidget {
  final TaskEntity task;
  final String? projectId;
  final BoardCubit? boardCubit;

  const _TaskDetailContent({
    required this.task,
    this.projectId,
    this.boardCubit,
  });

  @override
  State<_TaskDetailContent> createState() => _TaskDetailContentState();
}

class _TaskDetailContentState extends State<_TaskDetailContent> {
  late TaskEntity _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  void _handleTimerStart() {
    // Move to In Progress if in To Do or Done
    if (_currentTask.column == AppConstants.columnTodo ||
        _currentTask.column == AppConstants.columnDone) {
      widget.boardCubit?.moveToInProgress(_currentTask.id);

      // Update local state to reflect the change
      setState(() {
        _currentTask = _currentTask.copyWith(
          column: AppConstants.columnInProgress,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          BlocBuilder<CommentsCubit, CommentsState>(
            builder: (context, state) {
              if (state is CommentsLoaded && state.pendingSyncCount > 0) {
                return _SyncBadge(count: state.pendingSyncCount);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CommentsCubit, CommentsState>(
        listener: _handleStateChanges,
        builder: (context, state) => _buildBody(context, state),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, CommentsState state) {
    if (state is CommentsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (state is CommentsRefreshBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context, CommentsState state) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => context.read<CommentsCubit>().refreshComments(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskInfoCard(task: _currentTask),
                const SizedBox(height: 16),
                TaskTimerSection(
                  taskId: _currentTask.id,
                  currentColumn: _currentTask.column,
                  onTimerStart: _handleTimerStart,
                ),
                const SizedBox(height: 16),
                CommentsSection(
                  taskId: _currentTask.id,
                  projectId: widget.projectId,
                ),
              ],
            ),
          ),
        ),
        if (state is CommentsLoaded && state.operationMessage != null)
          _OperationOverlay(message: state.operationMessage!),
      ],
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final int count;

  const _SyncBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text('$count pending'),
        backgroundColor: Colors.orange.shade100,
        labelStyle: TextStyle(color: Colors.orange.shade800, fontSize: 12),
      ),
    );
  }
}

class _OperationOverlay extends StatelessWidget {
  final String message;

  const _OperationOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
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
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
