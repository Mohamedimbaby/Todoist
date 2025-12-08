import 'package:hive/hive.dart';
import '../../domain/entities/history_entity.dart';

part 'history_model.g.dart';

@HiveType(typeId: 3)
class HistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String taskContent;

  @HiveField(3)
  final int totalTrackedSeconds;

  @HiveField(4)
  final DateTime completedAt;

  @HiveField(5)
  final String? projectId;

  HistoryModel({
    required this.id,
    required this.taskId,
    required this.taskContent,
    required this.totalTrackedSeconds,
    required this.completedAt,
    this.projectId,
  });

  factory HistoryModel.fromEntity(HistoryEntity entity) {
    return HistoryModel(
      id: entity.id,
      taskId: entity.taskId,
      taskContent: entity.taskContent,
      totalTrackedSeconds: entity.totalTrackedSeconds,
      completedAt: entity.completedAt,
      projectId: entity.projectId,
    );
  }

  HistoryEntity toEntity() {
    return HistoryEntity(
      id: id,
      taskId: taskId,
      taskContent: taskContent,
      totalTrackedSeconds: totalTrackedSeconds,
      completedAt: completedAt,
      projectId: projectId,
    );
  }
}

