import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'expiry_date_extractor.dart';

/// Fournit une instance d'extraction des donnÃ©es d'un document d'agrÃ©ment
/// PMI (numÃ©ro + fin de pÃ©riode de validitÃ©) via OCR on-device.
final accreditationDocumentExtractorProvider = Provider<AccreditationDocumentExtractor>(
  (_) => AccreditationDocumentExtractor(),
);

/// DonnÃ©es lues sur un document d'agrÃ©ment PMI (photo/scan) via OCR.
class AccreditationExtractedData {
  const AccreditationExtractedData({this.number, this.expiry});

  /// NumÃ©ro d'agrÃ©ment dÃ©tectÃ©, rÃ©duit aux chiffres.
  final String? number;

  /// Fin de pÃ©riode de validitÃ© dÃ©tectÃ©e.
  final DateTime? expiry;

  bool get isEmpty => number == null && expiry == null;
}

/// Extrait le numÃ©ro d'agrÃ©ment et la date de fin de pÃ©riode de validitÃ©
/// d'un document d'agrÃ©ment PMI Ã  partir de sa photo, via ML Kit Text
/// Recognition (OCR on-device).
class AccreditationDocumentExtractor {
  AccreditationDocumentExtractor({ExpiryDateExtractor? expiryExtractor})
      : _expiryExtractor = expiryExtractor ?? ExpiryDateExtractor();

  final ExpiryDateExtractor _expiryExtractor;

  /// CaractÃ¨res typographiquement proches des chiffres, souvent confondus
  /// par l'OCR dans un numÃ©ro d'agrÃ©ment : valeur â†’ chiffre rÃ©el.
  static const Map<String, String> _digitConfusions = {
    'O': '0',
    'Q': '0',
    'D': '0',
    'I': '1',
    'L': '1',
    'Z': '2',
    'S': '5',
    'G': '6',
    'T': '7',
    'B': '8',
  };

  /// Analyse l'image localisÃ©e Ã  [imagePath] et retourne le numÃ©ro
  /// d'agrÃ©ment et la fin de pÃ©riode de validitÃ© dÃ©tectÃ©s.
  Future<AccreditationExtractedData> extract(
    String imagePath, {
    DateTime? now,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer();
    try {
      final recognizedText = await recognizer.processImage(inputImage);
      debugPrint('[AccreditationExtractor] Texte reconnu par l\'OCR :\n'
          '${recognizedText.text}');
      return parseAccreditationFromText(recognizedText.text, now: now);
    } finally {
      recognizer.close();
    }
  }

  /// Analyse le texte brut reconnu : numÃ©ro d'agrÃ©ment + fin de pÃ©riode de
  /// validitÃ©. Pure (aucune dÃ©pendance ML Kit) pour rester testable.
  AccreditationExtractedData parseAccreditationFromText(
    String text, {
    DateTime? now,
  }) {
    final expiry = _expiryExtractor.parseValidityEndFromText(text, now: now);
    return AccreditationExtractedData(
      number: _extractNumber(text),
      expiry: expiry,
    );
  }

  /// Cherche le numÃ©ro d'agrÃ©ment : prioritÃ© au libellÃ© Â« NÂ° d'agrÃ©ment Â» /
  /// Â« NumÃ©ro d'agrÃ©ment Â», puis Ã  la plus longue suite de chiffres.
  String? _extractNumber(String text) {
    final normalized = _stripAccents(text.toUpperCase().replaceAll('\u00A0', ' '));

    // CaractÃ¨res Â« chiffres Â» possibles Ã  l'Ã©cran aprÃ¨s OCR : les chiffres
    // rÃ©els + les lettres typographiquement proches (O, I, Z, S, T, Bâ€¦).
    const digit = r'[0-9OQDILZSGTB]';
    const digitOrGroup = r'[0-9OQDILZSGTB \t.\-]';

    // Â« NÂ° d'agrÃ©ment : 01932126014 Â», Â« NumÃ©ro d'agrÃ©ment 019 321 26 014 Â»â€¦
    final labeled = RegExp(
        r"(?:N°?\s*|NUMERO\s*)(?:D|DE)?\s*['’]?\s*AGREMENT\s*[:.\-\s]*"
        '$digit$digitOrGroup{4,}');
    for (final m in labeled.allMatches(normalized)) {
      final candidate = _digitsOnly(m.group(0)!.replaceAll(RegExp(r'^\D+'), ''));
      if (candidate.length >= 5) return candidate;
    }

    // Â« AGRÃ‰MENT NÂ° 01932126014 Â»â€¦
    final agrementLabel = RegExp(
        r'AGREMENT\s*(?:NÂ°?\s*)?[:.\-\s]*' '$digit$digitOrGroup{4,}');
    for (final m in agrementLabel.allMatches(normalized)) {
      final candidate = _digitsOnly(m.group(0)!.replaceAll(RegExp(r'^\D+'), ''));
      if (candidate.length >= 5) return candidate;
    }

    // Secours : la plus longue suite de chiffres plausible (9 Ã  12 chiffres,
    // sinon la plus longue au moins de 5 chiffres).
    String? best;
    int? bestScore;
    for (final m in RegExp('(?<![0-9A-Z])' '$digit$digitOrGroup{4,}')
        .allMatches(normalized)) {
      final candidate = _digitsOnly(m.group(0)!);
      if (candidate.length < 5) continue;
      final length = candidate.length;
      final score = length >= 9 && length <= 12 ? 1000 + (12 - length) : length;
      if (bestScore == null || score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return best;
  }

  String _digitsOnly(String input) {
    final buffer = StringBuffer();
    for (final rune in input.toUpperCase().codeUnits) {
      final ch = String.fromCharCode(rune);
      final code = ch.codeUnitAt(0);
      if (code >= 0x30 && code <= 0x39) {
        buffer.write(ch);
      } else {
        buffer.write(_digitConfusions[ch] ?? '');
      }
    }
    return buffer.toString();
  }

  /// Retire les accents d'un texte dÃ©jÃ  en majuscules.
  String _stripAccents(String input) => input
      .replaceAll('Ã‰', 'E')
      .replaceAll('Ãˆ', 'E')
      .replaceAll('ÃŠ', 'E')
      .replaceAll('Ã‹', 'E')
      .replaceAll('Ã€', 'A')
      .replaceAll('Ã‚', 'A')
      .replaceAll('Ãƒ', 'A')
      .replaceAll('ÃŽ', 'I')
      .replaceAll('Ã', 'I')
      .replaceAll('Ã”', 'O')
      .replaceAll('Ã–', 'O')
      .replaceAll('Ã™', 'U')
      .replaceAll('Ã›', 'U')
      .replaceAll('Ãœ', 'U')
      .replaceAll('Ã‡', 'C')
      .replaceAll('Å’', 'OE')
      .replaceAll('Ã†', 'AE');

  // â”€â”€â”€ Comparaison saisie vs document â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Normalise un numÃ©ro d'agrÃ©ment : uniquement les chiffres.
  static String normalizeNumber(String input) =>
      input.replaceAll(RegExp(r'[^0-9]'), '');

  /// `true` si le numÃ©ro saisi correspond au numÃ©ro lu sur le document
  /// (mÃªmes chiffres, indÃ©pendamment de la mise en forme).
  static bool numbersMatch(String entered, String? extracted) {
    if (extracted == null || extracted.isEmpty) return false;
    final a = normalizeNumber(entered);
    final b = normalizeNumber(extracted);
    return a.isNotEmpty && a == b;
  }

  /// `true` si la date saisie correspond Ã  la fin de pÃ©riode de validitÃ© du
  /// document (mÃªme mois / mÃªme annÃ©e).
  static bool datesMatch(DateTime? entered, DateTime? extracted) {
    if (entered == null || extracted == null) return false;
    return entered.year == extracted.year && entered.month == extracted.month;
  }
}
