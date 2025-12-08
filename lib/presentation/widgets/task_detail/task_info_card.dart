import 'package:flutter/material.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../core/theme/app_colors.dart';

/// Card displaying task information
class TaskInfoCard extends StatelessWidget {
  final TaskEntity task;

  const TaskInfoCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskTitle(content: task.content),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              _TaskDescription(description: task.description),
            ],
            const SizedBox(height: 12),
            _TaskMetadata(task: task),
          ],
        ),
      ),
    );
  }
}

class _TaskTitle extends StatelessWidget {
  final String content;

  const _TaskTitle({required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _TaskDescription extends StatelessWidget {
  final String description;

  const _TaskDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
    );
  }
}

class _TaskMetadata extends StatelessWidget {
  final TaskEntity task;

  const _TaskMetadata({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusChip(column: task.column),
        const SizedBox(width: 8),
        _PriorityChip(priority: task.priority),
        const Spacer(),
        _SyncStatus(isSynced: task.isSynced),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String column;

  const _StatusChip({required this.column});

  Color get _color {
    switch (column) {
      case 'todo':
        return AppColors.todoColumn;
      case 'in_progress':
        return AppColors.inProgressColumn;
      case 'done':
        return AppColors.doneColumn;
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (column) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      default:
        return column;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label,
        style: TextStyle(color: _color, fontSize: 12),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final int priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'P$priority',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  final bool isSynced;

  const _SyncStatus({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSynced ? Icons.cloud_done : Icons.cloud_off,
      size: 16,
      color: isSynced ? Colors.green : Colors.orange,
    );
  }
}

