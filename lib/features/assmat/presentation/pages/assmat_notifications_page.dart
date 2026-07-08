import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../contract/data/models/contract_model.dart';
import 'assmat_sign_contract_page.dart';

class AssmatNotificationsPage extends ConsumerWidget {
  const AssmatNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stream = FirebaseFirestore.instance
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
          'Notifications',
          style: AppTextStyles.titleMedium,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream.snapshots(),
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
                  const Icon(Icons.notifications_none_rounded,
                      size: 64, color: AppColors.secondaryText),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucune notification',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Les demandes de signature apparaîtront ici',
                    style: AppTextStyles.bodySmall.copyWith(
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
              final employer =
                  contractData?['employeur'] as Map<String, dynamic>?;
              final enfant =
                  contractData?['enfant'] as Map<String, dynamic>?;
              final employerName =
                  '${employer?['prenom'] ?? ''} ${employer?['nom'] ?? ''}'.trim();
              final childName = enfant?['prenom'] as String? ?? 'un enfant';
              final updatedAt = data['updatedAt'] as String? ?? '';
              final timeAgo = _formatTimeAgo(updatedAt);

              return _NotificationCard(
                employerName: employerName,
                childName: childName,
                timeAgo: timeAgo,
                contractId: doc.id,
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeAgo(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return "À l'instant";
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.employerName,
    required this.childName,
    required this.timeAgo,
    required this.contractId,
  });

  final String employerName;
  final String childName;
  final String timeAgo;
  final String contractId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demande de signature',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$employerName souhaite finaliser le contrat pour l'accueil de $childName",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (timeAgo.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AssmatSignContractPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Signer le document'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
