import 'package:flutter/material.dart';
import '../../../domain/entities/history_entity.dart';
import '../../../core/theme/app_colors.dart';

/// Single history item widget
class HistoryItem extends StatelessWidget {
  final HistoryEntity record;

  const HistoryItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.doneColumn,
          child: Icon(Icons.check, color: Colors.white),
        ),
        title: Text(
          record.taskContent,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatDate(record.completedAt)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            record.formattedTime,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

