import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/sync_action_entity.dart';

part 'sync_action_model.g.dart';

@HiveType(typeId: 5)
class SyncActionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int typeIndex;

  @HiveField(2)
  final String entityId;

  @HiveField(3)
  final String payloadJson;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int retryCount;

  @HiveField(6)
  final String? errorMessage;

  SyncActionModel({
    required this.id,
    required this.typeIndex,
    required this.entityId,
    required this.payloadJson,
    required this.createdAt,
    this.retryCount = 0,
    this.errorMessage,
  });

  factory SyncActionModel.fromEntity(SyncActionEntity entity) {
    return SyncActionModel(
      id: entity.id,
      typeIndex: entity.type.index,
      entityId: entity.entityId,
      payloadJson: jsonEncode(entity.payload),
      createdAt: entity.createdAt,
      retryCount: entity.retryCount,
      errorMessage: entity.errorMessage,
    );
  }

  SyncActionEntity toEntity() {
    return SyncActionEntity(
      id: id,
      type: SyncActionType.values[typeIndex],
      entityId: entityId,
      payload: jsonDecode(payloadJson) as Map<String, dynamic>,
      createdAt: createdAt,
      retryCount: retryCount,
      errorMessage: errorMessage,
    );
  }
}

