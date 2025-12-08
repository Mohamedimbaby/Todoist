import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task_entity.dart';
import '../../cubits/board/board_cubit.dart';
import '../../cubits/timer/timer_cubit.dart';
import 'board_task_card.dart';

/// A single column in the Kanban board
class BoardColumn extends StatelessWidget {
  final String title;
  final int id;
  final List<TaskEntity> tasks;
  final int columnPriority;
  final bool isDoneColumn;

  const BoardColumn({
    super.key,
    required this.id,
    required this.title,
    required this.tasks,
    required this.columnPriority,
    this.isDoneColumn = false,
  });

  bool get _isInProgressColumn => id == 2;
  bool get _isTodoColumn => id == 1;

  Color _headerColor(BuildContext context) {
    switch (id) {
      case 1:
        return AppColors.todoColumn;
      case 2:
        return AppColors.inProgressColumn;
      case 3:
        return AppColors.doneColumn;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<TaskEntity>(
      onAcceptWithDetails: (details) => _handleDrop(context, details.data),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: isHighlighted
              ? _headerColor(context).withValues(alpha: 0.1)
              : null,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildTaskList()),
            ],
          ),
        );
      },
    );
  }

  void _handleDrop(BuildContext context, TaskEntity task) {
    final boardCubit = context.read<BoardCubit>();
    final timerCubit = context.read<TimerCubit>();
    if(_checkIfSameStatus(task)) return;
    final isFromDoneColumn = task.column == AppConstants.columnDone;

    if (isDoneColumn) {
      try {
        timerCubit.stopTimer(task.id);
      } catch (_) {}
      boardCubit.completeTask(task);
    } else if (isFromDoneColumn) {
      boardCubit.moveTask(task.id, columnPriority, fromDoneColumn: true);
      if (_isInProgressColumn) {
        timerCubit.startTimer(task.id);
      }
    } else {
      boardCubit.moveTask(task.id, columnPriority);

      if (_isInProgressColumn) {
        timerCubit.startTimer(task.id);
      } else if (_isTodoColumn) {
        try {
          timerCubit.stopTimer(task.id);
        } catch (_) {}
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _headerColor(context).withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _headerColor(context),
              ),
            ),
          ),
          CircleAvatar(
            radius: 12,
            backgroundColor: _headerColor(context),
            child: Text(
              '${tasks.length}',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) => BoardTaskCard(
        task: tasks[index],
        isDone: isDoneColumn,
      ),
    );
  }

  bool _checkIfSameStatus(TaskEntity task) {
    return (task.column == AppConstants.columnDone && isDoneColumn)||
    (task.column == AppConstants.columnInProgress && _isInProgressColumn) ||
    (task.column == AppConstants.columnTodo && _isTodoColumn);
  }
}
