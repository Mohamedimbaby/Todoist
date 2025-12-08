import 'package:equatable/equatable.dart';

/// History record entity for completed tasks
class HistoryEntity extends Equatable {
  final String id;
  final String taskId;
  final String taskContent;
  final int totalTrackedSeconds;
  final DateTime completedAt;
  final String? projectId;

  const HistoryEntity({
    required this.id,
    required this.taskId,
    required this.taskContent,
    required this.totalTrackedSeconds,
    required this.completedAt,
    this.projectId,
  });

  /// Format tracked time as HH:MM:SS
  String get formattedTime {
    final hours = totalTrackedSeconds ~/ 3600;
    final minutes = (totalTrackedSeconds % 3600) ~/ 60;
    final seconds = totalTrackedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        taskContent,
        totalTrackedSeconds,
        completedAt,
        projectId,
      ];
}

