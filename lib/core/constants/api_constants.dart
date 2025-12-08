/// API-related constants for Todoist integration
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.todoist.com/rest/v2';

  // Endpoints
  static const String projects = '/projects';
  static const String tasks = '/tasks';
  static const String comments = '/comments';

  // Headers
  static const String authorization = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String requestId = 'X-Request-Id';

  // Values
  static const String bearerPrefix = 'Bearer';
  static const String jsonContentType = 'application/json';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Retry settings
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;
}

