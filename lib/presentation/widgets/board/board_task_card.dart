import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task_entity.dart';
import '../../cubits/board/board_cubit.dart';
import '../../cubits/timer/timer_cubit.dart';
import '../../cubits/timer/timer_state.dart';
import '../../../utils/time_formatter.dart';

/// Draggable task card for the board with timer
class BoardTaskCard extends StatelessWidget {
  final TaskEntity task;
  final bool isDone;

  const BoardTaskCard({
    super.key,
    required this.task,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<TaskEntity>(
      data: task,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            task.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _CardBody(task: task, isDone: isDone),
      ),
      child: _CardBody(task: task, isDone: isDone),
    );
  }
}

class _CardBody extends StatelessWidget {
  final TaskEntity task;
  final bool isDone;

  const _CardBody({required this.task, this.isDone = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showTaskOptions(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTaskTitle(),
              if (task.description.isNotEmpty) _buildDescription(),
              const SizedBox(height: 6),
              _buildTimerRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTitle() {
    return Row(
      children: [
        if (isDone)
          const Icon(Icons.check_circle, size: 14, color: AppColors.doneColumn),
        if (isDone) const SizedBox(width: 4),
        Expanded(
          child: Text(
            task.content,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        task.description,
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTimerRow(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        final isRunning = _isTimerRunning(state);
        final seconds = _getElapsedSeconds(state);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimerDisplay(seconds, isRunning),
            const SizedBox(width: 4),
            _buildTimerButton(context, isRunning),
          ],
        );
      },
    );
  }

  Widget _buildTimerDisplay(int seconds, bool isRunning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isRunning
            ? AppColors.accent.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color: isRunning ? AppColors.accent : Colors.grey,
          ),
          const SizedBox(width: 3),
          Text(
            TimeFormatter.formatSeconds(seconds),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isRunning ? FontWeight.bold : FontWeight.normal,
              color: isRunning ? AppColors.accent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(BuildContext context, bool isRunning) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTimerTap(context, isRunning),
        child: Icon(
          isRunning ? Icons.stop_circle : Icons.play_circle,
          color: isRunning ? AppColors.error : AppColors.accent,
          size: 20,
        ),
      ),
    );
  }

  void _handleTimerTap(BuildContext context, bool isRunning) {
    final timerCubit = context.read<TimerCubit>();
    final boardCubit = context.read<BoardCubit>();

    if (isRunning) {
      timerCubit.stopTimer(task.id);
    } else {
      timerCubit.startTimer(task.id);

      // Move to In Progress if in To Do
      if (task.column == AppConstants.columnTodo || task.column == AppConstants.columnDone) {
        boardCubit.moveToInProgress(task.id);
      }
    }
  }

  bool _isTimerRunning(TimerState state) {
    if (state is TimerLoaded) {
      return state.runningTimer?.taskId == task.id;
    }
    if (state is TimerTicking) {
      return state.taskId == task.id;
    }
    return false;
  }

  int _getElapsedSeconds(TimerState state) {
    if (state is TimerTicking && state.taskId == task.id) {
      return state.elapsedSeconds;
    }
    if (state is TimerLoaded) {
      return state.timersByTaskId[task.id]?.currentElapsedSeconds ?? 0;
    }
    return 0;
  }

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('View Details'),
              onTap: () {
                ctx.pop();
                _navigateToDetails(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Mark Complete'),
              onTap: () {
                ctx.pop();
                context.read<BoardCubit>().completeTask(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                ctx.pop();
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    final boardCubit = context.read<BoardCubit>();
    context.push(
      AppRoutes.taskDetailPath(task.id),
      extra: {
        RouteExtra.task: task,
        RouteExtra.boardCubit: boardCubit,
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ctx.pop();
              context.read<BoardCubit>().deleteTask(task.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
