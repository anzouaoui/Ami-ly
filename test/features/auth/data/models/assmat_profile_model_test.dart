import 'package:amily/features/auth/data/models/assmat_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final futureDate = now.add(const Duration(days: 365));
  final pastDate = now.subtract(const Duration(days: 365));

  AssmatProfileModel _baseProfile({
    bool isIdentityVerified = true,
    DateTime? identityDocumentExpiry,
    DateTime? accreditationExpiry,
    String? criminalRecordUrl,
    IdentityDocumentType? identityDocumentType,
    bool includeFront = true,
    String frontUrl = 'https://example.com/doc.jpg',
    bool includeBack = true,
    String backUrl = 'https://example.com/doc-back.jpg',
  }) {
    final isCni = identityDocumentType == IdentityDocumentType.cni ||
        identityDocumentType == null;
    return AssmatProfileModel(
      uid: 'test-uid',
      createdAt: now,
      isIdentityVerified: isIdentityVerified,
      identityDocumentType: identityDocumentType ?? IdentityDocumentType.cni,
      identityDocumentUrl: includeFront ? frontUrl : null,
      identityDocumentUrlBack: isCni && includeBack ? backUrl : null,
      identityDocumentExpiry: identityDocumentExpiry,
      accreditationExpiry: accreditationExpiry,
      criminalRecordUrl: criminalRecordUrl,
      criminalRecordUploadedAt: now,
    );
  }

  group('isFullyVerified', () {
    test('retourne true quand tous les champs sont valides', () {
      final profile = _baseProfile(
        isIdentityVerified: true,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      expect(profile.isFullyVerified, isTrue);
    });

    test('retourne false quand le document d\'identité est expiré', () {
      final profile = _baseProfile(
        isIdentityVerified: true,
        identityDocumentExpiry: pastDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false quand l\'agrément est expiré', () {
      final profile = _baseProfile(
        isIdentityVerified: true,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: pastDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false quand le casier judiciaire est manquant', () {
      final profile = _baseProfile(
        isIdentityVerified: true,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: null,
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false quand le casier judiciaire est une chaîne vide', () {
      final profile = _baseProfile(
        isIdentityVerified: true,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: '',
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false quand l\'identité n\'est pas vérifiée', () {
      final profile = _baseProfile(
        isIdentityVerified: false,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false quand la date d\'expiration du document est null', () {
      final profile = _baseProfile(
        isIdentityVerified: true,
        identityDocumentExpiry: null,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false quand la date d\'expiration de l\'agrément est null', () {
      final profile = _baseProfile(
        isIdentityVerified: true,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: null,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false pour une CNI sans verso', () {
      final profile = _baseProfile(
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
        includeBack: false,
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false pour une CNI avec un verso vide', () {
      final profile = _baseProfile(
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
        backUrl: '',
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne true pour un passeport sans verso (un seul document)', () {
      final profile = _baseProfile(
        identityDocumentType: IdentityDocumentType.passeport,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      expect(profile.isFullyVerified, isTrue);
    });

    test('retourne false pour un passeport sans recto', () {
      final profile = _baseProfile(
        identityDocumentType: IdentityDocumentType.passeport,
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
        includeFront: false,
      );
      expect(profile.isFullyVerified, isFalse);
    });

    test('retourne false quand aucun champ n\'est renseigné (profil initial)', () {
      final profile = AssmatProfileModel(
        uid: 'test-uid',
        createdAt: now,
      );
      expect(profile.isFullyVerified, isFalse);
    });
  });

  group('AssmatProfileModel - serialization identity fields', () {
    test('copyWith préserve les champs identity', () {
      final original = _baseProfile(
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      final copied = original.copyWith(firstName: 'Marie');
      expect(copied.identityDocumentType, IdentityDocumentType.cni);
      expect(copied.identityDocumentUrl, 'https://example.com/doc.jpg');
      expect(copied.identityDocumentUrlBack, 'https://example.com/doc-back.jpg');
      expect(copied.identityDocumentExpiry, futureDate);
      expect(copied.criminalRecordUrl, 'https://example.com/casier.jpg');
      expect(copied.criminalRecordUploadedAt, now);
    });

    test('copyWith efface les champs identity quand les flags clear sont true', () {
      final original = _baseProfile(
        identityDocumentExpiry: futureDate,
        accreditationExpiry: futureDate,
        criminalRecordUrl: 'https://example.com/casier.jpg',
      );
      final cleared = original.copyWith(
        clearIdentityDocumentUrl: true,
        clearIdentityDocumentUrlBack: true,
        clearIdentityDocumentExpiry: true,
        clearCriminalRecordUrl: true,
        clearCriminalRecordUploadedAt: true,
      );
      expect(cleared.identityDocumentUrl, isNull);
      expect(cleared.identityDocumentUrlBack, isNull);
      expect(cleared.identityDocumentExpiry, isNull);
      expect(cleared.criminalRecordUrl, isNull);
      expect(cleared.criminalRecordUploadedAt, isNull);
    });

    test('IdentityDocumentType.fromKey retourne le bon type', () {
      expect(IdentityDocumentType.fromKey('cni'), IdentityDocumentType.cni);
      expect(IdentityDocumentType.fromKey('passeport'), IdentityDocumentType.passeport);
      expect(IdentityDocumentType.fromKey(null), isNull);
      expect(IdentityDocumentType.fromKey('inconnu'), isNull);
    });

    test('IdentityDocumentType.label retourne le libellé humain', () {
      expect(IdentityDocumentType.cni.label, 'Carte nationale d\'identité');
      expect(IdentityDocumentType.passeport.label, 'Passeport');
    });
  });
}
