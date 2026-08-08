import 'package:amily/core/services/expiry_date_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final extractor = ExpiryDateExtractor();
  final now = DateTime(2026, 8, 7);

  group('parseExpiryFromText - zone MRZ', () {
    test('extrait la date d\'expiration d\'une CNI (format TD1, verso)', () {
      final text = [
        'I<UTOFRA<DUPONT<<ANDREA<<<<<<<<<<',
        '2201234565FRA9001011M3101017<<',
        'DUPONT<<ANDREA<<<<<<<<<<<<<<<<<<',
      ].join('\n');
      expect(extractor.parseExpiryFromText(text, now: now), DateTime(2031, 1, 1));
    });

    test('extrait la date d\'expiration d\'un passeport (format TD3)', () {
      final text = [
        'P<FRABERTRAND<<MARC<ELIE<<<<<<<<<<<<<<<<<<<<',
        'AB123456<9FRA9001015M2708157<<<<<<<<<<<<<<<<',
      ].join('\n');
      expect(extractor.parseExpiryFromText(text, now: now),
          DateTime(2027, 8, 15));
    });

    test('ignore une date MRZ déjà expirée', () {
      const text = '2201234565FRA9001011M2001017<<';
      expect(extractor.parseExpiryFromText(text, now: now), isNull);
    });

    test('ignore une date MRZ invalide (mois hors bornes)', () {
      const text = '2201234565FRA9001011M3113017<<';
      expect(extractor.parseExpiryFromText(text, now: now), isNull);
    });

    test('tolère les confusions OCR (O lu à la place de 0)', () {
      const text = '2201234565FRA9001011M31O1O17<<';
      expect(extractor.parseExpiryFromText(text, now: now),
          DateTime(2031, 1, 1));
    });

    test('lit la date dans une zone MRZ concaténée (2 × 44 caractères)', () {
      final text = [
        'P<FRABERTRAND<<MARC<ELIE<<<<<<<<<<<<<<<<<<<<',
        'AB123456<9FRA9001015M2708157<<<<<<<<<<<<<<<<',
      ].join();
      expect(extractor.parseExpiryFromText(text, now: now),
          DateTime(2027, 8, 15));
    });
  });

  group('parseExpiryFromText - date lisible', () {
    test('extrait une date au format JJ/MM/AAAA', () {
      const text = 'Carte nationale d\'identité\nDate d\'expiration : 27/08/2031';
      expect(extractor.parseExpiryFromText(text, now: now),
          DateTime(2031, 8, 27));
    });

    test('extrait un mois/année sur une CNI récente (Expire le : 08/2031)', () {
      const text = 'REPUBLIQUE FRANCAISE\nEXPIRE LE : 08/2031\nADRESSE';
      expect(extractor.parseExpiryFromText(text, now: now),
          DateTime(2031, 8, 31));
    });

    test('privilégie le champ « Carte valable jusqu\'au » (JJ/MM/AAAA)', () {
      const text = 'CARTE NATIONALE D\'IDENTITE\n'
          'CARTE VALABLE JUSQU\'AU 12/08/2031\n'
          'ADRESSE';
      expect(extractor.parseExpiryFromText(text, now: now),
          DateTime(2031, 8, 12));
    });

    test('privilégie le champ « valable jusqu\'au » (mois/année)', () {
      const text = 'CARTE VALABLE JUSQU\'AU 08/2031';
      expect(extractor.parseExpiryFromText(text, now: now),
          DateTime(2031, 8, 31));
    });

    test('retourne null quand seule une date passée est présente', () {
      const text = 'Date de naissance : 09/01/1990';
      expect(extractor.parseExpiryFromText(text, now: now), isNull);
    });

    test('retourne null quand aucune date n\'est présente', () {
      const text = 'Bonjour, ceci n\'est pas un document d\'identité.';
      expect(extractor.parseExpiryFromText(text, now: now), isNull);
    });
  });

  group('parseValidityEndFromText - fin de période de validité', () {
    test('extrait la date qui suit « au » (fin de période)', () {
      const text = 'Période de validité : du 01/09/2026 au 31/08/2031';
      expect(extractor.parseValidityEndFromText(text, now: now),
          DateTime(2031, 8, 31));
    });

    test('gère les accents (« PÉRIODE DE VALIDITÉ »)', () {
      const text = 'PÉRIODE DE VALIDITÉ DU 01/09/2026 AU 31/08/2031';
      expect(extractor.parseValidityEndFromText(text, now: now),
          DateTime(2031, 8, 31));
    });

    test('privilégie « valable jusqu\'au »', () {
      const text = 'Agrément valable jusqu\'au 12/06/2029 '
          '(période du 01/06/2026 au 12/06/2029)';
      expect(extractor.parseValidityEndFromText(text, now: now),
          DateTime(2029, 6, 12));
    });

    test('extrait un mois/année de fin (« au 08/2031 »)', () {
      const text = 'Période de validité du 01/08/2026 au 08/2031';
      expect(extractor.parseValidityEndFromText(text, now: now),
          DateTime(2031, 8, 31));
    });

    test('ignore une période déjà expirée', () {
      const text = 'Période de validité : du 01/01/2020 au 31/12/2023';
      expect(extractor.parseValidityEndFromText(text, now: now), isNull);
    });

    test('retombe sur la date d\'expiration lisible', () {
      const text = 'RÉPUBLIQUE FRANÇAISE\nDate d\'expiration : 27/08/2031';
      expect(extractor.parseValidityEndFromText(text, now: now),
          DateTime(2031, 8, 27));
    });
  });
}
