import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/providers/secure_storage_provider.dart';
import '../../../domain/usecases/sync_usecases.dart';
import '../../../di/api_injection.dart' as api_di;
import 'sync_state.dart';

/// Cubit for managing sync operations
class SyncCubit extends Cubit<SyncState> {
  final GetPendingSyncActionsUseCase _getPendingSyncActionsUseCase;
  final ExecuteSyncUseCase _executeSyncUseCase;
  final SecureStorageProvider _secureStorage;

  SyncCubit({
    required GetPendingSyncActionsUseCase getPendingSyncActionsUseCase,
    required ExecuteSyncUseCase executeSyncUseCase,
    HasPendingSyncUseCase? hasPendingSyncUseCase,
    GetSyncQueueCountUseCase? getSyncQueueCountUseCase,
    SecureStorageProvider? secureStorage,
  })  : _getPendingSyncActionsUseCase = getPendingSyncActionsUseCase,
        _executeSyncUseCase = executeSyncUseCase,
        _secureStorage = secureStorage ?? SecureStorageProvider(),
        super(const SyncInitial());

  /// Load sync queue status
  Future<void> loadSyncStatus() async {
    try {
      final actions = await _getPendingSyncActionsUseCase();
      final hasToken = await _secureStorage.hasTodoistToken();
      emit(SyncLoaded(pendingActions: actions, hasToken: hasToken));
    } catch (e) {
      emit(SyncError(e.toString()));
    }
  }

  /// Execute sync queue
  Future<void> syncNow() async {
    final current = state;
    if (current is! SyncLoaded) return;

    try {
      final hasToken = await _secureStorage.hasTodoistToken();
      if (!hasToken) {
        emit(const SyncError('No Todoist token configured'));
        return;
      }

      final token = await _secureStorage.getTodoistToken();
      if (token == null) return;

      api_di.initializeApiProviders(token);
      final total = current.pendingCount;
      emit(SyncInProgress(total: total, completed: 0));

      await _executeSyncUseCase();

      final remaining = await _getPendingSyncActionsUseCase();
      emit(SyncCompleted(
        syncedCount: total - remaining.length,
        failedCount: remaining.length,
      ));

      await loadSyncStatus();
    } catch (e) {
      emit(SyncError(e.toString()));
      await loadSyncStatus();
    }
  }

  /// Save Todoist token
  Future<void> saveToken(String token) async {
    await _secureStorage.saveTodoistToken(token);
    api_di.initializeApiProviders(token);
    await loadSyncStatus();
  }

  /// Remove Todoist token
  Future<void> removeToken() async {
    await _secureStorage.deleteTodoistToken();
    api_di.removeApiProviders();
    await loadSyncStatus();
  }

  /// Clear sync queue - just reload status
  Future<void> clearQueue() async {
    // TODO: Implement clear queue use case
    await loadSyncStatus();
  }
}
