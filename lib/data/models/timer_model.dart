import 'package:hive/hive.dart';
import '../../domain/entities/timer_entity.dart';

part 'timer_model.g.dart';

@HiveType(typeId: 1)
class TimerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final DateTime? startTimestamp;

  @HiveField(3)
  final int accumulatedSeconds;

  @HiveField(4)
  final bool isRunning;

  TimerModel({
    required this.id,
    required this.taskId,
    this.startTimestamp,
    this.accumulatedSeconds = 0,
    this.isRunning = false,
  });

  factory TimerModel.fromEntity(TimerEntity entity) {
    return TimerModel(
      id: entity.id,
      taskId: entity.taskId,
      startTimestamp: entity.startTimestamp,
      accumulatedSeconds: entity.accumulatedSeconds,
      isRunning: entity.isRunning,
    );
  }

  TimerEntity toEntity() {
    return TimerEntity(
      id: id,
      taskId: taskId,
      startTimestamp: startTimestamp,
      accumulatedSeconds: accumulatedSeconds,
      isRunning: isRunning,
    );
  }
}

