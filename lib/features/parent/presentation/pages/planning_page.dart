import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/stat_card.dart';

/// Onglet sélectionné dans la page Planning.
enum PlanningTab { weekly, yearly, leaves }

/// Page "Planning" — horaires + congés de l'assistante maternelle.
///
/// Frame "Planning" du design system :
///   - Header + sous-titre
///   - 3 tabs : Planning semaine / Calendrier annuel / Congés assmat
///   - Sélecteur de semaine ← "Semaine du 13 avr. au 17 avr." / "avril 2026" →
///   - 2 boutons d'action : Appliquer à la semaine / Export PDF
///   - Chip "0h / semaine"
///   - 3 stat cards : Total semaine / Estimation mois / Moyenne par jour
///   - Empty state : grande carte avec icône + CTA "+ Ajouter un horaire"
///   - Vue hebdo bas : 5 jours avec heures
///
/// Seul l'onglet "Planning semaine" affiche du contenu pour l'instant.
class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  PlanningTab _tab = PlanningTab.weekly;

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  'Consultez le planning et les congés de votre assistante maternelle',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: _TabBar(
                  active: _tab,
                  onChanged: (t) => setState(() => _tab = t),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sélecteur de semaine
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: _WeekSelector(
                  primaryLabel: 'Semaine du 13 avr. au 17 avr.',
                  secondaryLabel: 'avril 2026',
                  onPrevious: () => _stub('Semaine précédente'),
                  onNext: () => _stub('Semaine suivante'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Boutons d'action
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _stub('Appliquer à la semaine'),
                        icon: const Icon(
                          Icons.content_copy_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Appliquer à la semaine',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _stub('Export PDF'),
                        icon: const Icon(
                          Icons.download_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Export PDF',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Chip résumé semaine
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _WeekSummaryChip(hours: '0h / semaine'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats 3 cards
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.schedule_rounded,
                        iconBg: AppColors.secondary,
                        iconColor: AppColors.primary,
                        value: '0h',
                        label: 'Total semaine',
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        icon: Icons.calendar_month_rounded,
                        iconBg: AppColors.statBlueBg,
                        iconColor: AppColors.statBlueColor,
                        value: '0h',
                        label: 'Estimation mois',
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        icon: Icons.bar_chart_rounded,
                        iconBg: AppColors.statYellowBg,
                        iconColor: AppColors.accent,
                        value: '0.0h',
                        label: 'Moyenne / jour',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Empty state card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: _EmptyWeekCard(
                  onAddSchedule: () => _stub('Ajouter un horaire'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Vue hebdo (5 jours)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _WeeklyDaysRow(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header : back + logo "AMiLY" + spacer.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 28,
              color: AppColors.primaryText,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Retour',
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.child_care_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AMiLY',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// Segmented control 3 onglets.
class _TabBar extends StatelessWidget {
  const _TabBar({required this.active, required this.onChanged});
  final PlanningTab active;
  final ValueChanged<PlanningTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Planning semaine',
            isActive: active == PlanningTab.weekly,
            onTap: () => onChanged(PlanningTab.weekly),
          ),
          _TabItem(
            label: 'Calendrier annuel',
            isActive: active == PlanningTab.yearly,
            onTap: () => onChanged(PlanningTab.yearly),
          ),
          _TabItem(
            label: 'Congés assmat',
            isActive: active == PlanningTab.leaves,
            onTap: () => onChanged(PlanningTab.leaves),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              boxShadow: isActive ? AppShadows.sm : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive
                    ? AppColors.primaryText
                    : AppColors.secondaryText,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sélecteur de semaine : ← [2 lignes] →
class _WeekSelector extends StatelessWidget {
  const _WeekSelector({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrevious,
    required this.onNext,
  });
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ChevronButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  primaryLabel,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  secondaryLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _ChevronButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        width: 48,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 24, color: AppColors.primaryText),
      ),
    );
  }
}

/// Pill "0h / semaine" avec icône horloge.
class _WeekSummaryChip extends StatelessWidget {
  const _WeekSummaryChip({required this.hours});
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            hours,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state : cercle horloge + texte + CTA.
class _EmptyWeekCard extends StatelessWidget {
  const _EmptyWeekCard({required this.onAddSchedule});
  final VoidCallback onAddSchedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun horaire cette semaine',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ajoutez vos premiers créneaux de garde.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAddSchedule,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Ajouter un horaire'),
          ),
        ],
      ),
    );
  }
}

/// Vue hebdo : 5 jours Lun–Ven avec heures 0.0h.
class _WeeklyDaysRow extends StatelessWidget {
  const _WeeklyDaysRow();

  static const _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final day in _days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
              ),
              child: _DayCell(label: day),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '0.0h',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
