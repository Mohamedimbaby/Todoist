import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasktime/core/extensions/localization_extension.dart';
import '../../cubits/project/project_cubit.dart';

/// Dialog for creating a new Todoist project
class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(context.localization.newProject),
      content: TextField(
        controller: _controller,
        decoration:  InputDecoration(
          labelText:context.localization.projectName,
          hintText: context.localization.enterProjectName,
        ),
        autofocus: true,
        enabled: !_isLoading,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child:  Text(context.localization.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createProject,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              :  Text(context.localization.create),
        ),
      ],
    );
  }

  Future<void> _createProject() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    await context.read<ProjectCubit>().createProject(_controller.text);

    if (mounted) {
      context.pop();
    }
  }
}
