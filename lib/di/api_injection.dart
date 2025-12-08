import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../data/providers/todoist_api_provider.dart';
import '../data/providers/todoist_task_provider.dart';

final getIt = GetIt.instance;

/// Initialize API providers with the user's Todoist token
void initializeApiProviders(String token) {
  final dio = getIt<Dio>();

  // Register or re-register API providers
  if (getIt.isRegistered<TodoistApiProvider>()) {
    getIt.unregister<TodoistApiProvider>();
  }
  if (getIt.isRegistered<TodoistTaskProvider>()) {
    getIt.unregister<TodoistTaskProvider>();
  }

  getIt.registerLazySingleton<TodoistApiProvider>(
    () => TodoistApiProvider(dio: dio, token: token),
  );

  getIt.registerLazySingleton<TodoistTaskProvider>(
    () => TodoistTaskProvider(dio: dio, token: token),
  );
}

/// Remove API providers (when user logs out or removes token)
void removeApiProviders() {
  if (getIt.isRegistered<TodoistApiProvider>()) {
    getIt.unregister<TodoistApiProvider>();
  }
  if (getIt.isRegistered<TodoistTaskProvider>()) {
    getIt.unregister<TodoistTaskProvider>();
  }
}

