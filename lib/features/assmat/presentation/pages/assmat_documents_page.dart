import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'assmat_new_contract_page.dart';

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

class _DocumentsList extends StatefulWidget {
  const _DocumentsList({required this.assmatUid});

  final String assmatUid;

  @override
  State<_DocumentsList> createState() => _DocumentsListState();
}

class _DocumentsListState extends State<_DocumentsList> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractsQuery = FirebaseFirestore.instance
        .collection('contracts')
        .where('assmatUid', isEqualTo: widget.assmatUid)
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

        // ── Compute stats ──────────────────────────────────────────────────
        double totalMonthly = 0;
        int activeCount = docs.length;
        final childNames = <String>{};

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final contractData =
              data['contractData'] as Map<String, dynamic>?;
          final contrat =
              contractData?['contrat'] as Map<String, dynamic>?;
          final raw = contrat?['salaireMensuel'] as String? ?? '';
          final clean = raw.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.');
          totalMonthly += double.tryParse(clean) ?? 0;
          final enfant = contractData?['enfant'] as Map<String, dynamic>?;
          final childName = enfant?['prenom'] as String? ?? '';
          if (childName.isNotEmpty) childNames.add(childName);
        }

        // ── Filter ─────────────────────────────────────────────────────────
        final filtered = _query.isEmpty
            ? docs
            : docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final contractData =
                    data['contractData'] as Map<String, dynamic>?;
                final employer =
                    contractData?['employeur'] as Map<String, dynamic>?;
                final enfant =
                    contractData?['enfant'] as Map<String, dynamic>?;
                final employerName =
                    '${employer?['prenom'] ?? ''} ${employer?['nom'] ?? ''}'
                        .trim()
                        .toLowerCase();
                final childName =
                    (enfant?['prenom'] as String? ?? '').toLowerCase();
                final q = _query.toLowerCase();
                return employerName.contains(q) || childName.contains(q);
              }).toList();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Header ────────────────────────────────────────────────────
            Text(
              'Contrats CDI',
              style: AppTextStyles.headlineMedium
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Convention collective IDCC 3239 — Assistant maternel agréé',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── CTA ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AssMatNewContractPage(),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nouveau contrat CDI'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: AppTextStyles.labelLarge
                      .copyWith(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Stats ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _PageStatCard(
                    icon: Icons.work_outline_rounded,
                    iconColor: AppColors.primary,
                    value: '$activeCount',
                    label: 'Contrats actifs',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PageStatCard(
                    icon: Icons.euro_rounded,
                    iconColor: AppColors.primary,
                    value: '${totalMonthly.toStringAsFixed(0)} €',
                    label: 'Total mensuel',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PageStatCard(
                    icon: Icons.child_friendly_outlined,
                    iconColor: AppColors.accent,
                    value: '${childNames.length}',
                    label: 'Enfants accueillis',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Search ────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: AppShadows.sm,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher par famille ou enfant...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.secondaryText),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.secondaryText, size: 22),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Contract list ─────────────────────────────────────────────
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Center(
                  child: Text(
                    _query.isEmpty ? 'Aucun contrat signé' : 'Aucun contrat trouvé',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
              )
            else
              ...filtered.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final contractData =
                    data['contractData'] as Map<String, dynamic>?;
                final employer =
                    contractData?['employeur'] as Map<String, dynamic>?;
                final enfant =
                    contractData?['enfant'] as Map<String, dynamic>?;
                final employerName =
                    '${employer?['prenom'] ?? ''} ${employer?['nom'] ?? ''}'
                        .trim();
                final childName =
                    enfant?['prenom'] as String? ?? 'un enfant';
                final pdfUrl = data['pdfUrl'] as String?;
                final finalPdfUrl = data['finalPdfUrl'] as String?;
                final contractType =
                    data['contractType'] as String? ?? 'engagement';
                final generatedAt = (data['finalizedAt'] as String?) ??
                    data['updatedAt'] as String?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Card(
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
                          if (generatedAt != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 14,
                                      color: AppColors.secondaryText),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Généré le ${_formatDate(generatedAt)}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (contractType == 'cdi' && finalPdfUrl != null)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: () => launchUrl(
                                  Uri.parse(finalPdfUrl),
                                  mode: LaunchMode.externalApplication,
                                ),
                                icon: const Icon(Icons.download_rounded,
                                    size: 18),
                                label: const Text(
                                  'Contrat de travail CDI',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                          else ...[
                            if (pdfUrl != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => launchUrl(
                                      Uri.parse(pdfUrl),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                    icon: const Icon(
                                        Icons.description_outlined,
                                        size: 18),
                                    label: Text(
                                      contractType == 'cdi'
                                          ? 'Contrat de travail CDI'
                                          : 'Contrat d\'engagement réciproque',
                                      style: const TextStyle(fontSize: 13),
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
                                  icon: const Icon(Icons.download_rounded,
                                      size: 18),
                                  label: const Text(
                                    'Contrat de travail CDI',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

// ─── Stat card ─────────────────────────────────────────────────────────────────

class _PageStatCard extends StatelessWidget {
  const _PageStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

String _formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso);
    return DateFormat('dd/MM/yyyy').format(dt);
  } catch (_) {
    return iso;
  }
}
