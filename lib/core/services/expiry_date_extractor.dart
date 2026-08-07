import 'dart:math';

import 'package:flutter/foundation.dart';
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
  /// Caractères typographiquement proches des chiffres, souvent confondus
  /// par l'OCR dans une date MRZ (`YYMMDD`) : valeur → chiffre réel.
  static const Map<String, String> _digitConfusions = {
    'O': '0',
    'Q': '0',
    'I': '1',
    'L': '1',
    'Z': '2',
    'S': '5',
    'G': '6',
    'T': '7',
    'B': '8',
  };

  /// Mot-clés qui signalent qu'une date lisible est une date d'expiration.
  static final RegExp _expiryKeywords = RegExp(r'expir|validit|valable|fin de');

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
      final detected = parseExpiryFromText(recognizedText.text, now: now);
      debugPrint('[ExpiryDateExtractor] Texte reconnu par l\'OCR :\n'
          '${recognizedText.text}');
      debugPrint(
          '[ExpiryDateExtractor] Date d\'expiration détectée : $detected');
      return detected;
    } finally {
      recognizer.close();
    }
  }

  /// Analyse le texte brut reconnu et retourne la date d'expiration.
  ///
  /// Pure (aucune dépendance ML Kit) pour rester testable.
  DateTime? parseExpiryFromText(String text, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final normalized = text.toUpperCase();

    // Le champ « Carte valable jusqu'au <date> » désigne explicitement la
    // date d'expiration : on la privilégie.
    final untilDate = _parseValableJusquau(normalized, reference);
    if (untilDate != null) return untilDate;

    final mrzDate = _parseMrz(normalized, reference);
    if (mrzDate != null) return mrzDate;

    return _parseReadableDate(normalized, reference);
  }

  /// Retourne la date qui suit directement « valable jusqu'au » / « jusqu'à »,
  /// au format `JJ/MM/AAAA` (ou `AA`) ou `MM/AAAA`, si elle est dans le futur.
  DateTime? _parseValableJusquau(String text, DateTime reference) {
    final prefix = r"JUSQU'A?U?\s*(?:LE\s*)?[:\-]?\s*";

    final dmy = RegExp(prefix + r'(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})');
    for (final m in dmy.allMatches(text)) {
      final day = int.parse(m.group(1)!);
      final month = int.parse(m.group(2)!);
      final yearText = m.group(3)!;
      final year = yearText.length == 2
          ? 2000 + int.parse(yearText)
          : int.parse(yearText);
      final date = _buildDate(year: year, month: month, day: day);
      if (date != null && date.isAfter(reference)) return date;
    }

    final my = RegExp(prefix + r'(0[1-9]|1[0-2])[/.\-](\d{4})');
    for (final m in my.allMatches(text)) {
      final month = int.parse(m.group(1)!);
      final year = int.parse(m.group(2)!);
      final date = DateTime(year, month + 1, 0);
      if (date.isAfter(reference)) return date;
    }

    return null;
  }

  // ─── Zone MRZ ──────────────────────────────────────────────────────────

  /// Cherche une date d'expiration dans les lignes MRZ. En TD1 (CNI) comme en
  /// TD3 (passeport), la date est en `YYMMDD` aux positions 21 à 26 (index 0)
  /// de la seconde ligne. Une seule photo peut regrouper plusieurs lignes MRZ
  /// (TD1 = 3 × 30, TD3 = 2 × 44) : on tente chaque début de ligne plausible.
  DateTime? _parseMrz(String text, DateTime reference) {
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (!_looksLikeMrzLine(line)) continue;
      for (final start in const [0, 30, 44, 60, 88, 90]) {
        if (start + 27 > line.length) continue;
        final date = _parseMrzChunk(line, start + 21, reference);
        if (date != null) return date;
      }
    }
    return null;
  }

  /// Une ligne MRZ est longue (≥ 27) et majoritairement composée de lettres
  /// majuscules, de chiffres et de `<`. L'OCR peut ponctuellement lire un
  /// caractère parasite (espace, `%`, `&`) : on tolère jusqu'à 3 écarts.
  bool _looksLikeMrzLine(String line) {
    if (line.length < 27) return false;
    var stray = 0;
    for (final ch in line.codeUnits) {
      final isAlnum = (ch >= 0x30 && ch <= 0x39) || (ch >= 0x41 && ch <= 0x5A);
      if (!isAlnum && ch != 0x3C) {
        stray++;
        if (stray > 3) return false;
      }
    }
    return true;
  }

  DateTime? _parseMrzChunk(String line, int start, DateTime reference) {
    if (start + 6 > line.length) return null;
    final chunk = StringBuffer();
    for (var i = start; i < start + 6; i++) {
      final ch = line[i];
      final code = ch.codeUnitAt(0);
      if (code >= 0x30 && code <= 0x39) {
        chunk.write(ch);
      } else {
        chunk.write(_digitConfusions[ch] ?? '');
      }
    }
    final value = chunk.toString();
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return null;
    final date = _buildDate(
      year: 2000 + int.parse(value.substring(0, 2)),
      month: int.parse(value.substring(2, 4)),
      day: int.parse(value.substring(4, 6)),
    );
    if (date != null && date.isAfter(reference)) return date;
    return null;
  }

  // ─── Date lisible ─────────────────────────────────────────────────────

  /// Secours : cherche des dates dans le texte (« expire le 12/08/2031 »,
  /// « Expire le : 08/2031 »…). Les dates proches d'un mot-clé d'expiration
  /// sont prioritaires, sinon la plus proche dans le futur est retenue.
  DateTime? _parseReadableDate(String text, DateTime reference) {
    final candidates = <(DateTime, bool)>[]; // (date, proche d'un mot-clé)
    const sep = r'[/.\- ]';

    void add(DateTime? date, int index) {
      if (date == null || !date.isAfter(reference)) return;
      final from = max(0, index - 40);
      final to = min(text.length, index + 40);
      final nearKeyword = _expiryKeywords.hasMatch(text.substring(from, to));
      candidates.add((date, nearKeyword));
    }

    // JJ/MM/AAAA ou JJ/MM/AA.
    final dmy = RegExp(r'(\d{1,2})' + sep + r'(\d{1,2})' + sep + r'(\d{2,4})');
    for (final m in dmy.allMatches(text)) {
      final day = int.parse(m.group(1)!);
      final month = int.parse(m.group(2)!);
      final yearText = m.group(3)!;
      final year =
          yearText.length == 2 ? 2000 + int.parse(yearText) : int.parse(yearText);
      add(_buildDate(year: year, month: month, day: day), m.start);
    }

    // AAAA/MM/JJ.
    final ymd = RegExp(r'(\d{4})' + sep + r'(\d{1,2})' + sep + r'(\d{1,2})');
    for (final m in ymd.allMatches(text)) {
      add(
        _buildDate(
          year: int.parse(m.group(1)!),
          month: int.parse(m.group(2)!),
          day: int.parse(m.group(3)!),
        ),
        m.start,
      );
    }

    // MM/AAAA (CNI récente : « Expire le : 08/2031 »). La carte reste
    // valable jusqu'au dernier jour du mois.
    final my = RegExp(r'(0[1-9]|1[0-2])' + sep + r'(\d{4})');
    for (final m in my.allMatches(text)) {
      final month = int.parse(m.group(1)!);
      final year = int.parse(m.group(2)!);
      add(DateTime(year, month + 1, 0), m.start);
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      if (a.$2 != b.$2) return a.$2 ? -1 : 1;
      return a.$1.compareTo(b.$1);
    });
    return candidates.first.$1;
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
