/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'TaskTime';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String tasksBox = 'tasks_box';
  static const String commentsBox = 'comments_box';
  static const String timersBox = 'timers_box';
  static const String historyBox = 'history_box';
  static const String syncQueueBox = 'sync_queue_box';
  static const String settingsBox = 'settings_box';
  static const String projectsBox = 'projects_box';

  // Default Kanban Columns
  static const String columnTodo = 'To Do';
  static const String columnInProgress = 'In Progress';
  static const String columnDone = 'Done';

  static const List<String> defaultColumns = [
    columnTodo,
    columnInProgress,
    columnDone,
  ];

  // Secure Storage Keys
  static const String todoistTokenKey = 'todoist_token';

  // Settings Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
}

