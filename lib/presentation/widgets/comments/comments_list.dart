import 'package:flutter/material.dart';
import 'package:tasktime/core/extensions/localization_extension.dart';
import '../../../domain/entities/comment_entity.dart';
import 'comment_item.dart';

/// List of comments
class CommentsList extends StatelessWidget {
  final List<CommentEntity> comments;

  const CommentsList({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const _EmptyComments();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => CommentItem(comment: comments[index]),
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              context.localization.noCommentsYet,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Text(
              context.localization.addCommentAbove,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

