import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/data/models/parent_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../messaging/providers/messaging_providers.dart';
import '../../../parent/data/models/child_model.dart';
import '../../data/models/parent_with_children.dart';
import '../../presentation/pages/assmat_chat_page.dart';
import '../providers/assmat_search_providers.dart';

/// Page "Parents en recherche" pour les assistantes maternelles.
///
/// Branchée sur Firestore : récupère les parents actifs (searchPaused == false)
/// avec leurs enfants, et permet une recherche par ville.
class SearchParentsPage extends ConsumerStatefulWidget {
  const SearchParentsPage({super.key});

  @override
  ConsumerState<SearchParentsPage> createState() => _SearchParentsPageState();
}

class _SearchParentsPageState extends ConsumerState<SearchParentsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assmatProfile = ref.watch(assmatProfileProvider).valueOrNull;
    final parentsAsync =
        ref.watch(searchableParentsWithChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Container(
                width: 32,
                height: 32,
                color: const Color(0xFF4A3B33),
                child: const Icon(Icons.family_restroom,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('AMiLY',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        size: 28, color: AppColors.secondaryText),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Parents en recherche',
                        style: AppTextStyles.headlineMedium
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Consultez les familles qui recherchent une assistante maternelle '
                  'et envoyez une demande de contact',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),

          // Search card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: AppShadows.sm,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par ville...',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.secondaryText),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.secondaryText, size: 22),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  parentsAsync.when(
                    loading: () => const _StatusChip(
                      label: 'Chargement...',
                      dotColor: AppColors.secondaryText,
                      bgColor: AppColors.background,
                      textColor: AppColors.secondaryText,
                    ),
                    error: (_, __) => const _StatusChip(
                      label: 'Erreur de chargement',
                      dotColor: Colors.red,
                      bgColor: Color(0xFFFFEBEE),
                      textColor: Colors.red,
                    ),
                    data: (all) {
                      final filtered = _query.isEmpty
                          ? all
                          : all.where((p) =>
                              p.parent.address.toLowerCase().contains(_query) ||
                              '${p.parent.firstName} ${p.parent.lastName}'
                                  .toLowerCase()
                                  .contains(_query)).toList();
                      return _StatusChip(
                        label:
                            '${filtered.length} famille${filtered.length > 1 ? 's' : ''} en recherche',
                        dotColor: const Color(0xFF4CAF50),
                        bgColor: const Color(0xFFE8F5E9),
                        textColor: const Color(0xFF2E7D32),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Family list
          Expanded(
            child: parentsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Erreur : $e',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error),
                ),
              ),
              data: (all) {
                final filtered = _query.isEmpty
                    ? all
                    : all.where((p) =>
                        p.parent.address.toLowerCase().contains(_query) ||
                        '${p.parent.firstName} ${p.parent.lastName}'
                            .toLowerCase()
                            .contains(_query)).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isNotEmpty
                          ? 'Aucune famille trouvée pour « $_query »'
                          : 'Aucune famille en recherche actuellement',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => Consumer(
                    builder: (context, ref, _) => _FamilyCard(
                      parentWithChildren: filtered[i],
                      assmatProfile: assmatProfile,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Family card
// ---------------------------------------------------------------------------

class _FamilyCard extends ConsumerWidget {
  const _FamilyCard({
    required this.parentWithChildren,
    this.assmatProfile,
  });

  final ParentWithChildren parentWithChildren;
  // ignore: unused_element
  final Object? assmatProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = parentWithChildren;
    final p = w.parent;

    final displayName = '${p.firstName} ${p.lastName}'.trim();
    final initials = p.firstName.isNotEmpty ? p.firstName[0] : '?';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF3E5D8),
                child: Text(
                  initials.toUpperCase(),
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          displayName.isNotEmpty ? displayName : 'Parent',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const _StatusChip(
                          label: 'En recherche',
                          dotColor: Color(0xFF4CAF50),
                          bgColor: Color(0xFFE8F5E9),
                          textColor: Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            p.address.isNotEmpty ? p.address : 'Adresse non renseignée',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.secondaryText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Search criteria (from children data)
          Text(
            'CRITÈRES DE RECHERCHE',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          _CriteriaRow(
            icon: Icons.child_friendly_outlined,
            child: Text(
              '${w.children.length} enfant${w.children.length > 1 ? 's' : ''}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryText),
            ),
          ),

          // Children details
          if (w.children.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...w.children.map((k) => Padding(
              padding: EdgeInsets.only(bottom: k != w.children.last ? AppSpacing.sm : 0),
              child: _ChildCard(child: k),
            )),
          ],

          const SizedBox(height: AppSpacing.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openChat(context, ref, p, displayName),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Message'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    ParentProfileModel parent,
    String parentName,
  ) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final datasource = ref.read(messagingDatasourceProvider);
    final assmatProfile = ref.read(assmatProfileProvider).valueOrNull;
    final assmatName = assmatProfile != null
        ? '${assmatProfile.firstName} ${assmatProfile.lastName}'.trim()
        : currentUser.displayName ?? 'Assistante maternelle';

    final result = await datasource.getOrCreateConversation(
      parentUid: parent.uid,
      assmatUid: currentUser.uid,
      parentName: parentName.isNotEmpty ? parentName : 'Parent',
      assmatName: assmatName,
    );

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssMatChatPage(
            contact: ChatContact(
              name: parentName.isNotEmpty ? parentName : 'Parent',
              initials: parentName.isNotEmpty
                  ? parentName.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join()
                  : 'P',
            ),
            conversationId: result.convId,
          ),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.dotColor,
    required this.bgColor,
    required this.textColor,
  });

  final String label;
  final Color dotColor;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  const _CriteriaRow({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child});
  final ChildModel child;

  String _ageLabel(DateTime? birthDate) {
    if (birthDate == null) return '';
    final now = DateTime.now();
    final totalMonths =
        (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (totalMonths < 0) return '';
    if (totalMonths < 2) return '$totalMonths mois';
    if (totalMonths < 24) return '$totalMonths mois';
    final years = totalMonths ~/ 12;
    return '$years an${years > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F5),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.child_friendly_outlined,
                size: 20, color: Color(0xFFE07A5F)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText),
                    children: [
                      TextSpan(
                        text: child.firstName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (child.birthDate != null) ...[
                        TextSpan(
                          text: '  (${_ageLabel(child.birthDate)})',
                          style: const TextStyle(color: AppColors.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                if (child.interests.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    child.interests.join('   '),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
