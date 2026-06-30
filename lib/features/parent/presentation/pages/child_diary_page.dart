import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/child_model.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_navigation_drawer.dart';

/// Page "Journal de mon enfant" — rapports quotidiens envoyés par
/// l'assistante maternelle.
///
/// Frame "Child Diary" du design system :
///   - Header (menu + logo + spacer)
///   - Sous-titre "Rapport quotidien envoyé par votre assistante maternelle"
///   - Sélecteur de date : ← [date centrée avec icône calendrier] →
///   - Empty state card (grand, shadow md) : rond gris + document + titre +
///     message
///   - Bouton outlined "Contacter l'assistante"
///
/// Aucun rapport réel — tout est en empty state pour l'instant.
class ChildDiaryPage extends StatefulWidget {
  const ChildDiaryPage({super.key, this.childName});

  final String? childName;

  @override
  State<ChildDiaryPage> createState() => _ChildDiaryPageState();
}

class _ChildDiaryPageState extends State<ChildDiaryPage> {
  DateTime _date = DateTime.now();
  ChildModel? _selectedChild;
  bool _initialized = false;

  static const _weekdays = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  static const _months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  String get _formattedDate =>
      '${_weekdays[_date.weekday - 1]} ${_date.day} ${_months[_date.month - 1]} ${_date.year}';

  void _shift(int days) {
    setState(() => _date = _date.add(Duration(days: days)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _onContactAssmat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contacter l\'assistante — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final childrenAsync = ref.watch(childrenProvider);
        final children = childrenAsync.valueOrNull ?? [];

        if (children.isNotEmpty && !_initialized) {
          if (widget.childName != null) {
            _selectedChild = children.firstWhere(
              (c) => c.firstName.toLowerCase() == widget.childName!.toLowerCase(),
              orElse: () => children.first,
            );
          } else {
            _selectedChild = children.first;
          }
          _initialized = true;
        }

        final currentChildName = _selectedChild?.firstName ?? widget.childName;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: const ParentNavigationDrawer(),
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
                      0,
                    ),
                    child: children.isEmpty
                        ? Text(
                            'Journal de mon enfant',
                            style: AppTextStyles.headlineMedium,
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Journal de ', style: AppTextStyles.headlineMedium),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<ChildModel>(
                                    value: _selectedChild,
                                    isDense: true,
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                    items: children.map((c) {
                                      return DropdownMenuItem<ChildModel>(
                                        value: c,
                                        child: Text(c.firstName),
                                      );
                                    }).toList(),
                                    onChanged: (c) {
                                      if (c != null) {
                                        setState(() => _selectedChild = c);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Text(
                      'Rapport quotidien envoyé par votre assistante maternelle',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _DateSelector(
                      label: _formattedDate,
                      onPrevious: () => _shift(-1),
                      onNext: () => _shift(1),
                      onTapDate: _pickDate,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _EmptyReportCard(childName: currentChildName),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: _onContactAssmat,
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                      ),
                      label: const Text('Contacter l\'assistante'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
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
          Builder(
            builder: (ctx) {
              final canPop = Navigator.of(ctx).canPop();
              if (canPop) {
                return IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 28,
                    color: AppColors.primaryText,
                  ),
                  onPressed: () => Navigator.of(ctx).maybePop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Retour',
                );
              } else {
                return IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    size: 28,
                    color: AppColors.primaryText,
                  ),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Menu',
                );
              }
            },
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

/// Sélecteur de date : ← | [date + calendar] | →
class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onTapDate,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTapDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: InkWell(
            onTap: onTapDate,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.labelLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        width: 48,
        height: 48,
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

/// Empty state : grand card avec cercle gris + icône doc + titre + message.
class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard({this.childName});
  final String? childName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.md,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.secondaryText,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Pas de rapport',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Text(
                childName != null
                    ? 'Aucun rapport n\'a été envoyé pour $childName pour cette journée.'
                    : 'Aucun rapport n\'a été envoyé pour cette journée.',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
