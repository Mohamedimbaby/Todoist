import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/utils/time_formatter.dart';

void main() {
  group('TimeFormatter', () {
    group('formatSeconds', () {
      test('formats zero seconds correctly', () {
        expect(TimeFormatter.formatSeconds(0), '00:00');
      });

      test('formats seconds under a minute', () {
        expect(TimeFormatter.formatSeconds(45), '00:45');
      });

      test('formats minutes correctly', () {
        expect(TimeFormatter.formatSeconds(125), '02:05');
      });

      test('formats hours correctly', () {
        expect(TimeFormatter.formatSeconds(3661), '01:01:01');
      });

      test('formats large values correctly', () {
        expect(TimeFormatter.formatSeconds(36000), '10:00:00');
      });
    });

    group('formatSecondsHuman', () {
      test('formats zero seconds', () {
        expect(TimeFormatter.formatSecondsHuman(0), '0s');
      });

      test('formats seconds under a minute', () {
        expect(TimeFormatter.formatSecondsHuman(45), '45s');
      });

      test('formats minutes', () {
        expect(TimeFormatter.formatSecondsHuman(125), '2m');
      });

      test('formats hours and minutes', () {
        expect(TimeFormatter.formatSecondsHuman(3661), '1h 1m');
      });
    });
  });
}

