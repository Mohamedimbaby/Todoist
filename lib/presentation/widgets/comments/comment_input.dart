import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/comments/comments_cubit.dart';

/// Input field for adding new comments
class CommentInput extends StatefulWidget {
  final String taskId;
  final String? projectId;

  const CommentInput({
    super.key,
    required this.taskId,
    this.projectId,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _submitComment() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    context.read<CommentsCubit>().addComment(
          content,
          projectId: widget.projectId,
        );

    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return _InputField(
      controller: _controller,
      focusNode: _focusNode,
      submitComment: _submitComment,
      hasText: _hasText,
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback submitComment;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.submitComment,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 1,
      style: TextStyle(
        color: AppColors.cardDark,
        height: 1.1
      ) ,
      textCapitalization: TextCapitalization.sentences,
      decoration:  InputDecoration(

        hintText: 'Add a comment...',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.cardDark,
            width: 1,
          ),

        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.cardDark,
            width: 1,
          ),

        ),
        hintStyle:  TextStyle(
        color: AppColors.cardDark,
      ),
        border: InputBorder.none,
        fillColor:  Colors.grey[100],
        filled: true,
        suffix: _SendButton(
          enabled: hasText,
          onPressed: submitComment,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _SendButton({
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child:  Icon(Icons.send,
      color: AppColors.accent,)

    );
  }
}

