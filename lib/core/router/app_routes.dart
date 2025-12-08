/// Route path constants for the app
abstract class AppRoutes {
  // Projects
  static const String projects = '/';
  static const String sync = '/sync';
  
  // Board
  static const String board = '/board/:projectId';
  static String boardPath(String projectId) => '/board/$projectId';
  
  // Task Detail
  static const String taskDetail = '/task/:taskId';
  static String taskDetailPath(String taskId) => '/task/$taskId';
  
  // History
  static const String history = '/history';
  
  // Settings
  static const String settings = '/settings';
}

/// Route parameter keys
abstract class RouteParams {
  static const String projectId = 'projectId';
  static const String taskId = 'taskId';
}

/// Route extra data keys
abstract class RouteExtra {
  static const String project = 'project';
  static const String task = 'task';
  static const String boardCubit = 'boardCubit';
}

