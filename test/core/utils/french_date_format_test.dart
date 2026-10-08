import 'package:amily/core/utils/french_date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('frenchMonthName couvre les 12 mois', () {
    expect(frenchMonthName(1), 'janvier');
    expect(frenchMonthName(8), 'août');
    expect(frenchMonthName(12), 'décembre');
    expect(frenchMonthNamesCapitalized[1], 'Février');
  });

  test('formatFrenchLongDate', () {
    expect(formatFrenchLongDate(DateTime(2026, 10, 8)), '8 octobre 2026');
  });

  test('formatHourMinute complète avec des zéros', () {
    expect(formatHourMinute(DateTime(2026, 1, 1, 9, 5)), '09:05');
    expect(formatHourMinute(DateTime(2026, 1, 1, 18, 30)), '18:30');
  });

  test('formatClock', () {
    expect(formatClock(7, 3), '07:03');
    expect(formatClock(23, 45), '23:45');
  });
}
