import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/board/board_cubit.dart';

/// Dialog for adding a new task to the board
class AddBoardTaskDialog extends StatefulWidget {
  const AddBoardTaskDialog({super.key});

  @override
  State<AddBoardTaskDialog> createState() => _AddBoardTaskDialogState();
}

class _AddBoardTaskDialogState extends State<AddBoardTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'What needs to be done?',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
              autofocus: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add more details',
              ),
              maxLines: 2,
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await context.read<BoardCubit>().addTask(
          _contentController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );

    if (mounted) {
      context.pop();
    }
  }
}
