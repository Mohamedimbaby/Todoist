import '../entities/sync_action_entity.dart';

/// Abstract sync repository interface
abstract class SyncRepository {
  /// Get all pending sync actions
  Future<List<SyncActionEntity>> getPendingSyncActions();

  /// Add a sync action to the queue
  Future<void> addSyncAction(SyncActionEntity action);

  /// Remove a sync action from the queue
  Future<void> removeSyncAction(String id);

  /// Update sync action (e.g., increment retry count)
  Future<void> updateSyncAction(SyncActionEntity action);

  /// Clear all sync actions
  Future<void> clearSyncQueue();

  /// Get sync action count
  Future<int> getSyncActionCount();

  /// Execute all pending sync actions
  Future<void> executeSyncQueue();

  /// Check if there are pending sync actions
  Future<bool> hasPendingSyncActions();
}

