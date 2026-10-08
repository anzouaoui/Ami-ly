import 'package:amily/features/contract/data/models/contract_form_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson est l\'inverse de toJson', () {
    final data = ContractFormData(
      nomEmployeur: 'Durand',
      prenomSalarie: 'Anne',
      childId: 'child-1',
      childFirstName: 'Léo',
      semainesAn: '46',
      planningRemis: true,
      jfTravaille15Aout: true,
      congesVersement: 'juin',
      faitA: 'Lyon',
    );

    final roundTrip = ContractFormData.fromJson(data.toJson());

    expect(roundTrip.toJson(), data.toJson());
  });

  test('fromJson applique les valeurs par défaut sur un json vide', () {
    final data = ContractFormData.fromJson(const {});

    expect(data.civiliteEmployeur, '');
    expect(data.idccCode, '3239');
    expect(data.childId, isNull);
    expect(data.planningRemis, isFalse);
  });
}
