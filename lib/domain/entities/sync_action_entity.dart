import 'package:equatable/equatable.dart';

/// Types of sync actions
enum SyncActionType {
  createTask,
  updateTask,
  deleteTask,
  completeTask,
  createProject,
  deleteProject,
  createComment,
  updateComment,
  deleteComment,
}

/// Sync action entity for offline queue
class SyncActionEntity extends Equatable {
  final String id;
  final SyncActionType type;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? errorMessage;

  const SyncActionEntity({
    required this.id,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.errorMessage,
  });

  SyncActionEntity copyWith({
    String? id,
    SyncActionType? type,
    String? entityId,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    String? errorMessage,
  }) {
    return SyncActionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        entityId,
        payload,
        createdAt,
        retryCount,
        errorMessage,
      ];
}

