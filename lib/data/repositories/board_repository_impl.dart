import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/sync_action_entity.dart';
import '../../domain/repositories/board_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../models/task_model.dart';

/// Implementation of BoardRepository - local-first with sync queue
class BoardRepositoryImpl implements BoardRepository {
  final Box<TaskModel> _tasksBox;
  final SyncRepository _syncRepository;

  /// Cache expiration time in minutes
  static const int cacheExpirationMinutes = 60;

  /// Key prefix for storing last fetch time per project
  static const String _lastFetchPrefix = '_lastFetch_';

  BoardRepositoryImpl({
    required Box<TaskModel> tasksBox,
    required SyncRepository syncRepository,
  })  : _tasksBox = tasksBox,
        _syncRepository = syncRepository;

  @override
  Future<List<TaskEntity>> getTasksForProject(String projectId) async {
    return _tasksBox.values
        .where((t) => t.projectId == projectId)
        .map((t) => t.toEntity())
        .toList();
  }

  @override
  Future<bool> isCacheExpired(String projectId) async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    final lastFetch = box.get('$_lastFetchPrefix$projectId') as DateTime?;

    if (lastFetch == null) return true;

    final now = DateTime.now();
    final diff = now.difference(lastFetch).inMinutes;
    return diff >= cacheExpirationMinutes;
  }

  @override
  Future<void> updateLastFetchTime(String projectId) async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put('$_lastFetchPrefix$projectId', DateTime.now());
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    final id = task.id.isEmpty ? const Uuid().v4() : task.id;
    final now = DateTime.now();

    final newTask = task.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    await _tasksBox.put(id, TaskModel.fromEntity(newTask));

    await _syncRepository.addSyncAction(SyncActionEntity(
      id: const Uuid().v4(),
      type: SyncActionType.createTask,
      entityId: id,
      payload: {
        'content': newTask.content,
        'description': newTask.description,
        'project_id': newTask.projectId,
        'priority': newTask.priority,
        'id': newTask.id,
      },
      createdAt: now,
    ));

    return newTask;
  }

  @override
  Future<TaskEntity> updateTaskPriority(String taskId, int newPriority) async {
    final model = _tasksBox.get(taskId);
    if (model == null) throw Exception('Task not found');

    final now = DateTime.now();
    String newColumn;
    if (newPriority <= 2) {
      newColumn = AppConstants.columnTodo;
    } else {
      newColumn = AppConstants.columnInProgress;
    }

    final updated = model.toEntity().copyWith(
          priority: newPriority,
          column: newColumn,
          updatedAt: now,
          isSynced: false,
        );

    await _tasksBox.put(taskId, TaskModel.fromEntity(updated));

    await _syncRepository.addSyncAction(SyncActionEntity(
      id: const Uuid().v4(),
      type: SyncActionType.updateTask,
      entityId: model.todoistId ?? taskId,
      payload: {'priority': newPriority},
      createdAt: now,
    ));

    return updated;
  }

  @override
  Future<TaskEntity> completeTask(String taskId) async {
    final model = _tasksBox.get(taskId);
    if (model == null) throw Exception('Task not found');

    final now = DateTime.now();
    final completed = model.toEntity().copyWith(
          column: AppConstants.columnDone,
          updatedAt: now,
          isSynced: false,
        );

    await _tasksBox.put(taskId, TaskModel.fromEntity(completed));

    await _syncRepository.addSyncAction(SyncActionEntity(
      id: const Uuid().v4(),
      type: SyncActionType.completeTask,
      entityId: model.todoistId ?? taskId,
      payload: {},
      createdAt: now,
    ));

    return completed;
  }

  @override
  Future<TaskEntity> reopenTask(String taskId, int priority) async {
    final model = _tasksBox.get(taskId);
    if (model == null) throw Exception('Task not found');

    final now = DateTime.now();
    String newColumn =
        priority <= 2 ? AppConstants.columnTodo : AppConstants.columnInProgress;

    final reopened = model.toEntity().copyWith(
          column: newColumn,
          priority: priority,
          updatedAt: now,
          isSynced: false,
        );

    await _tasksBox.put(taskId, TaskModel.fromEntity(reopened));

    await _syncRepository.addSyncAction(SyncActionEntity(
      id: const Uuid().v4(),
      type: SyncActionType.updateTask,
      entityId: model.todoistId ?? taskId,
      payload: {'reopen': true},
      createdAt: now,
    ));

    await _syncRepository.addSyncAction(SyncActionEntity(
      id: const Uuid().v4(),
      type: SyncActionType.updateTask,
      entityId: model.todoistId ?? taskId,
      payload: {'priority': priority},
      createdAt: now,
    ));

    return reopened;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final model = _tasksBox.get(taskId);
    if (model == null) return;

    await _tasksBox.delete(taskId);

    if (model.todoistId != null) {
      await _syncRepository.addSyncAction(SyncActionEntity(
        id: const Uuid().v4(),
        type: SyncActionType.deleteTask,
        entityId: model.todoistId!,
        payload: {},
        createdAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> saveTasksFromApi(List<Map<String, dynamic>> apiTasks) async {
    for (final json in apiTasks) {
      final projectId = json['project_id']?.toString();
      final todoistId = json['id'].toString();

      final existing = _tasksBox.values
          .where((t) => t.todoistId == todoistId)
          .firstOrNull;

      final column = _getColumnFromPriority(json['priority'] as int? ?? 1);
      final task = TaskEntity(
        id: existing?.id ?? const Uuid().v4(),
        content: json['content'] as String,
        description: json['description'] as String? ?? '',
        column: column,
        priority: json['priority'] as int? ?? 1,
        projectId: projectId,
        todoistId: todoistId,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.now(),
        isSynced: true,
      );

      await _tasksBox.put(task.id, TaskModel.fromEntity(task));
    }
  }

  String _getColumnFromPriority(int priority) {
    if (priority <= 2) return AppConstants.columnTodo;
    return AppConstants.columnInProgress;
  }

  @override
  Future<bool> hasPendingSyncActions() async {
    return await _syncRepository.hasPendingSyncActions();
  }

  @override
  Future<int> getPendingSyncCount() async {
    return await _syncRepository.getSyncActionCount();
  }
}
