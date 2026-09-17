import 'package:flutter_test/flutter_test.dart';
import 'package:signage_surgeon_technician/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils.isSameDay', () {
    test('true for the same calendar day at different times', () {
      final a = DateTime(2026, 9, 17, 8, 0);
      final b = DateTime(2026, 9, 17, 22, 30);
      expect(AppDateUtils.isSameDay(a, b), isTrue);
    });

    test('false across a day boundary', () {
      final a = DateTime(2026, 9, 17, 23, 59);
      final b = DateTime(2026, 9, 18, 0, 1);
      expect(AppDateUtils.isSameDay(a, b), isFalse);
    });
  });

  group('AppDateUtils.isToday', () {
    test('null date is never "today"', () {
      expect(AppDateUtils.isToday(null), isFalse);
    });

    test('the current moment is today', () {
      expect(AppDateUtils.isToday(DateTime.now()), isTrue);
    });

    test('yesterday is not today', () {
      expect(AppDateUtils.isToday(DateTime.now().subtract(const Duration(days: 1))), isFalse);
    });
  });
}
