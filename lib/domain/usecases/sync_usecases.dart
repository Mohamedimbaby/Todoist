import '../entities/sync_action_entity.dart';
import '../repositories/sync_repository.dart';

/// Use case for executing sync queue
class ExecuteSyncUseCase {
  final SyncRepository _repository;

  ExecuteSyncUseCase(this._repository);

  Future<void> call() => _repository.executeSyncQueue();
}

/// Use case for getting pending sync actions
class GetPendingSyncActionsUseCase {
  final SyncRepository _repository;

  GetPendingSyncActionsUseCase(this._repository);

  Future<List<SyncActionEntity>> call() => _repository.getPendingSyncActions();
}

/// Use case for adding a sync action
class AddSyncActionUseCase {
  final SyncRepository _repository;

  AddSyncActionUseCase(this._repository);

  Future<void> call(SyncActionEntity action) =>
      _repository.addSyncAction(action);
}

/// Use case for removing a sync action
class RemoveSyncActionUseCase {
  final SyncRepository _repository;

  RemoveSyncActionUseCase(this._repository);

  Future<void> call(String id) => _repository.removeSyncAction(id);
}

/// Use case for checking if sync is needed
class HasPendingSyncUseCase {
  final SyncRepository _repository;

  HasPendingSyncUseCase(this._repository);

  Future<bool> call() => _repository.hasPendingSyncActions();
}

/// Use case for getting sync queue count
class GetSyncQueueCountUseCase {
  final SyncRepository _repository;

  GetSyncQueueCountUseCase(this._repository);

  Future<int> call() => _repository.getSyncActionCount();
}

