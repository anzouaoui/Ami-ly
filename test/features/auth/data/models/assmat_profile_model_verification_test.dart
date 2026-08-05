import 'package:amily/features/auth/data/models/assmat_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssmatProfileModel.computeVerificationStatus', () {
    final deadline = DateTime(2026, 9, 1, 12, 0, 0);

    VerificationStatus statusAt(DateTime now, VerificationStatus current) =>
        AssmatProfileModel.computeVerificationStatus(
          deadline: deadline,
          now: now,
          current: current,
        );

    test('reste pending tant que la deadline est loin (> J-15)', () {
      expect(
        statusAt(DateTime(2026, 8, 5), VerificationStatus.pending),
        VerificationStatus.pending,
      );
      expect(
        statusAt(DateTime(2026, 8, 15), VerificationStatus.pending),
        VerificationStatus.pending,
      );
    });

    test('pending → reminded15 à J-15', () {
      expect(
        statusAt(DateTime(2026, 8, 17), VerificationStatus.pending),
        VerificationStatus.reminded15,
      );
    });

    test('pending → reminded2 à J-2', () {
      expect(
        statusAt(DateTime(2026, 8, 30), VerificationStatus.pending),
        VerificationStatus.reminded2,
      );
    });

    test('reminded15 → reminded2 à J-2', () {
      expect(
        statusAt(DateTime(2026, 8, 30), VerificationStatus.reminded15),
        VerificationStatus.reminded2,
      );
    });

    test('reminded15 ne régresse pas vers pending', () {
      expect(
        statusAt(DateTime(2026, 8, 20), VerificationStatus.reminded15),
        VerificationStatus.reminded15,
      );
    });

    test('reminded2 ne régresse pas avant la deadline', () {
      expect(
        statusAt(DateTime(2026, 8, 20), VerificationStatus.reminded2),
        VerificationStatus.reminded2,
      );
      expect(
        statusAt(DateTime(2026, 8, 28), VerificationStatus.reminded2),
        VerificationStatus.reminded2,
      );
    });

    test('deadline dépassée → expired (depuis pending, reminded15 ou reminded2)',
        () {
      expect(
        statusAt(DateTime(2026, 9, 1, 12, 0, 1), VerificationStatus.pending),
        VerificationStatus.expired,
      );
      expect(
        statusAt(DateTime(2026, 9, 2), VerificationStatus.reminded15),
        VerificationStatus.expired,
      );
      expect(
        statusAt(DateTime(2026, 9, 2), VerificationStatus.reminded2),
        VerificationStatus.expired,
      );
    });

    test('verified est un état terminal', () {
      expect(
        statusAt(DateTime(2026, 8, 30), VerificationStatus.verified),
        VerificationStatus.verified,
      );
      expect(
        statusAt(DateTime(2026, 9, 30), VerificationStatus.verified),
        VerificationStatus.verified,
      );
    });

    test('expired est un état terminal', () {
      expect(
        statusAt(DateTime(2026, 9, 5), VerificationStatus.expired),
        VerificationStatus.expired,
      );
      expect(
        statusAt(DateTime(2026, 7, 1), VerificationStatus.expired),
        VerificationStatus.expired,
      );
    });
  });

  group('AssmatProfileModel.initial', () {
    test('verificationDeadline = createdAt + 30 jours', () {
      final before = DateTime.now();
      final profile = AssmatProfileModel.initial(uid: 'u1');
      final after = DateTime.now();

      final deadline = profile.verificationDeadline;
      expect(deadline, isNotNull);

      final minDeadline = before.add(AssmatProfileModel.verificationDeadlineDuration);
      final maxDeadline = after.add(AssmatProfileModel.verificationDeadlineDuration);
      expect(deadline!.isBefore(minDeadline), isFalse);
      expect(deadline.isAfter(maxDeadline), isFalse);
    });

    test('statut de vérification initial : pending', () {
      final profile = AssmatProfileModel.initial(uid: 'u1');
      expect(profile.verificationStatus, VerificationStatus.pending);
    });
  });
}
