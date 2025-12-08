import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasktime/core/extensions/localization_extension.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../cubits/comments/comments_cubit.dart';

/// Single comment item widget
class CommentItem extends StatelessWidget {
  final CommentEntity comment;

  const CommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentAvatar(isSynced: comment.isSynced),
          const SizedBox(width: 12),
          Expanded(
            child: _CommentContent(comment: comment),
          ),
          _CommentActions(comment: comment),
        ],
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  final bool isSynced;

  const _CommentAvatar({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 20, color: Colors.grey),
        ),
        if (!isSynced)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentContent extends StatelessWidget {
  final CommentEntity comment;

  const _CommentContent({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentHeader(comment: comment),
        const SizedBox(height: 4),
        _CommentText(content: comment.content),
        if (comment.attachment != null) ...[
          const SizedBox(height: 8),
          _CommentAttachment(attachment: comment.attachment!),
        ],
      ],
    );
  }
}

class _CommentHeader extends StatelessWidget {
  final CommentEntity comment;

  const _CommentHeader({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'You',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDate(comment.postedAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CommentText extends StatelessWidget {
  final String content;

  const _CommentText({required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class _CommentAttachment extends StatelessWidget {
  final String attachment;

  const _CommentAttachment({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attachment, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              attachment,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentActions extends StatelessWidget {
  final CommentEntity comment;

  const _CommentActions({required this.comment});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[400]),
      onSelected: (value) {
        if (value == 'delete') {
          _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.localization.deleteComment),
        content: Text(context.localization.deleteCommentQuestion),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(context.localization.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ctx.pop();
              context.read<CommentsCubit>().deleteComment(comment.id);
            },
            child: Text(
              context.localization.delete,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

