import 'package:equatable/equatable.dart';
import '../../../domain/entities/sync_action_entity.dart';

/// States for SyncCubit
abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// Sync queue loaded
class SyncLoaded extends SyncState {
  final List<SyncActionEntity> pendingActions;
  final bool isSyncing;
  final bool hasToken;

  const SyncLoaded({
    required this.pendingActions,
    this.isSyncing = false,
    this.hasToken = false,
  });

  int get pendingCount => pendingActions.length;

  @override
  List<Object?> get props => [pendingActions, isSyncing, hasToken];
}

/// Sync in progress
class SyncInProgress extends SyncState {
  final int total;
  final int completed;

  const SyncInProgress({required this.total, required this.completed});

  @override
  List<Object?> get props => [total, completed];
}

/// Sync completed
class SyncCompleted extends SyncState {
  final int syncedCount;
  final int failedCount;

  const SyncCompleted({required this.syncedCount, required this.failedCount});

  @override
  List<Object?> get props => [syncedCount, failedCount];
}

/// Sync error
class SyncError extends SyncState {
  final String message;

  const SyncError(this.message);

  @override
  List<Object?> get props => [message];
}

