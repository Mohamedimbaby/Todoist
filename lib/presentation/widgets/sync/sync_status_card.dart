import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/sync/sync_cubit.dart';

/// Card showing sync status and actions
class SyncStatusCard extends StatelessWidget {
  final int pendingCount;
  final bool hasToken;

  const SyncStatusCard({
    super.key,
    required this.pendingCount,
    required this.hasToken,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  pendingCount > 0 ? Icons.cloud_upload : Icons.cloud_done,
                  color: pendingCount > 0 ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  pendingCount > 0
                      ? '$pendingCount pending actions'
                      : 'All synced',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasToken
                        ? () => context.read<SyncCubit>().syncNow()
                        : null,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed:
                      pendingCount > 0 ? () => _confirmClear(context) : null,
                  child: const Text('Clear Queue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Sync Queue'),
        content: const Text('This will discard all pending sync actions.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SyncCubit>().clearQueue();
              ctx.pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
