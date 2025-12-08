import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Summary card for history page
class HistorySummary extends StatelessWidget {
  final String totalTime;
  final int completedCount;

  const HistorySummary({
    super.key,
    required this.totalTime,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStat(
              context,
              icon: Icons.check_circle,
              label: 'Completed',
              value: '$completedCount',
              color: AppColors.doneColumn,
            ),
            const SizedBox(width: 32),
            _buildStat(
              context,
              icon: Icons.timer,
              label: 'Total Time',
              value: totalTime,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

