import 'package:amily/features/contract/data/models/contract_form_data.dart';
import 'package:amily/features/contract/data/models/contract_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContractModel — champs DocuSign (documents signés)', () {
    test('toFirestore enregistre les métadonnées du PDF signé', () {
      final signedAt = DateTime.utc(2026, 8, 6, 10, 0, 0);
      final model = ContractModel(
        id: 'contract-42',
        parentUid: 'parent-1',
        assmatUid: 'assmat-1',
        status: ContractStatus.signed,
        docusignEnvelopeId: 'env-123',
        docusignStatus: 'completed',
        finalPdfUrl: 'https://storage/contrat_finalise.pdf',
        finalPdfPath: 'contracts/contract-42/contrat_finalise.pdf',
        finalizedAt: signedAt,
        parentSignedAt: signedAt,
        assmatSignedAt: signedAt,
        contractData: ContractFormData(
          prenomEmployeur: 'Julie',
          nomEmployeur: 'Durand',
        ),
      );

      final json = model.toFirestore();

      expect(json['status'], 'signed');
      expect(json['docusignEnvelopeId'], 'env-123');
      expect(json['docusignStatus'], 'completed');
      expect(json['finalPdfUrl'], 'https://storage/contrat_finalise.pdf');
      expect(json['finalPdfPath'], 'contracts/contract-42/contrat_finalise.pdf');
      expect(json['finalizedAt'], '2026-08-06T10:00:00.000Z');
      expect(json['parentSignedAt'], '2026-08-06T10:00:00.000Z');
    });

    test('parseContractDate gère Timestamp, String ISO et DateTime', () {
      final now = DateTime.utc(2026, 8, 6);
      expect(
        ContractModel.parseContractDate(Timestamp.fromDate(now))
            ?.toUtc(),
        now,
      );
      expect(
        ContractModel.parseContractDate('2026-08-06T10:00:00.000Z'),
        DateTime.utc(2026, 8, 6, 10),
      );
      expect(ContractModel.parseContractDate(now), now);
      expect(ContractModel.parseContractDate(null), isNull);
      expect(ContractModel.parseContractDate('pas-une-date'), isNull);
    });

    test('copyWith modifie et efface les champs DocuSign', () {
      final model = ContractModel(
        id: 'contract-42',
        parentUid: 'parent-1',
        assmatUid: 'assmat-1',
      );

      final updated = model.copyWith(
        status: ContractStatus.signed,
        docusignEnvelopeId: 'env-123',
        docusignStatus: 'completed',
        finalPdfUrl: 'https://storage/contrat_finalise.pdf',
        finalPdfPath: 'contracts/contract-42/contrat_finalise.pdf',
        finalizedAt: DateTime.utc(2026, 8, 6),
      );

      expect(updated.status, ContractStatus.signed);
      expect(updated.docusignEnvelopeId, 'env-123');
      expect(updated.docusignStatus, 'completed');
      expect(updated.finalPdfUrl, 'https://storage/contrat_finalise.pdf');
      expect(updated.finalPdfPath, 'contracts/contract-42/contrat_finalise.pdf');
      expect(updated.finalizedAt, DateTime.utc(2026, 8, 6));

      final cleared = updated.copyWith(clearFinalPdfUrl: true);
      expect(cleared.finalPdfUrl, isNull);
    });

    test('le statut signed est un statut valide du modèle', () {
      expect(ContractStatus.values, contains(ContractStatus.signed));
    });
  });
}
