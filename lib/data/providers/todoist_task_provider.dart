import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';

/// Todoist Task API provider
class TodoistTaskProvider {
  final Dio _dio;
  final String _token;

  TodoistTaskProvider({required Dio dio, required String token})
      : _dio = dio,
        _token = token {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout =
        Duration(milliseconds: ApiConstants.connectTimeout);
    _dio.options.receiveTimeout =
        Duration(milliseconds: ApiConstants.receiveTimeout);
    _dio.options.headers = {
      ApiConstants.authorization: '${ApiConstants.bearerPrefix} $_token',
      ApiConstants.contentType: ApiConstants.jsonContentType,
    };
  }

  Map<String, String> get _requestHeaders => {
        ApiConstants.requestId: const Uuid().v4(),
      };

  /// Create a new task
  Future<Map<String, dynamic>> createTask({
    required String content,
    String? description,
    String? projectId,
    int? priority,
  }) async {
    try {
      final data = <String, dynamic>{'content': content};
      if (description != null) data['description'] = description;
      if (projectId != null) data['project_id'] = projectId;
      if (priority != null) data['priority'] = priority;

      final response = await _dio.post(
        ApiConstants.tasks,
        data: data,
        options: Options(headers: _requestHeaders),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      await _dio.post(
        '${ApiConstants.tasks}/$taskId',
        data: data,
        options: Options(headers: _requestHeaders),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Complete a task
  Future<void> completeTask(String taskId) async {
    try {
      await _dio.post(
        '${ApiConstants.tasks}/$taskId/close',
        options: Options(headers: _requestHeaders),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete(
        '${ApiConstants.tasks}/$taskId',
        options: Options(headers: _requestHeaders),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Reopen a completed task
  Future<void> reopenTask(String taskId) async {
    try {
      await _dio.post(
        '${ApiConstants.tasks}/$taskId/reopen',
        options: Options(headers: _requestHeaders),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return const AppException(errorType: ErrorType.network);
    }
    if (e.response?.statusCode == 401) {
      return const AppException(errorType: ErrorType.auth);
    }
    return AppException(
      errorType:  ErrorType.server,
      code: e.response?.statusCode,
    );
  }
}
