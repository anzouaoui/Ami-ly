import 'package:amily/core/utils/address_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBANAddress - adresse bien formée', () {
    test('découpe adresse, code postal et ville', () {
      final result = parseBANAddress('25 Avenue Franklin D. Roosevelt, 75008 Paris');
      expect(result.street, '25 Avenue Franklin D. Roosevelt');
      expect(result.postalCode, '75008');
      expect(result.city, 'Paris');
    });

    test('gère les espaces autour des segments', () {
      final result = parseBANAddress('  25 Avenue Franklin D. Roosevelt ,  75008 Paris  ');
      expect(result.street, '25 Avenue Franklin D. Roosevelt');
      expect(result.postalCode, '75008');
      expect(result.city, 'Paris');
    });

    test('gère un code postal commençant par zéro', () {
      final result = parseBANAddress('3 Rue des Mimosas, 06200 Nice');
      expect(result.street, '3 Rue des Mimosas');
      expect(result.postalCode, '06200');
      expect(result.city, 'Nice');
    });
  });

  group('parseBANAddress - adresse sans code postal', () {
    test('retourne l\'adresse complète et des champs ville/CP vides', () {
      const address = '25 Avenue Franklin D. Roosevelt';
      final result = parseBANAddress(address);
      expect(result.street, address);
      expect(result.postalCode, '');
      expect(result.city, '');
    });
  });

  group('parseBANAddress - adresse vide', () {
    test('retourne des champs vides', () {
      final result = parseBANAddress('');
      expect(result.street, '');
      expect(result.postalCode, '');
      expect(result.city, '');
    });

    test('retourne des champs vides pour une adresse d\'espaces', () {
      final result = parseBANAddress('   ');
      expect(result.street, '');
      expect(result.postalCode, '');
      expect(result.city, '');
    });
  });

  group('parseBANAddress - adresse avec plusieurs virgules', () {
    test('conserve la voie en plusieurs segments et découpe le CP/ville', () {
      final result = parseBANAddress('Résidence Les Lilas, Bâtiment B, 75008 Paris');
      expect(result.street, 'Résidence Les Lilas, Bâtiment B');
      expect(result.postalCode, '75008');
      expect(result.city, 'Paris');
    });
  });

  group('parseBANAddress - adresse mal formée', () {
    test('adresse non BAN : retourne l\'adresse complète', () {
      const address = 'Chez M. Dupont, Paris';
      final result = parseBANAddress(address);
      expect(result.street, address);
      expect(result.postalCode, '');
      expect(result.city, '');
    });

    test('dernier segment sans code postal : retourne l\'adresse complète', () {
      const address = 'Résidence Les Lilas, Bâtiment B, Paris';
      final result = parseBANAddress(address);
      expect(result.street, address);
      expect(result.postalCode, '');
      expect(result.city, '');
    });

    test('ne lève jamais d\'exception', () {
      expect(() => parseBANAddress(''), returnsNormally);
      expect(() => parseBANAddress(','), returnsNormally);
      expect(() => parseBANAddress('75008'), returnsNormally);
    });
  });
}
