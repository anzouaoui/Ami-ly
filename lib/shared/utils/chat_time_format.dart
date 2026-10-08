import 'package:intl/intl.dart';

import '../../core/utils/french_date_format.dart';

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Libellé court de la date du dernier message d'une conversation :
/// `HH:mm` aujourd'hui, `Hier`, jour abrégé (< 7 jours), sinon `dd/MM`.
String conversationTimeLabel(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  if (_isSameDay(dt, now)) {
    return DateFormat('HH:mm').format(dt);
  }
  if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) {
    return 'Hier';
  }
  if (now.difference(dt).inDays < 7) {
    return DateFormat('EEE', 'fr_FR').format(dt);
  }
  return DateFormat('dd/MM').format(dt);
}

/// Horodatage d'une bulle de message : `HH:mm` aujourd'hui,
/// `Hier HH:mm`, sinon `dd/MM HH:mm`.
String chatMessageTimeLabel(DateTime dt) {
  final now = DateTime.now();
  final time = formatHourMinute(dt);
  if (_isSameDay(dt, now)) {
    return time;
  }
  if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) {
    return 'Hier $time';
  }
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  return '$day/$month $time';
}
