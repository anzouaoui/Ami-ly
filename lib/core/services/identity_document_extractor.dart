import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'expiry_date_extractor.dart';

/// Fournit une instance d'extraction des données d'une pièce d'identité
/// (nom, prénom, numéro de document, date de naissance, date d'expiration)
/// via ML Kit Text Recognition (OCR on-device, sans SDK KYC tiers).
final identityDocumentExtractorProvider = Provider<IdentityDocumentExtractor>(
  (_) => IdentityDocumentExtractor(),
);

/// Données lues sur une pièce d'identité (CNI / passeport) via OCR.
class IdentityExtractedData {
  const IdentityExtractedData({
    this.lastName,
    this.firstName,
    this.documentNumber,
    this.birthDate,
    this.expiryDate,
  });

  const IdentityExtractedData.empty()
      : lastName = null,
        firstName = null,
        documentNumber = null,
        birthDate = null,
        expiryDate = null;

  /// Nom de famille détecté (zone MRZ ou libellé « NOM : … »).
  final String? lastName;

  /// Prénom(s) détecté(s).
  final String? firstName;

  /// Numéro de document détecté (zone MRZ ou libellé « N° : … »).
  final String? documentNumber;

  /// Date de naissance détectée.
  final DateTime? birthDate;

  /// Date d'expiration détectée.
  final DateTime? expiryDate;

  /// `true` si aucun champ n'a pu être extrait.
  bool get isEmpty =>
      lastName == null &&
      firstName == null &&
      documentNumber == null &&
      birthDate == null &&
      expiryDate == null;

  /// Nombre de champs renseignés (affiché dans l'écran de relecture).
  int get foundCount => [
        if (lastName != null) 1,
        if (firstName != null) 1,
        if (documentNumber != null) 1,
        if (birthDate != null) 1,
        if (expiryDate != null) 1,
      ].length;
}

/// Extrait les informations clés d'une pièce d'identité (CNI / passeport)
/// à partir de sa photo, via ML Kit Text Recognition (OCR on-device).
///
/// Le texte reconnu est analysé en priorité dans la zone MRZ (Machine
/// Readable Zone) : lignes TD1 (CNI) et TD3 (passeport). En secours, on lit
/// les libellés français (« NOM : … », « Date de naissance : … »…) utilisés
/// par la nouvelle CNI sans zone MRZ.
class IdentityDocumentExtractor {
  IdentityDocumentExtractor({ExpiryDateExtractor? expiryExtractor})
      : _expiryExtractor = expiryExtractor ?? ExpiryDateExtractor();

  final ExpiryDateExtractor _expiryExtractor;

  /// Caractères typographiquement proches des chiffres, souvent confondus
  /// par l'OCR dans une zone MRZ : valeur → chiffre réel.
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

  /// Analyse l'image localisée à [imagePath] et retourne les informations
  /// d'identité détectées.
  Future<IdentityExtractedData> extract(
    String imagePath, {
    DateTime? now,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer();
    try {
      final recognizedText = await recognizer.processImage(inputImage);
      debugPrint('[IdentityDocumentExtractor] Texte reconnu par l\'OCR :\n'
          '${recognizedText.text}');
      return parseIdentityFromText(recognizedText.text, now: now);
    } finally {
      recognizer.close();
    }
  }

  /// Analyse le texte brut reconnu et retourne les informations d'identité.
  ///
  /// Pure (aucune dépendance ML Kit) pour rester testable.
  IdentityExtractedData parseIdentityFromText(String text, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final normalized = _normalize(text);

    final mrz = _parseMrz(normalized, reference);
    final labels = _parseLabels(normalized, reference);

    final expiryDate = mrz?.expiryDate ??
        _expiryExtractor.parseExpiryFromText(text, now: now);

    return IdentityExtractedData(
      lastName: mrz?.lastName ?? labels?.lastName,
      firstName: mrz?.firstName ?? labels?.firstName,
      documentNumber: mrz?.documentNumber ?? labels?.documentNumber,
      birthDate: mrz?.birthDate ?? labels?.birthDate,
      expiryDate: expiryDate,
    );
  }

  // ─── Zone MRZ ──────────────────────────────────────────────────────────

  /// Cherche les lignes MRZ dans le texte (TD1 = 3 × 30, TD3 = 2 × 44).
  List<String> _extractMrzLines(String text) {
    final lines = <String>[];
    for (final raw in text.split('\n')) {
      final line = raw.trim().toUpperCase().replaceAll(' ', '');
      if (_looksLikeMrzLine(line)) lines.add(line);
    }
    return lines;
  }

  /// Une ligne MRZ est longue (≥ 27) et majoritairement composée de lettres
  /// majuscules, de chiffres et de `<`. On tolère jusqu'à 3 écarts (l'OCR
  /// peut lire ponctuellement un caractère parasite).
  bool _looksLikeMrzLine(String line) {
    if (line.length < 27) return false;
    var stray = 0;
    for (final code in line.codeUnits) {
      final isAlnum =
          (code >= 0x30 && code <= 0x39) || (code >= 0x41 && code <= 0x5A);
      if (!isAlnum && code != 0x3C) {
        stray++;
        if (stray > 3) return false;
      }
    }
    return true;
  }

  _MrzData? _parseMrz(String normalized, DateTime reference) {
    final lines = _extractMrzLines(normalized);
    if (lines.isEmpty) return null;

    String? lastName;
    String? firstName;
    String? documentNumber;
    DateTime? birthDate;
    DateTime? expiryDate;

    for (final line in lines) {
      if (lastName == null || firstName == null) {
        final names = _parseMrzNames(line);
        if (names != null) {
          lastName ??= names.lastName;
          firstName ??= names.firstName;
        }
      }
      // La ligne de données peut être complète (30 ou 44 caractères) ou
      // concaténée (OCR qui fusionne deux lignes). On tente plusieurs départs.
      for (final start in const [0, 30, 44, 60, 88]) {
        documentNumber ??= _parseMrzDocumentNumberAt(line, start);
        // Naissance en YYMMDD à 13, expiration en YYMMDD à 21 (indices 0).
        birthDate ??= _parseMrzDateAt(line, start + 13, reference,
            future: false);
        expiryDate ??= _parseMrzDateAt(line, start + 21, reference,
            future: true);
      }
    }

    if (lastName == null &&
        firstName == null &&
        documentNumber == null &&
        birthDate == null &&
        expiryDate == null) {
      return null;
    }
    return _MrzData(
      lastName: lastName,
      firstName: firstName,
      documentNumber: documentNumber,
      birthDate: birthDate,
      expiryDate: expiryDate,
    );
  }

  /// Extrait nom + prénom(s) d'une ligne MRZ : `P<FRA<DUPONT<<ANDREA`,
  /// `IDFRA<DUPONT<<ANDREA`, `I<UTOFRA<DUPONT<<ANDREA`…
  ({String lastName, String firstName})? _parseMrzNames(String line) {
    var s = line;

    // Type (P, ID, I…) + pays émetteur (3 lettres), avec ou sans séparateur.
    if (RegExp(r'^[A-Z]{1,2}<[A-Z]{3}').hasMatch(s)) {
      s = s.substring(5);
    } else if (RegExp(r'^[A-Z]{2}[A-Z]{3}').hasMatch(s)) {
      s = s.substring(5);
    } else {
      return null;
    }

    // Nationalité optionnelle (TD1) : 3 lettres suivies de '<'.
    if (RegExp(r'^[A-Z]{3}<').hasMatch(s)) {
      s = s.substring(4);
    }

    final index = s.indexOf('<<');
    if (index <= 0) return null;
    final lastNamePart = s.substring(0, index).replaceAll('<', '');
    final givenPart = s.substring(index + 2);
    if (lastNamePart.length < 2) return null;

    final givenNames = givenPart
        .split('<')
        .where(_isAlphaToken)
        .toList();
    if (givenNames.isEmpty) return null;

    return (
      lastName: lastNamePart,
      firstName: givenNames.join(' '),
    );
  }

  /// Extrait le numéro de document au début d'une ligne MRZ (jusqu'à 10
  /// caractères, arrêté au premier `<`). Rejette les faux positifs sans
  /// chiffre (lignes de nom).
  String? _parseMrzDocumentNumberAt(String line, int start) {
    if (start >= line.length) return null;
    var end = start;
    while (end < line.length && end < start + 10 && line[end] != '<') {
      end++;
    }
    var token = line.substring(start, end);
    // Le numéro est parfois suivi de la nationalité : « AB1234569FRA900101 ».
    final nationality = RegExp(r'[A-Z]{3}\d{6}').firstMatch(token);
    if (nationality != null) token = token.substring(0, nationality.start);
    token = token.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (token.length < 4 || !RegExp(r'[0-9]').hasMatch(token)) return null;
    return token;
  }

  /// Lit une date `YYMMDD` aux positions [start..start+6[ d'une ligne MRZ,
  /// en corrigeant les confusions OCR (O → 0, I → 1…).
  DateTime? _parseMrzDateAt(
    String line,
    int start,
    DateTime reference, {
    required bool future,
  }) {
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
      // Expiration : toujours sur ce siècle (2031, 2027…). Naissance :
      // pivot 2 chiffres (90 → 1990, 05 → 2005).
      year: future
          ? 2000 + int.parse(value.substring(0, 2))
          : _expandTwoDigitYear(int.parse(value.substring(0, 2)), reference),
      month: int.parse(value.substring(2, 4)),
      day: int.parse(value.substring(4, 6)),
    );
    if (date == null) return null;
    if (future && !date.isAfter(reference)) return null;
    if (!future && date.isAfter(reference)) return null;
    return date;
  }

  // ─── Libellés français (nouvelle CNI sans MRZ) ─────────────────────────

  _LabelData? _parseLabels(String normalized, DateTime reference) {
    String? lastName;
    String? firstName;
    String? documentNumber;
    DateTime? birthDate;

    // Chaque libellé occupe sa propre ligne (« NOM : … », « PRENOM : … »…).
    // On traite les lignes indépendamment pour qu'une valeur n'en avale pas
    // une autre (« DUPONT PRENOM »), et on s'arrête dès qu'un champ est trouvé.
    final nom = RegExp(
      r'^\s*NOM\s*(?:DE\s+FAMILLE)?\s*[:.\-]?\s*'
      r'([A-Z]{2,}(?:[\s\-][A-Z]{2,})*)',
    );
    final prenom = RegExp(
      r'^\s*PRENOM\b(?:\(?S\)?)?\s*[:.\-]?\s*'
      r'([A-Z]{2,}(?:[\s\-][A-Z]{2,})*)',
    );
    final numero = RegExp(
      r'^\s*(?:NUMERO\s*(?:DE\s+DOCUMENT)?|N[°º]\s?|NO\s?)\s*[:.\-]?\s*'
      r'([A-Z0-9]{4,}(?:\s[A-Z0-9]{4,})*)',
    );
    final naissance = RegExp(
      r'^\s*DATE\s+DE\s+NAISSANCE\s*[:.\-]?\s*'
      r'(\d{1,2})[/.\-\s](\d{1,2})[/.\-\s](\d{2,4})',
    );

    for (final rawLine in normalized.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final nomMatch = nom.firstMatch(line);
      if (nomMatch != null && lastName == null) {
        final value = nomMatch.group(1)!.trim();
        if (value.isNotEmpty) lastName = _capitalizeWords(value);
      }

      final prenomMatch = prenom.firstMatch(line);
      if (prenomMatch != null && firstName == null) {
        final value = prenomMatch.group(1)!.trim();
        if (value.isNotEmpty) firstName = _capitalizeWords(value);
      }

      final numeroMatch = numero.firstMatch(line);
      if (numeroMatch != null && documentNumber == null) {
        final value = numeroMatch.group(1)!.replaceAll(RegExp(r'\s'), '');
        if (value.length >= 4) documentNumber = value;
      }

      final naissanceMatch = naissance.firstMatch(line);
      if (naissanceMatch != null && birthDate == null) {
        final yearText = naissanceMatch.group(3)!;
        final year = yearText.length == 2
            ? _expandTwoDigitYear(int.parse(yearText), reference)
            : int.parse(yearText);
        final date = _buildDate(
          year: year,
          month: int.parse(naissanceMatch.group(2)!),
          day: int.parse(naissanceMatch.group(1)!),
        );
        if (date != null && !date.isAfter(reference)) birthDate = date;
      }
    }

    if (lastName == null &&
        firstName == null &&
        documentNumber == null &&
        birthDate == null) {
      return null;
    }
    return _LabelData(
      lastName: lastName,
      firstName: firstName,
      documentNumber: documentNumber,
      birthDate: birthDate,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  bool _isAlphaToken(String token) =>
      token.length >= 2 && RegExp(r'^[A-Z]+$').hasMatch(token);

  /// « DUPONT » → « Dupont », « MARC-ANTOINE » → « Marc Antoine ».
  String _capitalizeWords(String input) => input
      .split(RegExp(r'[\s\-]'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0] + w.substring(1).toLowerCase())
      .join(' ');

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

  /// Développe une année sur 2 chiffres en fonction de l'année de référence :
  /// « 90 » → 1990, « 05 » → 2005 (pivot à l'année en cours).
  int _expandTwoDigitYear(int yy, DateTime reference) =>
      yy <= reference.year % 100 ? 2000 + yy : 1900 + yy;

  /// Majuscules + retrait des accents pour fiabiliser les motifs regex.
  String _normalize(String input) {
    var s = input.toUpperCase();
    return s
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Ë', 'E')
        .replaceAll('À', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Ã', 'A')
        .replaceAll('Î', 'I')
        .replaceAll('Ï', 'I')
        .replaceAll('Ô', 'O')
        .replaceAll('Ö', 'O')
        .replaceAll('Ù', 'U')
        .replaceAll('Û', 'U')
        .replaceAll('Ü', 'U')
        .replaceAll('Ç', 'C')
        .replaceAll('Œ', 'OE')
        .replaceAll('Æ', 'AE');
  }
}

class _MrzData {
  const _MrzData({
    this.lastName,
    this.firstName,
    this.documentNumber,
    this.birthDate,
    this.expiryDate,
  });

  final String? lastName;
  final String? firstName;
  final String? documentNumber;
  final DateTime? birthDate;
  final DateTime? expiryDate;
}

class _LabelData {
  const _LabelData({
    this.lastName,
    this.firstName,
    this.documentNumber,
    this.birthDate,
  });

  final String? lastName;
  final String? firstName;
  final String? documentNumber;
  final DateTime? birthDate;
}
