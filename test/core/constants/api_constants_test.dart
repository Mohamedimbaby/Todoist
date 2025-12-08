import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl is defined', () {
      expect(ApiConstants.baseUrl, contains('todoist'));
      expect(ApiConstants.baseUrl, startsWith('https://'));
    });

    test('endpoints are defined', () {
      expect(ApiConstants.projects, isNotEmpty);
      expect(ApiConstants.tasks, isNotEmpty);
      expect(ApiConstants.comments, isNotEmpty);
    });

    test('timeout values are positive', () {
      expect(ApiConstants.connectTimeout, greaterThan(0));
      expect(ApiConstants.receiveTimeout, greaterThan(0));
    });

    test('headers are defined', () {
      expect(ApiConstants.authorization, isNotEmpty);
      expect(ApiConstants.contentType, isNotEmpty);
    });

    test('retry settings are defined', () {
      expect(ApiConstants.maxRetries, greaterThan(0));
      expect(ApiConstants.retryDelayMs, greaterThan(0));
    });
  });
}
