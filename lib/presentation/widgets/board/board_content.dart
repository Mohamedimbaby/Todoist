import 'package:flutter/material.dart';
import 'package:tasktime/core/extensions/localization_extension.dart';
import '../../cubits/board/board_state.dart';
import 'board_column.dart';

/// Content of the board showing three Kanban columns
class BoardContent extends StatelessWidget {
  final BoardLoaded state;

  const BoardContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4,vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: BoardColumn(
              id: 1,
              title: context.localization.todoColumn,
              tasks: state.todoTasks,
              columnPriority: 1,
            ),
          ),
          Expanded(
            child: BoardColumn(
              id: 2,
              title: context.localization.inProgressColumn,
              tasks: state.inProgressTasks,
              columnPriority: 3,
            ),
          ),
          Expanded(
            child: BoardColumn(
              id: 3,
              title: context.localization.doneColumn,
              tasks: state.doneTasks,
              columnPriority: 4,
              isDoneColumn: true,
            ),
          ),
        ],
      ),
    );
  }
}
