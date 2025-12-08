import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasktime/core/extensions/localization_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/time_formatter.dart';
import '../../cubits/timer/timer_cubit.dart';
import '../../cubits/timer/timer_state.dart';

/// Section displaying timer controls for a task
class TaskTimerSection extends StatelessWidget {
  final String taskId;
  final String currentColumn;
  final VoidCallback? onTimerStart;

  const TaskTimerSection({
    super.key,
    required this.taskId,
    required this.currentColumn,
    this.onTimerStart,
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
            _TimerContent(
              taskId: taskId,
              currentColumn: currentColumn,
              onTimerStart: onTimerStart,
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
        const Icon(Icons.timer, size: 20),
        const SizedBox(width: 8),
        Text(
          context.localization.timeTracker,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _TimerContent extends StatelessWidget {
  final String taskId;
  final String currentColumn;
  final VoidCallback? onTimerStart;

  const _TimerContent({
    required this.taskId,
    required this.currentColumn,
    this.onTimerStart,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        final isRunning = _isTimerRunning(state);
        final seconds = _getElapsedSeconds(state);

        return Row(
          children: [
            _TimerDisplay(seconds: seconds, isRunning: isRunning),
            const Spacer(),
            _TimerControls(
              taskId: taskId,
              isRunning: isRunning,
              onTimerStart: onTimerStart,
            ),
          ],
        );
      },
    );
  }

  bool _isTimerRunning(TimerState state) {
    if (state is TimerLoaded) {
      return state.runningTimer?.taskId == taskId;
    }
    if (state is TimerTicking) {
      return state.taskId == taskId;
    }
    return false;
  }

  int _getElapsedSeconds(TimerState state) {
    if (state is TimerTicking && state.taskId == taskId) {
      return state.elapsedSeconds;
    }
    if (state is TimerLoaded) {
      return state.timersByTaskId[taskId]?.currentElapsedSeconds ?? 0;
    }
    return 0;
  }
}

class _TimerDisplay extends StatelessWidget {
  final int seconds;
  final bool isRunning;

  const _TimerDisplay({required this.seconds, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isRunning
            ? AppColors.accent.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        TimeFormatter.formatSeconds(seconds),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          color: isRunning ? AppColors.accent : Colors.grey,
        ),
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  final String taskId;
  final bool isRunning;
  final VoidCallback? onTimerStart;

  const _TimerControls({
    required this.taskId,
    required this.isRunning,
    this.onTimerStart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlayPauseButton(
          taskId: taskId,
          isRunning: isRunning,
          onTimerStart: onTimerStart,
        ),
        const SizedBox(width: 8),
        _StopButton(taskId: taskId, isRunning: isRunning),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final String taskId;
  final bool isRunning;
  final VoidCallback? onTimerStart;

  const _PlayPauseButton({
    required this.taskId,
    required this.isRunning,
    this.onTimerStart,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: () {
        if (isRunning) {
          context.read<TimerCubit>().stopTimer(taskId);
        } else {
          context.read<TimerCubit>().startTimer(taskId);
          // Trigger callback to move task to In Progress
          onTimerStart?.call();
        }
      },
      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
      style: IconButton.styleFrom(
        backgroundColor: isRunning ? Colors.orange : AppColors.accent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  final String taskId;
  final bool isRunning;

  const _StopButton({required this.taskId, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: isRunning
          ? () => context.read<TimerCubit>().stopTimer(taskId)
          : null,
      icon: const Icon(Icons.stop),
    );
  }
}
