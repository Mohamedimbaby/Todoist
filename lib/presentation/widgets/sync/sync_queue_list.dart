import 'package:flutter/material.dart';
import '../../../domain/entities/sync_action_entity.dart';
import 'sync_action_item.dart';

/// List of pending sync actions
class SyncQueueList extends StatelessWidget {
  final List<SyncActionEntity> actions;

  const SyncQueueList({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pending Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                SyncActionItem(action: actions[index]),
          ),
        ],
      ),
    );
  }
}

