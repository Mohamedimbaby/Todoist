import 'package:flutter/material.dart';
import '../../../domain/entities/sync_action_entity.dart';
import '../../../core/theme/app_colors.dart';

/// Single sync action item widget
class SyncActionItem extends StatelessWidget {
  final SyncActionEntity action;

  const SyncActionItem({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIcon(),
      title: Text(_getActionTitle()),
      subtitle: action.errorMessage != null
          ? Text(
              action.errorMessage!,
              style: const TextStyle(color: AppColors.error),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text('Retries: ${action.retryCount}'),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;
    switch (action.type) {
      case SyncActionType.createTask:
        icon = Icons.add;
        color = AppColors.success;
        break;
      case SyncActionType.updateTask:
        icon = Icons.edit;
        color = AppColors.info;
        break;
      case SyncActionType.deleteTask:
        icon = Icons.delete;
        color = AppColors.error;
        break;
      case SyncActionType.completeTask:
        icon = Icons.check;
        color = AppColors.doneColumn;
        break;
      default:
        icon = Icons.sync;
        color = AppColors.primary;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.2),
      child: Icon(icon, color: color, size: 18),
    );
  }

  String _getActionTitle() {
    switch (action.type) {
      case SyncActionType.createTask:
        return 'Create Task';
      case SyncActionType.updateTask:
        return 'Update Task';
      case SyncActionType.deleteTask:
        return 'Delete Task';
      case SyncActionType.completeTask:
        return 'Complete Task';
      case SyncActionType.createProject:
        return 'Create Project';
      case SyncActionType.deleteProject:
        return 'Delete Project';
      case SyncActionType.createComment:
        return 'Create Comment';
      case SyncActionType.updateComment:
        return 'Update Comment';
      case SyncActionType.deleteComment:
        return 'Delete Comment';
    }
  }
}

