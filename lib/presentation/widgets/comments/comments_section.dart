import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasktime/core/extensions/localization_extension.dart';
import '../../cubits/comments/comments_cubit.dart';
import '../../cubits/comments/comments_state.dart';
import 'comments_list.dart';
import 'comment_input.dart';

/// Section displaying comments for a task
class CommentsSection extends StatelessWidget {
  final String taskId;
  final String? projectId;

  const CommentsSection({
    super.key,
    required this.taskId,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(),
            const SizedBox(height: 12),
            CommentInput(taskId: taskId, projectId: projectId),
            const SizedBox(height: 16),
            BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const _LoadingIndicator();
                }
                if (state is CommentsLoaded) {
                  return CommentsList(comments: state.comments);
                }
                if (state is CommentsRefreshBlocked) {
                  return CommentsList(comments: state.currentState.comments);
                }
                if (state is CommentsError && state.previousState != null) {
                  return CommentsList(
                      comments: state.previousState!.comments);
                }
                return const _EmptyState();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.comment, size: 20),
        const SizedBox(width: 8),
        Text(
          context.localization.comments,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No comments yet',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}

