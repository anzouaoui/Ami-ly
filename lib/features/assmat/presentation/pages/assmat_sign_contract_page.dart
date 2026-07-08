import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../contract/data/models/contract_form_data.dart';
import '../../../contract/data/models/contract_model.dart';
import '../../../contract/data/models/signature_audit_model.dart';
import '../../../contract/data/services/contract_service.dart';
import '../../../contract/presentation/widgets/in_app_signature_widget.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/notification_service.dart';

class AssmatSignContractPage extends ConsumerWidget {
  const AssmatSignContractPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final assmat = ref.watch(assmatProfileProvider).valueOrNull;

    if (user == null || assmat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Signature contrat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final contractsQuery = FirebaseFirestore.instance
        .collection('contracts')
        .where('assmatUid', isEqualTo: user.uid)
        .where('status', whereIn: [ContractStatus.pendingAssmat.name])
        .orderBy('updatedAt', descending: true);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Contrats à signer',
          style: AppTextStyles.titleMedium,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: contractsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.error}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 64, color: AppColors.success),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucun contrat en attente de signature',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final contractData = data['contractData'] as Map<String, dynamic>?;
              final formData = contractData != null
                  ? _parseFormData(contractData)
                  : null;

              return _ContractCard(
                id: doc.id,
                formData: formData,
                assmatFirstName: assmat.firstName,
                assmatLastName: assmat.lastName,
                assmatUid: user.uid,
                contractType: data['contractType'] as String? ?? 'engagement',
                pdfUrl: data['pdfUrl'] as String?,
              );
            },
          );
        },
      ),
    );
  }

  ContractFormData _parseFormData(Map<String, dynamic> json) {
    final employer = json['employeur'] as Map<String, dynamic>? ?? {};
    final salarie = json['salarie'] as Map<String, dynamic>? ?? {};
    final enfant = json['enfant'] as Map<String, dynamic>? ?? {};
    final contrat = json['contrat'] as Map<String, dynamic>? ?? {};

    return ContractFormData(
      civiliteEmployeur: employer['civilite'] as String? ?? '',
      typeEmployeur: employer['type'] as String? ?? '',
      nomEmployeur: employer['nom'] as String? ?? '',
      prenomEmployeur: employer['prenom'] as String? ?? '',
      adresseEmployeur: employer['adresse'] as String? ?? '',
      villeEmployeur: employer['ville'] as String? ?? '',
      cpEmployeur: employer['cp'] as String? ?? '',
      telEmployeur: employer['telephone'] as String? ?? '',
      emailEmployeur: employer['email'] as String? ?? '',
      civiliteSalarie: salarie['civilite'] as String? ?? '',
      nomSalarie: salarie['nom'] as String? ?? '',
      prenomSalarie: salarie['prenom'] as String? ?? '',
      adresseSalarie: salarie['adresse'] as String? ?? '',
      villeSalarie: salarie['ville'] as String? ?? '',
      cpSalarie: salarie['cp'] as String? ?? '',
      telSalarie: salarie['telephone'] as String? ?? '',
      emailSalarie: salarie['email'] as String? ?? '',
      childFirstName: enfant['prenom'] as String? ?? '',
      prenomEnfant: enfant['prenomComplet'] as String? ?? '',
      nomEnfant: enfant['nom'] as String? ?? '',
      dateNaissanceEnfant: enfant['dateNaissance'] as String? ?? '',
      dateDebut: contrat['dateDebut'] as String? ?? '',
      dateEmbauche: contrat['dateEmbauche'] as String? ?? '',
      finContrat: contrat['finContrat'] as String? ?? '',
      periodeEssai: contrat['periodeEssai'] as String? ?? '',
      heuresSemaine: contrat['heuresSemaine'] as String? ?? '',
      heuresMois: contrat['heuresMois'] as String? ?? '',
      semainesAn: contrat['semainesAn'] as String? ?? '',
      salaireMensuel: contrat['salaireMensuel'] as String? ?? '',
      salaireHoraire: contrat['salaireHoraire'] as String? ?? '',
    );
  }
}

class _ContractCard extends ConsumerWidget {
  const _ContractCard({
    required this.id,
    required this.formData,
    required this.assmatFirstName,
    required this.assmatLastName,
    required this.assmatUid,
    required this.contractType,
    this.pdfUrl,
  });

  final String id;
  final ContractFormData? formData;
  final String assmatFirstName;
  final String assmatLastName;
  final String assmatUid;
  final String contractType;
  final String? pdfUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employerName = formData != null
        ? '${formData!.prenomEmployeur} ${formData!.nomEmployeur}'.trim()
        : 'Parent';
    final childName = formData?.childFirstName.isNotEmpty == true
        ? formData!.childFirstName
        : formData?.prenomEnfant.isNotEmpty == true
            ? formData!.prenomEnfant
            : 'un enfant';
    final isEngagement = contractType == 'engagement';
    final documentLabel = isEngagement
        ? 'Engagement réciproque'
        : 'Contrat CDI';

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '$documentLabel — $employerName',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isEngagement
                  ? 'Accueil de $childName'
                  : 'CDI — Accueil de $childName',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'En attente de votre signature',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formData != null
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _AssmatSignContractDetailPage(
                              contractId: id,
                              formData: formData!,
                              assmatFirstName: assmatFirstName,
                              assmatLastName: assmatLastName,
                              assmatUid: assmatUid,
                              employerName: employerName,
                              contractType: contractType,
                              pdfUrl: pdfUrl,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                child: const Text('Signer le contrat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssmatSignContractDetailPage extends ConsumerWidget {
  const _AssmatSignContractDetailPage({
    required this.contractId,
    required this.formData,
    required this.assmatFirstName,
    required this.assmatLastName,
    required this.assmatUid,
    required this.employerName,
    required this.contractType,
    this.pdfUrl,
  });

  final String contractId;
  final ContractFormData formData;
  final String assmatFirstName;
  final String assmatLastName;
  final String assmatUid;
  final String employerName;
  final String contractType;
  final String? pdfUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childName = formData.childFirstName.isNotEmpty
        ? formData.childFirstName
        : formData.prenomEnfant.isNotEmpty
            ? formData.prenomEnfant
            : 'l\'enfant';
    final isEngagement = contractType == 'engagement';
    final documentLabel = isEngagement ? "l'engagement réciproque" : 'le contrat CDI';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEngagement ? "Signer l'engagement" : 'Signer le contrat',
            style: AppTextStyles.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildContractSummary(),
            if (pdfUrl != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(pdfUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Voir le document'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            InAppSignatureWidget(
              parentFirstName: assmatFirstName,
              parentLastName: assmatLastName,
              parentUid: assmatUid,
              assmatName: employerName,
              contractFormData: formData,
              customTitle: isEngagement
                  ? "Signature de l'engagement réciproque"
                  : 'Signature du contrat CDI',
              customDescription:
                  'En signant, vous acceptez les termes $documentLabel '
                  'avec $employerName pour l\'accueil de $childName.',
              onSigned: (result) async {
                final firebaseService = ref.read(firebaseServiceProvider);
                final service =
                    ContractService(firebaseService: firebaseService);
                final ip = await ContractService.getPublicIp();

                await service.finalizeAssmatSignature(
                  contractId: contractId,
                  signedName: result.signedName,
                  ipAddress: ip,
                );

                final audit = SignatureAuditModel(
                  uid: assmatUid,
                  role: 'assmat',
                  signedName: result.signedName,
                  ipAddress: ip,
                  method: 'typed_name',
                  consentText: result.consentText,
                );
                await service.saveSignature(
                    contractId: contractId, audit: audit);

                // Notification au parent
                try {
                  final contractDoc = await FirebaseFirestore.instance
                      .collection('contracts')
                      .doc(contractId)
                      .get();
                  final parentUid =
                      contractDoc.data()?['parentUid'] as String? ?? '';
                  if (parentUid.isNotEmpty) {
                    final notifService =
                        ref.read(notificationServiceProvider);
                    await notifService.createNotification(
                      recipientUid: parentUid,
                      senderUid: assmatUid,
                      type: 'assmat_signed',
                      contractId: contractId,
                      title: isEngagement
                          ? "Engagement réciproque signé"
                          : 'Contrat signé',
                      body: isEngagement
                          ? "L'assistante maternelle a signé l'engagement réciproque."
                          : "L'assistante maternelle a signé le contrat CDI.",
                    );
                  }
                } catch (_) {
                  // Échec notification non bloquant
                }

                // Génération du PDF finalisé si les deux parties ont signé
                try {
                  await service.generateFinalizedPdf(
                    contractId: contractId,
                    formData: formData,
                    contractType: isEngagement ? 'engagement' : 'cdi',
                  );
                } catch (_) {
                  // Échec génération PDF non bloquant
                }

                  if (context.mounted) {
                  final docLabel = isEngagement ? "l'engagement" : 'le contrat';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$docLabel signé avec succès !'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              onError: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.accent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractSummary() {
    final employeeName =
        '${formData.prenomSalarie} ${formData.nomSalarie}'.trim();
    final childName = formData.childFirstName.isNotEmpty
        ? formData.childFirstName
        : formData.prenomEnfant.isNotEmpty
            ? formData.prenomEnfant
            : 'l\'enfant';
    final localIsEngagement = contractType == 'engagement';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localIsEngagement
                ? "Récapitulatif de l'engagement réciproque"
                : 'Récapitulatif du contrat',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _summaryRow('Employeur', employerName),
          _summaryRow('Assistante maternelle', employeeName),
          _summaryRow('Enfant', childName),
          if (formData.dateDebut.isNotEmpty)
            _summaryRow('Date de début', formData.dateDebut),
          if (formData.salaireMensuel.isNotEmpty)
            _summaryRow('Salaire mensuel', '${formData.salaireMensuel} €'),
          if (formData.heuresSemaine.isNotEmpty)
            _summaryRow('Heures / semaine', '${formData.heuresSemaine} h'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
