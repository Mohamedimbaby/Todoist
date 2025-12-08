import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

/// Secure storage provider for sensitive data like API tokens
class SecureStorageProvider {
  final FlutterSecureStorage _storage;

  SecureStorageProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save Todoist token
  Future<void> saveTodoistToken(String token) async {
    await _storage.write(key: AppConstants.todoistTokenKey, value: token);
  }

  /// Get Todoist token
  Future<String?> getTodoistToken() async {
    return _storage.read(key: AppConstants.todoistTokenKey);
  }

  /// Delete Todoist token
  Future<void> deleteTodoistToken() async {
    await _storage.delete(key: AppConstants.todoistTokenKey);
  }

  /// Check if Todoist token exists
  Future<bool> hasTodoistToken() async {
    final token = await getTodoistToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

