import 'package:amily/core/utils/name_initials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initialsOf prend les deux premiers mots non vides', () {
    expect(initialsOf('marie dupont'), 'MD');
    expect(initialsOf('  Jean   Pierre Martin'), 'JP');
    expect(initialsOf('Léa'), 'L');
    expect(initialsOf(''), '');
  });
}
