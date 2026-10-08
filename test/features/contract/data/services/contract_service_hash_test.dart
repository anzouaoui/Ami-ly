import 'package:amily/core/services/firebase_service.dart';
import 'package:amily/features/contract/data/services/contract_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockStorage extends Mock implements FirebaseStorage {}

/// Test de caractérisation : fige la sortie actuelle de [computePdfHash],
/// déjà persistée en base (`pdfHash`, `finalPdfHash`). Toute modification
/// de l'algorithme doit être volontaire et migrer les hash existants.
void main() {
  final service = ContractService(
    firebaseService: FirebaseService(
      auth: _MockAuth(),
      firestore: _MockFirestore(),
      storage: _MockStorage(),
    ),
  );

  test('computePdfHash est stable', () {
    expect(service.computePdfHash([]), _hashOfEmpty);
    expect(service.computePdfHash([1, 2, 3, 250]), _hashOf1234);
    expect(
      service.computePdfHash(List<int>.generate(1000, (i) => i % 256)),
      _hashOf1000,
    );
  });
}

// Valeurs relevées avant refactoring. NB : ce ne sont pas des SHA-256
// standards (le SHA-256 de '' vaut e3b0c442…) : l'implémentation maison
// diverge de la norme, mais ces hash sont déjà stockés.
const _hashOfEmpty =
    '361ab6322fa9e7a7bb23818d839e01bddafdf47305426edd297aedb9f6202bae';
const _hashOf1234 =
    '1f2ce1b51439bf3ea0611413f6f939a4bb94bb5908ec38432899d3dbfc663524';
const _hashOf1000 =
    'cb70c700b624ce516b1f31b2d8ec0def1e3c3471dc4f9343d877f93cb4bcdd9a';
