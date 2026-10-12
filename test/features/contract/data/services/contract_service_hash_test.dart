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

void main() {
  final service = ContractService(
    firebaseService: FirebaseService(
      auth: _MockAuth(),
      firestore: _MockFirestore(),
      storage: _MockStorage(),
    ),
  );

  test('computePdfHash est un SHA-256 standard des octets bruts', () {
    expect(
      service.computePdfHash([]),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    expect(
      service.computePdfHash('abc'.codeUnits),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  // Caractérisation : fige l'ancien calcul, dont les hash sont déjà
  // persistés sur les contrats sans champ `pdfHashAlgorithm`.
  test('computeLegacyPdfHash est stable', () {
    expect(service.computeLegacyPdfHash([]), _hashOfEmpty);
    expect(service.computeLegacyPdfHash([1, 2, 3, 250]), _hashOf1234);
    expect(
      service.computeLegacyPdfHash(List<int>.generate(1000, (i) => i % 256)),
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
