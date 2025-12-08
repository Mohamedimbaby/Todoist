import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/history_entity.dart';
import '../../../domain/entities/project_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/board_repository.dart';
import '../../../domain/usecases/history_usecases.dart';
import '../../../domain/usecases/timer_usecases.dart';
import '../../../data/services/sync_service.dart';
import 'board_state.dart';

/// Cubit for managing the Kanban board - LOCAL FIRST with cache expiration
class BoardCubit extends Cubit<BoardState> {
  final BoardRepository _boardRepository;
  final CreateHistoryRecordUseCase _createHistoryRecordUseCase;
  final GetTimerForTaskUseCase _getTimerForTaskUseCase;
  final SyncService _syncService;

  ProjectEntity? _project;
  bool _isFirstLoad = true;

  BoardCubit({
    required BoardRepository boardRepository,
    required CreateHistoryRecordUseCase createHistoryRecordUseCase,
    required GetTimerForTaskUseCase getTimerForTaskUseCase,
    required SyncService syncService,
  })  : _boardRepository = boardRepository,
        _createHistoryRecordUseCase = createHistoryRecordUseCase,
        _getTimerForTaskUseCase = getTimerForTaskUseCase,
        _syncService = syncService,
        super(const BoardInitial());

  void setProject(ProjectEntity value) {
    _project = value;
    _isFirstLoad = true;
  }

  /// Load tasks with cache expiration check
  Future<void> loadTasks() async {
    if (_project == null) {
      emit(const BoardError('No project selected'));
      return;
    }

    if (state is BoardInitial || _isFirstLoad) {
      emit(const BoardLoading());
    }

    try {
      final localTasks =
          await _boardRepository.getTasksForProject(_project!.id);
      final hasPending = await _boardRepository.hasPendingSyncActions();
      final isExpired = await _boardRepository.isCacheExpired(_project!.id);

      // Decide whether to fetch from API
      final shouldFetchFromApi = _isFirstLoad && localTasks.isEmpty ||
          (isExpired && !hasPending);

      if (shouldFetchFromApi) {
        await _fetchAndSaveFromApi();
        _isFirstLoad = false;
        return;
      }

      // If expired but has pending sync, show warning
      if (isExpired && hasPending) {
        _isFirstLoad = false;
        final pendingCount = await _boardRepository.getPendingSyncCount();
        _emitLoadedState(localTasks, pendingCount);
        
        // Show cache expired warning
        final currentState = state;
        if (currentState is BoardLoaded) {
          emit(currentState.copyWith(
            operationMessage: 'Data may be outdated. Sync to refresh.',
          ));
          await Future.delayed(const Duration(seconds: 3));
          emit(currentState.copyWith(clearMessage: true));
        }
        return;
      }

      _isFirstLoad = false;
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(localTasks, pendingCount);

      _trySyncInBackground();
    } catch (e) {
      emit(BoardError(e.toString()));
    }
  }

  /// Fetch tasks from API and save to local storage
  Future<void> _fetchAndSaveFromApi() async {
    final result = await _syncService.fetchTasksFromApi(_project!.id);

    if (result.success) {
      await _boardRepository.saveTasksFromApi(result.tasks);
      await _boardRepository.updateLastFetchTime(_project!.id);
      
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
    } else {
      // API failed - try to use local data if available
      final localTasks =
          await _boardRepository.getTasksForProject(_project!.id);
      if (localTasks.isNotEmpty) {
        final pendingCount = await _boardRepository.getPendingSyncCount();
        _emitLoadedState(localTasks, pendingCount);
        _showError('Could not refresh: ${result.message}');
      } else {
        emit(BoardError(result.message));
      }
    }
  }

  /// Pull to refresh - fetch from API if no pending sync
  Future<void> refresh() async {
    if (_project == null) return;

    final hasPending = await _boardRepository.hasPendingSyncActions();
    if (hasPending) {
      final currentState = state;
      if (currentState is BoardLoaded) {
        emit(BoardRefreshBlocked(
          message:
              'Cannot refresh. You have unsynced changes. Please sync first.',
          currentState: currentState,
        ));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
      }
      return;
    }

    _showOperationMessage('Refreshing...');

    final result = await _syncService.fetchTasksFromApi(_project!.id);
    if (result.success) {
      await _boardRepository.saveTasksFromApi(result.tasks);
      await _boardRepository.updateLastFetchTime(_project!.id);
      
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
    } else {
      _clearOperationMessage();
      final currentState = state;
      if (currentState is BoardLoaded) {
        emit(BoardError(result.message, previousState: currentState));
      }
    }
  }

  Future<void> addTask(String content, {String? description}) async {
    if (_project == null) return;

    _showOperationMessage('Adding task...');
    String newTaskId = const Uuid().v4();
    try {
      final task = TaskEntity(
        id: newTaskId,
        content: content,
        description: description ?? '',
        column: AppConstants.columnTodo,
        priority: 1,
        projectId: _project!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await _boardRepository.createTask(task);
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
      _trySyncInBackground();
    } catch (e) {
      _showError('Failed to add task: $e');
    }
  }

  Future<void> moveTask(String taskId, int newPriority,
      {bool fromDoneColumn = false}) async {
    final currentState = state;
    if (currentState is! BoardLoaded) return;

    final allTasks = currentState.allTasks;
    final task = allTasks.firstWhere((t) => t.id == taskId);

    final updatedTask = task.copyWith(
      priority: newPriority,
      column: newPriority <= 2
          ? AppConstants.columnTodo
          : AppConstants.columnInProgress,
    );

    _emitOptimisticUpdate(currentState, task, updatedTask);

    try {
      if (fromDoneColumn) {
        await _boardRepository.reopenTask(taskId, newPriority);
      } else {
        await _boardRepository.updateTaskPriority(taskId, newPriority);
      }
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
      _trySyncInBackground();
    } catch (e) {
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
      _showError('Failed to move task');
    }
  }

  Future<void> moveToInProgress(String taskId) async {
    await moveTask(taskId, 3);
  }

  Future<void> completeTask(TaskEntity taskToComplete) async {
    final currentState = state;
    if (currentState is! BoardLoaded) return;

    final completedTask = taskToComplete.copyWith(
      column: AppConstants.columnDone,
    );
    _emitOptimisticUpdate(currentState, taskToComplete, completedTask);

    try {
      final timerEntity =
          await _getTimerForTaskUseCase(taskToComplete.id);
      await _createHistoryRecordUseCase(HistoryEntity(
        id: '',
        taskId: taskToComplete.id,
        taskContent: taskToComplete.content,
        totalTrackedSeconds: timerEntity?.accumulatedSeconds ?? 0,
        completedAt: DateTime.now(),
      ));

      await _boardRepository.completeTask(taskToComplete.id);
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
      _trySyncInBackground();
    } catch (e) {
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
      _showError('Failed to complete task');
    }
  }

  Future<void> deleteTask(String taskId) async {
    _showOperationMessage('Deleting...');

    try {
      await _boardRepository.deleteTask(taskId);
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
      _trySyncInBackground();
    } catch (e) {
      _showError('Failed to delete task');
    }
  }

  Future<void> _trySyncInBackground() async {
    final result = await _syncService.syncNow();
    if (result.syncedCount > 0) {
      final pendingCount = await _boardRepository.getPendingSyncCount();
      final currentState = state;
      if (currentState is BoardLoaded) {
        emit(currentState.copyWith(pendingSyncCount: pendingCount));
      }
    }
  }

  Future<void> syncNow() async {
    _showOperationMessage('Syncing...');
    final result = await _syncService.syncNow();
    _clearOperationMessage();

    if (!result.success) {
      _showError(result.message);
    } else {
      final tasks = await _boardRepository.getTasksForProject(_project!.id);
      final pendingCount = await _boardRepository.getPendingSyncCount();
      _emitLoadedState(tasks, pendingCount);
    }
  }

  void _emitLoadedState(List<TaskEntity> tasks, int pendingCount) {
    final todoTasks =
        tasks.where((t) => t.column == AppConstants.columnTodo).toList();
    final inProgressTasks =
        tasks.where((t) => t.column == AppConstants.columnInProgress).toList();
    final doneTasks =
        tasks.where((t) => t.column == AppConstants.columnDone).toList();

    emit(BoardLoaded(
      project: _project!,
      todoTasks: todoTasks,
      inProgressTasks: inProgressTasks,
      doneTasks: doneTasks,
      pendingSyncCount: pendingCount,
    ));
  }

  void _emitOptimisticUpdate(
    BoardLoaded currentState,
    TaskEntity oldTask,
    TaskEntity newTask,
  ) {
    var todoTasks = List<TaskEntity>.from(currentState.todoTasks);
    var inProgressTasks = List<TaskEntity>.from(currentState.inProgressTasks);
    var doneTasks = List<TaskEntity>.from(currentState.doneTasks);

    todoTasks.removeWhere((t) => t.id == oldTask.id);
    inProgressTasks.removeWhere((t) => t.id == oldTask.id);
    doneTasks.removeWhere((t) => t.id == oldTask.id);

    if (newTask.column == AppConstants.columnTodo) {
      todoTasks.add(newTask);
    } else if (newTask.column == AppConstants.columnInProgress) {
      inProgressTasks.add(newTask);
    } else {
      doneTasks.add(newTask);
    }

    emit(currentState.copyWith(
      todoTasks: todoTasks,
      inProgressTasks: inProgressTasks,
      doneTasks: doneTasks,
    ));
  }

  void _showOperationMessage(String message) {
    final currentState = state;
    if (currentState is BoardLoaded) {
      emit(currentState.copyWith(operationMessage: message));
    }
  }

  void _clearOperationMessage() {
    final currentState = state;
    if (currentState is BoardLoaded) {
      emit(currentState.copyWith(clearMessage: true));
    }
  }

  void _showError(String message) {
    final currentState = state;
    if (currentState is BoardLoaded) {
      emit(BoardError(message, previousState: currentState));
    } else {
      emit(BoardError(message));
    }
  }
}
