import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../data/models/task_model.dart';
import '../data/models/timer_model.dart';
import '../data/models/comment_model.dart';
import '../data/models/history_model.dart';
import '../data/models/project_model.dart';
import '../data/models/sync_action_model.dart';
import '../data/providers/secure_storage_provider.dart';
import '../data/providers/todoist_task_provider.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/repositories/timer_repository_impl.dart';
import '../data/repositories/history_repository_impl.dart';
import '../data/repositories/project_repository_impl.dart';
import '../data/repositories/sync_repository_impl.dart';
import '../data/repositories/board_repository_impl.dart';
import '../data/repositories/comments_repository_impl.dart';
import '../data/services/sync_service.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/timer_repository.dart';
import '../domain/repositories/history_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/sync_repository.dart';
import '../domain/repositories/board_repository.dart';
import '../domain/repositories/comments_repository.dart';
import '../domain/usecases/task_usecases.dart';
import '../domain/usecases/timer_usecases.dart';
import '../domain/usecases/history_usecases.dart';
import '../domain/usecases/sync_usecases.dart';
import '../domain/usecases/project_usecases.dart';
import '../presentation/cubits/board/board_cubit.dart';
import '../presentation/cubits/timer/timer_cubit.dart';
import '../presentation/cubits/sync/sync_cubit.dart';
import '../presentation/cubits/history/history_cubit.dart';
import '../presentation/cubits/comments/comments_cubit.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  await _initHive();
  _registerProviders();
  _registerRepositories();
  _registerServices();
  _registerUseCases();
  _registerCubits();
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TimerModelAdapter());
  Hive.registerAdapter(CommentModelAdapter());
  Hive.registerAdapter(HistoryModelAdapter());
  Hive.registerAdapter(ProjectModelAdapter());
  Hive.registerAdapter(SyncActionModelAdapter());

  final tasksBox = await Hive.openBox<TaskModel>(AppConstants.tasksBox);
  final timersBox = await Hive.openBox<TimerModel>(AppConstants.timersBox);
  final commentsBox =
      await Hive.openBox<CommentModel>(AppConstants.commentsBox);
  final historyBox =
      await Hive.openBox<HistoryModel>(AppConstants.historyBox);
  final projectsBox =
      await Hive.openBox<ProjectModel>(AppConstants.projectsBox);
  final syncBox =
      await Hive.openBox<SyncActionModel>(AppConstants.syncQueueBox);

  getIt.registerSingleton<Box<TaskModel>>(tasksBox);
  getIt.registerSingleton<Box<TimerModel>>(timersBox);
  getIt.registerSingleton<Box<CommentModel>>(commentsBox);
  getIt.registerSingleton<Box<HistoryModel>>(historyBox);
  getIt.registerSingleton<Box<ProjectModel>>(projectsBox);
  getIt.registerSingleton<Box<SyncActionModel>>(syncBox);
}

void _registerProviders() {
  getIt.registerLazySingleton<SecureStorageProvider>(
    () => SecureStorageProvider(),
  );

  getIt.registerLazySingleton<Dio>(() => Dio());

  getIt.registerLazySingleton<TodoistTaskProvider>(
    () => TodoistTaskProvider(
      dio: getIt<Dio>(),
      token: AppConfig.defaultTodoistToken,
    ),
  );
}

void _registerRepositories() {
  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(
      syncBox: getIt<Box<SyncActionModel>>(),
      taskProvider: getIt<TodoistTaskProvider>(),
      taskBox: getIt<Box<TaskModel>>(),
      commentsBox: getIt<Box<CommentModel>>(),
    ),
  );

  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(tasksBox: getIt<Box<TaskModel>>()),
  );

  getIt.registerLazySingleton<TimerRepository>(
    () => TimerRepositoryImpl(timersBox: getIt<Box<TimerModel>>()),
  );

  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(historyBox: getIt<Box<HistoryModel>>()),
  );

  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(projectsBox: getIt<Box<ProjectModel>>()),
  );

  getIt.registerLazySingleton<BoardRepository>(
    () => BoardRepositoryImpl(
      tasksBox: getIt<Box<TaskModel>>(),
      syncRepository: getIt<SyncRepository>(),
    ),
  );

  getIt.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(
      commentsBox: getIt<Box<CommentModel>>(),
      tasksBox: getIt<Box<TaskModel>>(),
      syncRepository: getIt<SyncRepository>(),
    ),
  );
}

void _registerServices() {
  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      syncRepository: getIt<SyncRepository>(),
      secureStorage: getIt<SecureStorageProvider>(),
      dio: getIt<Dio>(),
      tasksBox: getIt<Box<TaskModel>>(),
      commentsBox: getIt<Box<CommentModel>>(),
    ),
  );
}

void _registerUseCases() {
  // Task Use Cases
  getIt.registerLazySingleton(() => GetAllTasksUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTasksByColumnUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => MoveTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => CompleteTaskUseCase(getIt()));

  // Timer Use Cases
  getIt.registerLazySingleton(() => StartTimerUseCase(getIt()));
  getIt.registerLazySingleton(() => StopTimerUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTimerForTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRunningTimerUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTotalTrackedTimeUseCase(getIt()));

  // History Use Cases
  getIt.registerLazySingleton(() => GetAllHistoryUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateHistoryRecordUseCase(getIt()));
  getIt.registerLazySingleton(() => GetHistoryByDateRangeUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTotalHistoryTimeUseCase(getIt()));

  // Sync Use Cases
  getIt.registerLazySingleton(() => ExecuteSyncUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPendingSyncActionsUseCase(getIt()));
  getIt.registerLazySingleton(() => AddSyncActionUseCase(getIt()));
  getIt.registerLazySingleton(() => RemoveSyncActionUseCase(getIt()));
  getIt.registerLazySingleton(() => HasPendingSyncUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSyncQueueCountUseCase(getIt()));

  // Project Use Cases
  getIt.registerLazySingleton(() => GetAllProjectsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProjectByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveProjectUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteLocalProjectUseCase(getIt()));
  getIt.registerLazySingleton(() => FetchRemoteProjectsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateRemoteProjectUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteRemoteProjectUseCase(getIt()));
  getIt.registerLazySingleton(() => SyncProjectsUseCase(getIt()));
}

void _registerCubits() {
  getIt.registerFactory<BoardCubit>(
    () => BoardCubit(
      boardRepository: getIt(),
      createHistoryRecordUseCase: getIt(),
      getTimerForTaskUseCase: getIt(),
      syncService: getIt(),
    ),
  );

  getIt.registerFactory<CommentsCubit>(
    () => CommentsCubit(
      commentsRepository: getIt(),
      syncService: getIt(),
    ),
  );

  getIt.registerLazySingleton<TimerCubit>(
    () => TimerCubit(timerRepository: getIt()),
  );

  getIt.registerLazySingleton<SyncCubit>(
    () => SyncCubit(
      getPendingSyncActionsUseCase: getIt(),
      executeSyncUseCase: getIt(),
      secureStorage: getIt(),
    ),
  );

  getIt.registerLazySingleton<HistoryCubit>(
    () => HistoryCubit(
      getAllHistoryUseCase: getIt(),
      getTotalHistoryTimeUseCase: getIt(),
    ),
  );
}
