// Formatage de dates en français, sans dépendre de l'initialisation des
// locales `intl`.

/// Noms des mois en minuscules, index 0 = janvier.
const List<String> frenchMonthNames = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// Noms des mois avec majuscule initiale, index 0 = Janvier.
const List<String> frenchMonthNamesCapitalized = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

/// Nom du mois [month] (1-12) en minuscules : `frenchMonthName(3)` → `mars`.
String frenchMonthName(int month) => frenchMonthNames[month - 1];

/// Date longue : `8 octobre 2026`.
String formatFrenchLongDate(DateTime date) =>
    '${date.day} ${frenchMonthName(date.month)} ${date.year}';

/// Heure sur 24 h avec zéros : `09:05`.
String formatHourMinute(DateTime date) => formatClock(date.hour, date.minute);

/// Heure [hour]:[minute] sur 24 h avec zéros : `formatClock(9, 5)` → `09:05`.
/// Pratique pour un `TimeOfDay`.
String formatClock(int hour, int minute) =>
    '${_twoDigits(hour)}:${_twoDigits(minute)}';

String _twoDigits(int value) => value.toString().padLeft(2, '0');
