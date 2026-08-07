import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Fournit une instance d'extraction de date d'expiration (OCR on-device).
final expiryDateExtractorProvider =
    Provider<ExpiryDateExtractor>((_) => ExpiryDateExtractor());

/// Extrait la date d'expiration d'un document d'identité (CNI / passeport)
/// à partir de sa photo, via ML Kit Text Recognition (OCR on-device).
///
/// La date est prioritairement lue dans la zone MRZ (Machine Readable Zone)
/// présente au verso des CNI et sur la page de données des passeports, puis
/// en secours dans un libellé humain (« Date d'expiration : … »).
class ExpiryDateExtractor {
  /// Analyse l'image localisée à [imagePath] et retourne la date
  /// d'expiration détectée (dans le futur), ou `null` si aucune n'est fiable.
  Future<DateTime?> extractExpiryDate(
    String imagePath, {
    DateTime? now,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer();
    try {
      final recognizedText = await recognizer.processImage(inputImage);
      return parseExpiryFromText(recognizedText.text, now: now);
    } finally {
      recognizer.close();
    }
  }

  /// Analyse le texte brut reconnu et retourne la date d'expiration.
  ///
  /// Pure (aucune dépendance ML Kit) pour rester testable.
  DateTime? parseExpiryFromText(String text, {DateTime? now}) {
    final reference = now ?? DateTime.now();

    for (final line in _mrzLines(text)) {
      final date = _parseMrzDate(line);
      if (date != null && date.isAfter(reference)) return date;
    }

    return _parseHumanReadableDates(text, reference);
  }

  /// Retourne les lignes susceptibles d'appartenir à une zone MRZ :
  /// uniquement lettres majuscules, chiffres et `<`, d'au moins 27
  /// caractères (une date est lue aux positions 21 à 26, index 0).
  List<String> _mrzLines(String text) {
    final mrzLike = RegExp(r'^[A-Z0-9<]+$');
    return text
        .split('\n')
        .map((l) => l.replaceAll(' ', ''))
        .where((l) =>
            l.length >= 27 &&
            l.contains('<<') &&
            mrzLike.hasMatch(l))
        .toList();
  }

  /// Dans les formats MRZ TD1 (CNI) et TD3 (passeport), la date
  /// d'expiration est en `YYMMDD` aux positions 21 à 26 (index 0)
  /// de la seconde ligne de la zone.
  DateTime? _parseMrzDate(String line) {
    final chunk = line.substring(21, 27);
    if (!RegExp(r'^\d{6}$').hasMatch(chunk)) return null;
    return _buildDate(
      year: 2000 + int.parse(chunk.substring(0, 2)),
      month: int.parse(chunk.substring(2, 4)),
      day: int.parse(chunk.substring(4, 6)),
    );
  }

  /// Secours : cherche des dates `JJ/MM/AAAA` (ou `JJ.MM.AAAA`,
  /// `JJ-MM-AAAA`) dans le texte, et retourne la plus proche dans le futur.
  DateTime? _parseHumanReadableDates(String text, DateTime reference) {
    final dates = <DateTime>[];
    final pattern = RegExp(r'(\d{2})[/.\-](\d{2})[/.\-](\d{4})');
    for (final m in pattern.allMatches(text)) {
      final date = _buildDate(
        year: int.parse(m.group(3)!),
        month: int.parse(m.group(2)!),
        day: int.parse(m.group(1)!),
      );
      if (date != null && date.isAfter(reference)) {
        dates.add(date);
      }
    }
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }

  DateTime? _buildDate({
    required int year,
    required int month,
    required int day,
  }) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }
}
