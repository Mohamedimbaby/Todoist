/// Application configuration
/// 
/// For development/testing, you can set the default token here.
/// In production, users should enter their token via Settings → Sync.
class AppConfig {
  AppConfig._();

  /// Default Todoist API token for development/testing
  /// Set via: flutter run --dart-define=TODOIST_TOKEN=your_token
  static const String defaultTodoistToken = String.fromEnvironment(
    'TODOIST_TOKEN',
    defaultValue: '',
  );

  /// Check if a default token is configured
  static bool get hasDefaultToken => defaultTodoistToken.isNotEmpty;
}
