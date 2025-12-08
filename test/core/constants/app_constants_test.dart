import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('column constants are defined', () {
      expect(AppConstants.columnTodo, 'To Do');
      expect(AppConstants.columnInProgress, 'In Progress');
      expect(AppConstants.columnDone, 'Done');
    });

    test('box names are defined', () {
      expect(AppConstants.tasksBox, isNotEmpty);
      expect(AppConstants.timersBox, isNotEmpty);
      expect(AppConstants.commentsBox, isNotEmpty);
      expect(AppConstants.historyBox, isNotEmpty);
      expect(AppConstants.projectsBox, isNotEmpty);
      expect(AppConstants.syncQueueBox, isNotEmpty);
    });

    test('defaultColumns contains all columns', () {
      expect(AppConstants.defaultColumns, contains(AppConstants.columnTodo));
      expect(
          AppConstants.defaultColumns, contains(AppConstants.columnInProgress));
      expect(AppConstants.defaultColumns, contains(AppConstants.columnDone));
    });

    test('secure storage keys are defined', () {
      expect(AppConstants.todoistTokenKey, isNotEmpty);
    });

    test('app info is defined', () {
      expect(AppConstants.appName, 'TaskTime');
      expect(AppConstants.appVersion, isNotEmpty);
    });
  });
}
