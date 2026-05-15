import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/data/models/assmat_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/favorites_provider.dart';
import '../widgets/childminder_card.dart';

// ─── Internal view-model ──────────────────────────────────────────────────────

class _PracticalItem {
  const _PracticalItem(this.icon, this.label, {this.color});
  final IconData icon;
  final String label;
  final Color? color;
}

/// Convertit un mois en libellé lisible (ex: 3 mois, 1 an, 2 ans).
String _monthsLabel(int months) {
  if (months < 12) return '$months mois';
  final years = months ~/ 12;
  return '$years an${years > 1 ? 's' : ''}';
}

/// Construit la liste des infos pratiques affichables depuis le modèle Firestore.
List<_PracticalItem> _practicalItems(AssmatProfileModel m) => [
      if (m.availableSlots > 0)
        _PracticalItem(
          Icons.check_circle_outline_rounded,
          '${m.availableSlots} place${m.availableSlots > 1 ? 's' : ''} disponible${m.availableSlots > 1 ? 's' : ''}',
          color: AppColors.primary,
        )
      else
        const _PracticalItem(
          Icons.cancel_outlined,
          'Complet — aucune place disponible',
        ),
      if (m.ageGroupMax > 0)
        _PracticalItem(
          Icons.child_care_rounded,
          'Enfants de ${_monthsLabel(m.ageGroupMin)} à ${_monthsLabel(m.ageGroupMax)}',
        ),
      if (m.hourlyRate > 0)
        _PracticalItem(
          Icons.euro_rounded,
          '${m.hourlyRate.toStringAsFixed(2)} €/heure',
        ),
    ];

// ─── Page ─────────────────────────────────────────────────────────────────────

class ChildminderProfilePage extends ConsumerStatefulWidget {
  const ChildminderProfilePage({super.key, required this.data});
  final ChildminderSummary data;

  @override
  ConsumerState<ChildminderProfilePage> createState() =>
      _ChildminderProfilePageState();
}

class _ChildminderProfilePageState
    extends ConsumerState<ChildminderProfilePage> {
  @override
  Widget build(BuildContext context) {
    final asyncProfile =
        ref.watch(assmatProfileByUidProvider(widget.data.uid));
    final favoriteIds = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
    final isFavorite = favoriteIds.contains(widget.data.uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    color: AppColors.primaryText,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Expanded(
                    child: Text(
                      'Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => toggleFavorite(ref, widget.data.uid),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 22,
                      color: isFavorite
                          ? Colors.redAccent
                          : AppColors.secondaryText,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // ── Body scrollable ───────────────────────────────────────────
            Expanded(
              child: asyncProfile.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Impossible de charger le profil.\n$e',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (profile) {
                  if (profile == null) {
                    return const Center(
                      child: Text('Profil introuvable.'),
                    );
                  }
                  return _ProfileBody(
                    summary: widget.data,
                    profile: profile,
                  );
                },
              ),
            ),

            // ── CTA toujours visible en bas ───────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messagerie — à venir'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 18),
                      label: const Text('Envoyer un message'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        textStyle: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Le tarif horaire sera discuté lors de votre échange',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile body ─────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.summary, required this.profile});
  final ChildminderSummary summary;
  final AssmatProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final items = _practicalItems(profile);
    final hasBio = profile.bio.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identité
            _IdentityCard(summary: summary, profile: profile),
            const SizedBox(height: AppSpacing.md),

            // Stats
            _StatsRow(profile: profile),
            const SizedBox(height: AppSpacing.md),

            // Infos pratiques
            if (items.isNotEmpty) ...[
              _PracticalInfoCard(items: items),
              const SizedBox(height: AppSpacing.md),
            ],

            // Présentation (bio)
            if (hasBio) ...[
              _SectionCard(
                icon: Icons.menu_book_rounded,
                title: 'Présentation',
                child: Text(
                  profile.bio,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText, height: 1.6),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Disponibilités (places)
            _SlotsCard(profile: profile),
          ],
        ),
      ),
    );
  }
}

// ─── Identity card ────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.summary, required this.profile});
  final ChildminderSummary summary;
  final AssmatProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final isPro = profile.subscriptionPlan == 'pro';
    final fullName =
        '${profile.firstName} ${profile.lastName}'.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + PRO badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  summary.initials,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isPro)
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // Infos texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Assistante maternelle' : fullName,
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.place_outlined,
                          size: 14, color: AppColors.secondaryText),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        profile.address.isNotEmpty
                            ? profile.address
                            : 'Adresse non renseignée',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    'à ${summary.distance} de chez vous',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.hint, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final AssmatProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final experience = profile.yearsExperience > 0
        ? '${profile.yearsExperience} an${profile.yearsExperience > 1 ? 's' : ''}'
        : '—';

    final places = '${profile.availableSlots}/${profile.maxChildren}';

    final ageGroup = profile.ageGroupMax > 0
        ? '${_monthsLabel(profile.ageGroupMin)} - ${_monthsLabel(profile.ageGroupMax)}'
        : '—';

    return Row(
      children: [
        Expanded(
          child: _StatCell(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.primary,
            label: 'Expérience',
            value: experience,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCell(
            icon: Icons.face_rounded,
            iconColor: AppColors.accent,
            label: 'Places',
            value: places,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCell(
            icon: Icons.child_care_rounded,
            iconColor: AppColors.primary,
            label: 'Âge accepté',
            value: ageGroup,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText, fontSize: 11),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Practical info card ──────────────────────────────────────────────────────

class _PracticalInfoCard extends StatelessWidget {
  const _PracticalInfoCard({required this.items});
  final List<_PracticalItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Text(
              'Informations pratiques',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...items.map((item) {
            final fg = item.color ?? AppColors.secondaryText;
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Icon(item.icon, size: 16, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: fg,
                        fontWeight: item.color != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

// ─── Slots card ───────────────────────────────────────────────────────────────

class _SlotsCard extends StatelessWidget {
  const _SlotsCard({required this.profile});
  final AssmatProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final slots = profile.availableSlots;
    final slotLabel =
        slots == 0 ? 'Aucune place disponible' : '$slots place${slots > 1 ? 's' : ''} disponible${slots > 1 ? 's' : ''}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Disponibilités',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _GreenBadge(
                  label: slotLabel,
                  available: slots > 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GreenBadge extends StatelessWidget {
  const _GreenBadge({required this.label, this.available = true});
  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.primary : AppColors.secondaryText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border:
            Border.all(color: color.withValues(alpha: available ? 0.35 : 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Generic section card ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.icon});
  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
