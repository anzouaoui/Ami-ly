import 'package:amily/features/auth/data/models/assmat_profile_model.dart';
import 'package:amily/shared/widgets/unverified_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AssmatProfileModel profile({
    bool identityVerified = true,
    bool accreditationCertified = true,
    DateTime? identityDocumentExpiry,
    DateTime? accreditationExpiry,
    String? criminalRecordUrl,
  }) {
    return AssmatProfileModel(
      uid: 'assmat-1',
      createdAt: DateTime(2026),
      isIdentityVerified: identityVerified,
      isAccreditationCertified: accreditationCertified,
      identityDocumentExpiry: identityDocumentExpiry,
      accreditationExpiry: accreditationExpiry,
      criminalRecordUrl: criminalRecordUrl,
    );
  }

  group('isAssmatFullyVerified', () {
    test('retourne false quand le profil est null', () {
      expect(isAssmatFullyVerified(null), isFalse);
    });

    test('retourne true quand tout est vérifié', () {
      final p = profile(
        identityDocumentExpiry: DateTime.now().add(const Duration(days: 365)),
        accreditationExpiry: DateTime.now().add(const Duration(days: 365)),
        criminalRecordUrl: 'https://storage/casier.jpg',
      );
      expect(isAssmatFullyVerified(p), isTrue);
    });

    test('retourne false quand l\'identité n\'est pas vérifiée', () {
      final p = profile(identityVerified: false);
      expect(isAssmatFullyVerified(p), isFalse);
    });

    test('retourne false quand le casier judiciaire manque', () {
      final p = profile(accreditationExpiry: DateTime.now().add(const Duration(days: 365)));
      expect(isAssmatFullyVerified(p), isFalse);
    });

    test('retourne false quand l\'agrément est expiré', () {
      final p = profile(
        accreditationExpiry: DateTime.now().subtract(const Duration(days: 1)),
        criminalRecordUrl: 'https://storage/casier.jpg',
      );
      expect(isAssmatFullyVerified(p), isFalse);
    });
  });

  group('computeMissingAssmatVerification', () {
    test('liste les trois éléments quand le profil est null', () {
      final issues = computeMissingAssmatVerification(null);
      expect(issues, hasLength(3));
      expect(issues, containsAll(AssmatVerificationIssue.values));
    });

    test('ne liste aucun élément quand tout est vérifié', () {
      final p = profile(
        identityDocumentExpiry: DateTime.now().add(const Duration(days: 365)),
        accreditationExpiry: DateTime.now().add(const Duration(days: 365)),
        criminalRecordUrl: 'https://storage/casier.jpg',
      );
      expect(computeMissingAssmatVerification(p), isEmpty);
    });

    test('liste uniquement les éléments manquants', () {
      // Identité vérifiée, agrément valide, mais casier judiciaire absent.
      final p = profile(
        identityDocumentExpiry: DateTime.now().add(const Duration(days: 365)),
        accreditationExpiry: DateTime.now().add(const Duration(days: 365)),
      );
      final issues = computeMissingAssmatVerification(p);
      expect(issues, isNot(contains(AssmatVerificationIssue.identity)));
      expect(issues, isNot(contains(AssmatVerificationIssue.accreditation)));
      expect(issues, contains(AssmatVerificationIssue.criminalRecord));
      expect(issues, hasLength(1));
    });

    test('liste l\'identité quand elle n\'est pas vérifiée', () {
      final p = profile(
        identityVerified: false,
        identityDocumentExpiry: DateTime.now().add(const Duration(days: 365)),
        accreditationExpiry: DateTime.now().add(const Duration(days: 365)),
      );
      final issues = computeMissingAssmatVerification(p);
      expect(issues, contains(AssmatVerificationIssue.identity));
      expect(issues, isNot(contains(AssmatVerificationIssue.accreditation)));
      expect(issues, contains(AssmatVerificationIssue.criminalRecord));
    });
  });

  group('Blocage de création de contrat', () {
    Widget harness({
      required AssmatProfileModel? profile,
      required bool isAssmatSide,
      VoidCallback? onCompleteProfile,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  final allowed = await ensureAssmatVerifiedForContract(
                    context: context,
                    isAssmatSide: isAssmatSide,
                    profile: profile,
                    onCompleteProfile: onCompleteProfile,
                  );
                  if (allowed && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('CONTRACT_CREATED')),
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Créer le contrat'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('bloque la création et affiche la modale quand non vérifiée',
        (tester) async {
      await tester.pumpWidget(
        harness(
          profile: profile(identityVerified: false),
          isAssmatSide: false,
        ),
      );

      await tester.tap(find.text('Créer le contrat'));
      await tester.pumpAndSettle();

      expect(find.byType(UnverifiedProfileSheet), findsOneWidget);
      expect(find.text('Compris'), findsOneWidget);
      expect(find.text('CONTRACT_CREATED'), findsNothing);

      await tester.tap(find.text('Compris'));
      await tester.pumpAndSettle();
      expect(find.byType(UnverifiedProfileSheet), findsNothing);
      expect(find.text('CONTRACT_CREATED'), findsNothing);
    });

    testWidgets('autorise la création quand le profil est vérifié',
        (tester) async {
      await tester.pumpWidget(
        harness(
          profile: profile(
            identityDocumentExpiry:
                DateTime.now().add(const Duration(days: 365)),
            accreditationExpiry: DateTime.now().add(const Duration(days: 365)),
            criminalRecordUrl: 'https://storage/casier.jpg',
          ),
          isAssmatSide: false,
        ),
      );

      await tester.tap(find.text('Créer le contrat'));
      await tester.pumpAndSettle();

      expect(find.text('CONTRACT_CREATED'), findsOneWidget);
      expect(find.byType(UnverifiedProfileSheet), findsNothing);
    });

    testWidgets(
        'propose de compléter le profil (CTA assmat) quand non vérifiée',
        (tester) async {
      var completed = false;
      await tester.pumpWidget(
        harness(
          profile: profile(criminalRecordUrl: null),
          isAssmatSide: true,
          onCompleteProfile: () => completed = true,
        ),
      );

      await tester.tap(find.text('Créer le contrat'));
      await tester.pumpAndSettle();

      expect(find.text('Compléter mon profil'), findsOneWidget);
      await tester.tap(find.text('Compléter mon profil'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(find.text('CONTRACT_CREATED'), findsNothing);
    });
  });
}
