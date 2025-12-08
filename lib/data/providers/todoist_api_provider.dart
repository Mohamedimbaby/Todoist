import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';

/// Todoist API provider for making REST API calls
class TodoistApiProvider {
  final Dio _dio;
  final String _token;

  TodoistApiProvider({required Dio dio, required String token})
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

  /// Get all projects
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await _dio.get(
        ApiConstants.projects,
        options: Options(headers: _requestHeaders),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new project
  Future<Map<String, dynamic>> createProject(String name) async {
    try {
      final response = await _dio.post(
        ApiConstants.projects,
        data: {'name': name},
        options: Options(headers: _requestHeaders),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      await _dio.delete(
        '${ApiConstants.projects}/$projectId',
        options: Options(headers: _requestHeaders),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return const AppException( errorType: ErrorType.network);
    }
    if (e.response?.statusCode == 401) {
      return const AppException(errorType: ErrorType.auth);
    }
    if (e.response?.statusCode == 404) {
      return const AppException(errorType: ErrorType.notFound);
    }
    return AppException(
      errorType:  ErrorType.server,
      code: e.response?.statusCode,
    );
  }
}

