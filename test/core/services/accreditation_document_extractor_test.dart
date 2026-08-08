import 'package:amily/core/services/accreditation_document_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final extractor = AccreditationDocumentExtractor();
  final now = DateTime(2026, 8, 7);

  group('parseAccreditationFromText - numéro d\'agrément', () {
    test('extrait le numéro derrière « N° d\'agrément »', () {
      const text = 'AGRÉMENT N° D\'AGRÉMENT : 01932126014\n'
          'Période de validité : du 01/09/2026 au 31/08/2031';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.number, '01932126014');
    });

    test('extrait le numéro derrière « Numéro d\'agrément » avec espaces', () {
      const text = 'Numéro d\'agrément 019 321 26 014';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.number, '01932126014');
    });

    test('extrait le numéro derrière « AGRÉMENT N° »', () {
      const text = 'AGRÉMENT N° 01932126014';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.number, '01932126014');
    });

    test('tolère les confusions OCR (O lu à la place de 0)', () {
      const text = 'N° d\'agrément : 01932126O14';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.number, '01932126014');
    });

    test('retombe sur la plus longue suite de chiffres sans libellé', () {
      const text = 'RÉPUBLIQUE FRANÇAISE\n01932126014\nPMI de secteur';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.number, '01932126014');
    });

    test('retourne null sans numéro plausible', () {
      const text = 'Pas de numéro ici.';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.number, isNull);
    });
  });

  group('parseAccreditationFromText - fin de période de validité', () {
    test('extrait la date qui suit « au » dans la période de validité', () {
      const text = 'AGRÉMENT N° 01932126014\n'
          'Période de validité : du 01/09/2026 au 31/08/2031';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.expiry, DateTime(2031, 8, 31));
    });

    test('extrait la date après « valable jusqu\'au »', () {
      const text = 'Agrément valable jusqu\'au 12/06/2029';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.expiry, DateTime(2029, 6, 12));
    });

    test('ignore une période déjà expirée', () {
      const text = 'Période de validité : du 01/01/2020 au 31/12/2023';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.expiry, isNull);
    });

    test('extrait le mois/année de fin (« au 08/2031 »)', () {
      const text = 'Période de validité du 01/08/2026 au 08/2031';
      final data = extractor.parseAccreditationFromText(text, now: now);
      expect(data.expiry, DateTime(2031, 8, 31));
    });
  });

  group('comparaison saisie vs document', () {
    test('numbersMatch : correspondance avec mise en forme différente', () {
      expect(
        AccreditationDocumentExtractor.numbersMatch('019 321 26 014', '01932126014'),
        isTrue,
      );
      expect(
        AccreditationDocumentExtractor.numbersMatch('01932126015', '01932126014'),
        isFalse,
      );
      expect(
        AccreditationDocumentExtractor.numbersMatch('', '01932126014'),
        isFalse,
      );
      expect(
        AccreditationDocumentExtractor.numbersMatch('01932126014', null),
        isFalse,
      );
    });

    test('datesMatch : même mois/année', () {
      expect(
        AccreditationDocumentExtractor.datesMatch(
          DateTime(2031, 8, 31),
          DateTime(2031, 8, 12),
        ),
        isTrue,
      );
      expect(
        AccreditationDocumentExtractor.datesMatch(
          DateTime(2031, 9, 1),
          DateTime(2031, 8, 12),
        ),
        isFalse,
      );
      expect(AccreditationDocumentExtractor.datesMatch(null, DateTime(2031, 8, 12)),
          isFalse);
    });
  });
}
