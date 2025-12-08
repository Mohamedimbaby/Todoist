import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/time_formatter.dart';
import '../../cubits/timer/timer_cubit.dart';
import '../../cubits/timer/timer_state.dart';

/// Timer controls widget for task detail page
class TaskTimerControls extends StatelessWidget {
  final String taskId;

  const TaskTimerControls({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        final isRunning = _isRunning(state);
        final seconds = _getSeconds(state);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildTimerDisplay(seconds),
                const SizedBox(height: 24),
                _buildControls(context, isRunning),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerDisplay(int seconds) {
    return Text(
      TimeFormatter.formatSeconds(seconds),
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildControls(BuildContext context, bool isRunning) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton.large(
          heroTag: 'timer_button',
          onPressed: () => _toggleTimer(context, isRunning),
          backgroundColor: isRunning ? AppColors.error : AppColors.accent,
          child: Icon(isRunning ? Icons.stop : Icons.play_arrow, size: 36),
        ),
      ],
    );
  }

  void _toggleTimer(BuildContext context, bool isRunning) {
    if (isRunning) {
      context.read<TimerCubit>().stopTimer(taskId);
    } else {
      context.read<TimerCubit>().startTimer(taskId);
    }
  }

  bool _isRunning(TimerState state) {
    if (state is TimerLoaded) {
      return state.runningTimer?.taskId == taskId;
    }
    if (state is TimerTicking) {
      return state.taskId == taskId;
    }
    return false;
  }

  int _getSeconds(TimerState state) {
    if (state is TimerTicking && state.taskId == taskId) {
      return state.elapsedSeconds;
    }
    if (state is TimerLoaded) {
      return state.timersByTaskId[taskId]?.currentElapsedSeconds ?? 0;
    }
    return 0;
  }
}

