// ignore_for_file: subtype_of_sealed_class
import 'package:amily/core/services/firebase_service.dart';
import 'package:amily/features/contract/data/models/contract_form_data.dart';
import 'package:amily/features/contract/data/services/contract_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockSnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockDoc extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  test('findDraft restaure l\'enfant choisi (childId)', () async {
    final firestore = _MockFirestore();
    final contracts = _MockCollection();
    final byParent = _MockQuery();
    final byAssmat = _MockQuery();
    final byStatus = _MockQuery();
    final limited = _MockQuery();
    final snap = _MockSnapshot();
    final doc = _MockDoc();

    when(() => firestore.collection('contracts')).thenReturn(contracts);
    when(() => contracts.where('parentUid', isEqualTo: 'p1'))
        .thenReturn(byParent);
    when(() => byParent.where('assmatUid', isEqualTo: 'a1'))
        .thenReturn(byAssmat);
    when(() => byAssmat.where('status', whereIn: any(named: 'whereIn')))
        .thenReturn(byStatus);
    when(() => byStatus.limit(1)).thenReturn(limited);
    when(() => limited.get()).thenAnswer((_) async => snap);
    when(() => snap.docs).thenReturn([doc]);
    when(() => doc.id).thenReturn('contract-1');
    when(() => doc.data()).thenReturn({
      'status': 'draft',
      'currentStep': 3,
      'contractData': ContractFormData(
        childId: 'child-42',
        childFirstName: 'Léo',
      ).toJson(),
    });

    final service = ContractService(
      firebaseService: FirebaseService(
        auth: _MockAuth(),
        firestore: firestore,
        storage: _MockStorage(),
      ),
    );

    final draft = await service.findDraft(parentUid: 'p1', assmatUid: 'a1');

    expect(draft, isNotNull);
    expect(draft!.id, 'contract-1');
    expect(draft.step, 3);
    expect(draft.formData.childId, 'child-42');
    expect(draft.formData.childFirstName, 'Léo');
  });
}
