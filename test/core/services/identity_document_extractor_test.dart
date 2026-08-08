import 'package:amily/core/services/identity_document_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final extractor = IdentityDocumentExtractor();
  final now = DateTime(2026, 8, 7);

  group('parseIdentityFromText - CNI (zone MRZ TD1)', () {
    test('extrait nom, prénom, numéro, naissance et expiration', () {
      final text = [
        'I<UTOFRA<DUPONT<<ANDREA<<<<<<<<<<',
        '2201234565FRA9001011M3101017<<',
        'DUPONT<<ANDREA<<<<<<<<<<<<<<<<<<',
      ].join('\n');
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.lastName, 'DUPONT');
      expect(data.firstName, 'ANDREA');
      expect(data.documentNumber, '2201234565');
      expect(data.birthDate, DateTime(1990, 1, 1));
      expect(data.expiryDate, DateTime(2031, 1, 1));
      expect(data.foundCount, 5);
    });

    test('rejette une date d\'expiration déjà passée', () {
      final text = [
        'I<UTOFRA<DUPONT<<ANDREA<<<<<<<<<<',
        '2201234565FRA9001011M3101017<<',
        'DUPONT<<ANDREA<<<<<<<<<<<<<<<<<<',
      ].join('\n');
      final data = extractor.parseIdentityFromText(
        text,
        now: DateTime(2032, 1, 1),
      );
      expect(data.lastName, 'DUPONT');
      expect(data.expiryDate, isNull);
    });

    test('tolère les confusions OCR dans les dates MRZ (O→0, I→1)', () {
      final text = [
        'I<UTOFRA<DUPONT<<ANDREA<<<<<<<<<<',
        '2201234565FRA900IOI1M31O1O17<<',
        'DUPONT<<ANDREA<<<<<<<<<<<<<<<<<<',
      ].join('\n');
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.documentNumber, '2201234565');
      expect(data.birthDate, DateTime(1990, 1, 1));
      expect(data.expiryDate, DateTime(2031, 1, 1));
    });
  });

  group('parseIdentityFromText - passeport (zone MRZ TD3)', () {
    test('extrait nom composé et prénoms multiples', () {
      final text = [
        'P<FRABERTRAND<<MARC<ELIE<<<<<<<<<<<<<<<<<<<<',
        'AB123456<9FRA9001015M2708157<<<<<<<<<<<<<<<<',
      ].join('\n');
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.lastName, 'BERTRAND');
      expect(data.firstName, 'MARC ELIE');
      expect(data.documentNumber, 'AB123456');
      expect(data.birthDate, DateTime(1990, 1, 1));
      expect(data.expiryDate, DateTime(2027, 8, 15));
    });

    test('lit une zone MRZ concaténée (OCR qui fusionne les lignes)', () {
      final text = [
        'P<FRABERTRAND<<MARC<ELIE<<<<<<<<<<<<<<<<<<<<',
        'AB123456<9FRA9001015M2708157<<<<<<<<<<<<<<<<',
      ].join();
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.lastName, 'BERTRAND');
      expect(data.documentNumber, 'AB123456');
      expect(data.expiryDate, DateTime(2027, 8, 15));
    });
  });

  group('parseIdentityFromText - libellés français (nouvelle CNI)', () {
    test('extrait les champs à partir des libellés', () {
      final text = [
        'REPUBLIQUE FRANCAISE',
        'CARTE NATIONALE D\'IDENTITE',
        'NOM : DUPONT',
        'PRENOM : ANDREA',
        "N° : 2201234565",
        'DATE DE NAISSANCE : 09/01/1990',
      ].join('\n');
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.lastName, 'Dupont');
      expect(data.firstName, 'Andrea');
      expect(data.documentNumber, '2201234565');
      expect(data.birthDate, DateTime(1990, 1, 9));
      expect(data.isEmpty, isFalse);
    });

    test('normalise les accents des libellés', () {
      final text = [
        'PRÉNOM : MARIÉ-LEA',
        'NOM : LÉVÊQUE',
      ].join('\n');
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.lastName, 'Leveque');
      expect(data.firstName, 'Marie Lea');
    });

    test('extrait une date de naissance au format JJ/MM/AA', () {
      const text = 'DATE DE NAISSANCE : 09/01/90';
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.birthDate, DateTime(1990, 1, 9));
    });
  });

  group('parseIdentityFromText - cas limites', () {
    test('retourne des données vides sur un texte sans information', () {
      final data =
          extractor.parseIdentityFromText('Bonjour, ceci n\'est rien.', now: now);
      expect(data.isEmpty, isTrue);
      expect(data.foundCount, 0);
      expect(data.lastName, isNull);
      expect(data.firstName, isNull);
      expect(data.documentNumber, isNull);
      expect(data.birthDate, isNull);
      expect(data.expiryDate, isNull);
    });

    test('compte uniquement les champs renseignés', () {
      const text = 'NOM : DUPONT';
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.lastName, 'Dupont');
      expect(data.foundCount, 1);
    });

    test('ignore un numéro trop court (faux positif)', () {
      const text = 'NOM : DU\nN° : 12';
      final data = extractor.parseIdentityFromText(text, now: now);
      expect(data.documentNumber, isNull);
    });
  });
}
