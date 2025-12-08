import 'package:flutter/material.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../core/theme/app_colors.dart';

/// Header section for task detail page
class TaskDetailHeader extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailHeader({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusChip(),
            const SizedBox(height: 12),
            Text(
              task.content,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            const SizedBox(height: 12),
            _buildMetaInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        task.column,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _getColumnColor(),
      padding: EdgeInsets.zero,
    );
  }

  Color _getColumnColor() {
    switch (task.column) {
      case 'To Do':
        return AppColors.todoColumn;
      case 'In Progress':
        return AppColors.inProgressColumn;
      case 'Done':
        return AppColors.doneColumn;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildMetaInfo(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          'Created ${_formatDate(task.createdAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

