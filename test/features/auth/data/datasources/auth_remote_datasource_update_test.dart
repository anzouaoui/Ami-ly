import 'package:amily/core/services/firebase_service.dart';
import 'package:amily/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseService extends Mock implements FirebaseService {}

// ignore: subtype_of_sealed_class
class _MockDocRef extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late _MockFirebaseService firebase;
  late _MockDocRef doc;
  late AuthRemoteDataSource datasource;

  setUp(() {
    firebase = _MockFirebaseService();
    doc = _MockDocRef();
    when(() => firebase.assmatDoc(any())).thenReturn(doc);
    when(() => firebase.parentDoc(any())).thenReturn(doc);
    when(() => doc.update(any())).thenAnswer((_) async {});
    datasource = AuthRemoteDataSource(firebase);
  });

  Map<Object, Object?> capturedUpdate() =>
      verify(() => doc.update(captureAny())).captured.single
          as Map<Object, Object?>;

  test('updateAssmatCompliance : effacement, valeur, ou champ ignoré', () async {
    final expiry = DateTime(2030, 1, 2);

    await datasource.updateAssmatCompliance(
      uid: 'u1',
      identityDocumentType: 'cni',
      identityDocumentUrl: 'https://front',
      clearIdentityDocumentUrlBack: true,
      identityDocumentExpiry: expiry,
      // clear prioritaire sur la valeur
      criminalRecordUrl: 'https://ignored',
      clearCriminalRecordUrl: true,
      isIdentityVerified: false,
    );

    final update = capturedUpdate();
    expect(update.keys, {
      'identityDocumentType',
      'identityDocumentUrl',
      'identityDocumentUrlBack',
      'identityDocumentExpiry',
      'criminalRecordUrl',
      'isIdentityVerified',
    });
    expect(update['identityDocumentType'], 'cni');
    expect(update['identityDocumentUrl'], 'https://front');
    expect(update['identityDocumentUrlBack'], isA<FieldValue>());
    expect(update['identityDocumentExpiry'], Timestamp.fromDate(expiry));
    expect(update['criminalRecordUrl'], isA<FieldValue>());
    expect(update['isIdentityVerified'], false);
  });

  test('updateParentProfile : location absente si ni valeur ni clear',
      () async {
    await datasource.updateParentProfile(
      uid: 'u1',
      firstName: 'A',
      lastName: 'B',
      phoneNumber: '06',
      address: 'adr',
      familyDescription: 'desc',
      searchPaused: false,
    );

    final update = capturedUpdate();
    expect(update.containsKey('location'), isFalse);
    expect(update['firstName'], 'A');
    expect(update['updatedAt'], isA<DateTime>());
  });
}
