import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatDocumentsPage extends ConsumerWidget {
  const AssMatDocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

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
          'Mes contrats',
          style: AppTextStyles.titleMedium,
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _DocumentsList(assmatUid: user.uid),
    );
  }
}

class _DocumentsList extends StatelessWidget {
  const _DocumentsList({required this.assmatUid});

  final String assmatUid;

  @override
  Widget build(BuildContext context) {
    final contractsQuery = FirebaseFirestore.instance
        .collection('contracts')
        .where('assmatUid', isEqualTo: assmatUid)
        .where('status', isEqualTo: 'active')
        .orderBy('updatedAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
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
                const Icon(Icons.description_outlined,
                    size: 64, color: AppColors.secondaryText),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Aucun contrat signé',
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
            final contractData =
                data['contractData'] as Map<String, dynamic>?;
            final employer = contractData?['employeur'] as Map<String, dynamic>?;
            final enfant = contractData?['enfant'] as Map<String, dynamic>?;
            final employerName =
                '${employer?['prenom'] ?? ''} ${employer?['nom'] ?? ''}'.trim();
            final childName = enfant?['prenom'] as String? ?? 'un enfant';
            final pdfUrl = data['pdfUrl'] as String?;
            final finalPdfUrl = data['finalPdfUrl'] as String?;

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
                        const Icon(Icons.check_circle_rounded,
                            size: 20, color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            employerName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Accueil de $childName',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (pdfUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => launchUrl(
                              Uri.parse(pdfUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                            icon: const Icon(Icons.description_outlined, size: 18),
                            label: const Text(
                              'Contrat d\'engagement réciproque',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    if (finalPdfUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () => launchUrl(
                            Uri.parse(finalPdfUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text(
                            'Contrat de travail CDI',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

