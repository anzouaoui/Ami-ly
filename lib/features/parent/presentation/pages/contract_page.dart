import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/profile_form_field.dart';

/// Onglets de la page Contrat & Déclarations.
enum _ContractTab { contract, caf, pajemploi, endOfContract }

/// Page "Contrat & Déclarations" — gestion des contrats CDI avec l'assistante
/// maternelle.
///
/// Frames "Contracts Screen" → "Contract 3" du design system (fusionnées) :
///   - Header + title + subtitle
///   - Tabs : Contrat (actif) / CAF / Pajemploi / Fin de contrat
///   - Section "Nouveau contrat CDI" + convention collective
///   - Carte dépliable "Particulier employeur" (10 champs)
///   - Carte dépliable "Assistant maternel" (champs + 2 sous-sections assurance)
///   - Carte dépliable "Enfant & engagement" (3 champs)
///
/// Seul l'onglet "Contrat" a du contenu — les 3 autres afficheront des
/// placeholders (à compléter quand leurs specs arriveront).
class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  _ContractTab _tab = _ContractTab.contract;

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

              // Title + subtitle
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contrat & Déclarations',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Gérez vos contrats, simulez vos aides CAF et préparez vos déclarations Pajemploi',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
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

              // Contenu selon le tab
              if (_tab == _ContractTab.contract)
                const _ContractTabContent()
              else
                const _OtherTabPlaceholder(),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header : back + logo centré + cloche notifications.
class _Header extends StatelessWidget {
  const _Header();

  void _onNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 24,
              color: AppColors.primaryText,
            ),
            onPressed: () => _onNotifications(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}

/// TabBar horizontal scrollable (4 onglets, l'actif se distingue par fond blanc
/// + shadow sm).
class _TabBar extends StatelessWidget {
  const _TabBar({required this.active, required this.onChanged});
  final _ContractTab active;
  final ValueChanged<_ContractTab> onChanged;

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
            label: 'Contrat',
            icon: Icons.description_rounded,
            isActive: active == _ContractTab.contract,
            onTap: () => onChanged(_ContractTab.contract),
          ),
          _TabItem(
            label: 'CAF',
            icon: Icons.calculate_rounded,
            isActive: active == _ContractTab.caf,
            onTap: () => onChanged(_ContractTab.caf),
          ),
          _TabItem(
            label: 'Pajemploi',
            icon: Icons.account_balance_rounded,
            isActive: active == _ContractTab.pajemploi,
            onTap: () => onChanged(_ContractTab.pajemploi),
          ),
          _TabItem(
            label: 'Fin',
            icon: Icons.event_busy_rounded,
            isActive: active == _ContractTab.endOfContract,
            onTap: () => onChanged(_ContractTab.endOfContract),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final IconData icon;
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
              horizontal: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              boxShadow: isActive ? AppShadows.sm : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.secondaryText,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenu de l'onglet "Contrat" : titre + 3 cartes dépliables.
class _ContractTabContent extends StatelessWidget {
  const _ContractTabContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre section
          Text(
            'Nouveau contrat CDI',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Convention collective IDCC 3239 — Assistant maternel agréé',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Carte Particulier employeur
          const _ExpandableCard(
            icon: Icons.person_rounded,
            title: 'Particulier employeur',
            children: _ParticulierEmployeurForm(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Carte Assistant maternel
          const _ExpandableCard(
            icon: Icons.badge_rounded,
            title: 'Assistant maternel',
            children: _AssistantMaternelForm(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Carte Enfant & engagement
          const _ExpandableCard(
            icon: Icons.child_care_rounded,
            title: 'Enfant & engagement',
            children: _EnfantEngagementForm(),
            initiallyExpanded: false,
          ),
          const SizedBox(height: AppSpacing.md),

          // Carte Durée et horaires d'accueil
          const _ExpandableCard(
            icon: Icons.schedule_rounded,
            title: 'Durée et horaires d\'accueil',
            children: _HorairesForm(),
            initiallyExpanded: false,
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary heures / semaine
          const _WeekHoursSummary(
            totalHours: '50h/semaine',
            maxHours: '48h/semaine',
          ),
          const SizedBox(height: AppSpacing.md),

          // Délai de prévenance
          const ProfileFormField(
            label: 'Délai de prévenance (semaines)',
            initialValue: '2',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),

          // Carte Rémunération
          const _ExpandableCard(
            icon: Icons.euro_rounded,
            title: 'Rémunération',
            children: _RemunerationForm(),
            initiallyExpanded: false,
          ),
          const SizedBox(height: AppSpacing.md),

          // Récapitulatif Salaire
          const _SalaryRecapSection(),
          const SizedBox(height: AppSpacing.lg),

          // CTAs empilés : Enregistrer brouillon (primary) + Étape suivante (outlined)
          FilledButton.icon(
            onPressed: () => _onSaveDraft(context),
            icon: const Icon(Icons.save_outlined, size: 20),
            label: const Text('Enregistrer le brouillon'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _onNextStep(context),
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            label: const Text('Étape suivante'),
          ),
        ],
      ),
    );
  }

  void _onSaveDraft(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Brouillon enregistré'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onNextStep(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Étape suivante — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _OtherTabPlaceholder extends StatelessWidget {
  const _OtherTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 48,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bientôt disponible',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte dépliable : header icône + titre + chevron rotatif, body animé
/// via [AnimatedCrossFade].
class _ExpandableCard extends StatefulWidget {
  const _ExpandableCard({
    required this.icon,
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
  });

  final IconData icon;
  final String title;
  final Widget children;
  final bool initiallyExpanded;

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0 : -0.5,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body animé
          AnimatedCrossFade(
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: widget.children,
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Formulaires des 3 cartes (séparés pour lisibilité)
// -----------------------------------------------------------------

class _ParticulierEmployeurForm extends StatelessWidget {
  const _ParticulierEmployeurForm();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1 : Nom de naissance + Nom d'usage
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileFormField(
                label: 'Nom de naissance',
                required: true,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProfileFormField(
                label: 'Nom d\'usage',
                initialValue: 'ZOUAOUI',
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Row 2 : Prénom (full)
        ProfileFormField(
          label: 'Prénom',
          required: true,
          initialValue: 'Anouk',
        ),
        SizedBox(height: AppSpacing.md),

        // Row 3 : Adresse (full)
        ProfileFormField(label: 'Adresse'),
        SizedBox(height: AppSpacing.md),

        // Row 4 : Ville + Code postal
        Row(
          children: [
            Expanded(child: ProfileFormField(label: 'Ville')),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ProfileFormField(label: 'Code postal')),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Row 5 : Téléphone + Email
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileFormField(
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_rounded,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProfileFormField(
                label: 'Email',
                initialValue: 'anoukzouaoui9!',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Row 6 : En qualité de + N° Pajemploi
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileFormField(
                label: 'En qualité de',
                required: true,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ProfileFormField(label: 'N° Pajemploi')),
          ],
        ),
      ],
    );
  }
}

class _AssistantMaternelForm extends StatelessWidget {
  const _AssistantMaternelForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileFormField(
                label: 'Nom de naissance',
                required: true,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ProfileFormField(label: 'Nom d\'usage')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(label: 'Prénom', required: true),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(label: 'Adresse'),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Expanded(child: ProfileFormField(label: 'Ville')),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ProfileFormField(label: 'Code postal')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Expanded(
              child: ProfileFormField(
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_rounded,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProfileFormField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(label: 'N° de Sécurité sociale'),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Expanded(child: ProfileFormField(label: 'Référence de l\'agrément')),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProfileFormField(
                label: 'Date de délivrance',
                hintText: 'JJ/MM/AAAA',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(
          label: 'Date du dernier renouvellement',
          hintText: 'JJ/MM/AAAA',
        ),

        // Sous-section Assurance RC Pro
        const SizedBox(height: AppSpacing.lg),
        const _SubSectionHeader(
          icon: Icons.verified_user_rounded,
          title: 'Assurance RC Pro',
        ),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(
          label: 'Compagnie',
          hintText: 'Compagnie d\'assurance',
        ),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(label: 'N° de police'),

        // Sous-section Assurance auto
        const SizedBox(height: AppSpacing.lg),
        const _SubSectionHeader(
          icon: Icons.directions_car_rounded,
          title: 'Assurance auto',
        ),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(
          label: 'Compagnie',
          hintText: 'Compagnie d\'assurance',
        ),
        const SizedBox(height: AppSpacing.md),
        const ProfileFormField(label: 'N° de police'),
      ],
    );
  }
}

class _EnfantEngagementForm extends StatelessWidget {
  const _EnfantEngagementForm();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ProfileFormField(label: 'Nom', required: true)),
        SizedBox(width: AppSpacing.md),
        Expanded(child: ProfileFormField(label: 'Prénom', required: true)),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: ProfileFormField(
            label: 'Date naissance',
            hintText: 'JJ/MM/AAAA',
          ),
        ),
      ],
    );
  }
}

/// En-tête de sous-section dans une carte : icône + titre.
class _SubSectionHeader extends StatelessWidget {
  const _SubSectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTextStyles.labelLarge),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Carte "Durée et horaires d'accueil"
// -----------------------------------------------------------------

/// Modèle d'un créneau journalier (mock UI).
class _DaySchedule {
  const _DaySchedule({
    required this.active,
    required this.start,
    required this.end,
  });

  final bool active;
  final TimeOfDay start;
  final TimeOfDay end;

  _DaySchedule copyWith({
    bool? active,
    TimeOfDay? start,
    TimeOfDay? end,
  }) => _DaySchedule(
        active: active ?? this.active,
        start: start ?? this.start,
        end: end ?? this.end,
      );
}

class _HorairesForm extends StatefulWidget {
  const _HorairesForm();

  @override
  State<_HorairesForm> createState() => _HorairesFormState();
}

class _HorairesFormState extends State<_HorairesForm> {
  static const _contractOptions = [
    'Cas n°1 — 52 semaines (congés payés inclus)',
    'Cas n°2 — 46 semaines ou moins',
  ];
  String _selectedContract = _contractOptions[0];

  static const _dayNames = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  // Défaut : lundi-vendredi 08:00-18:00 actifs, weekend inactif.
  late final Map<String, _DaySchedule> _schedule = {
    for (final d in _dayNames)
      d: _DaySchedule(
        active: !(d == 'Samedi' || d == 'Dimanche'),
        start: const TimeOfDay(hour: 8, minute: 0),
        end: const TimeOfDay(hour: 18, minute: 0),
      ),
  };

  void _toggleDay(String day) {
    setState(() {
      final current = _schedule[day]!;
      _schedule[day] = current.copyWith(active: !current.active);
    });
  }

  Future<void> _pickTime(String day, {required bool isStart}) async {
    final current = _schedule[day]!;
    final initial = isStart ? current.start : current.end;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      _schedule[day] = isStart
          ? current.copyWith(start: picked)
          : current.copyWith(end: picked);
    });
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Planning enregistré'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Type de contrat
        Text('Type de contrat', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: _selectedContract,
          items: [
            for (final opt in _contractOptions)
              DropdownMenuItem(
                value: opt,
                child: Text(opt, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => setState(() => _selectedContract = v!),
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Planning hebdomadaire
        Text(
          'Planning hebdomadaire',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        for (final day in _dayNames) ...[
          _DayRow(
            day: day,
            schedule: _schedule[day]!,
            onToggle: () => _toggleDay(day),
            onPickStart: () => _pickTime(day, isStart: true),
            onPickEnd: () => _pickTime(day, isStart: false),
          ),
          if (day != _dayNames.last)
            const Divider(height: AppSpacing.md, color: AppColors.divider),
        ],

        const SizedBox(height: AppSpacing.lg),

        // CTA "Enregistrer le planning"
        FilledButton.icon(
          onPressed: _onSave,
          icon: const Icon(Icons.save_outlined, size: 20),
          label: const Text('Enregistrer le planning'),
        ),
      ],
    );
  }
}

/// Ligne d'un jour : icône d'état (✓ actif / ○ inactif) + nom + 2 time pickers.
class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.schedule,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String day;
  final _DaySchedule schedule;
  final VoidCallback onToggle;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Toggle icône
        InkWell(
          onTap: onToggle,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(
              schedule.active
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: schedule.active
                  ? AppColors.success
                  : AppColors.secondaryText,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Nom du jour
        SizedBox(
          width: 72,
          child: Text(
            day,
            style: AppTextStyles.bodyMedium.copyWith(
              color: schedule.active
                  ? AppColors.primaryText
                  : AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Time pickers (uniquement si actif)
        if (schedule.active) ...[
          Expanded(
            child: _TimeField(
              label: _format(schedule.start),
              onTap: onPickStart,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _TimeField(
              label: _format(schedule.end),
              onTap: onPickEnd,
            ),
          ),
        ] else
          const Expanded(child: SizedBox()),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Section Rémunération
// -----------------------------------------------------------------

/// Carte récap heures semaine : "Total : 50h/semaine" + "Max : 48h/semaine"
/// en rouge si dépassement.
class _WeekHoursSummary extends StatelessWidget {
  const _WeekHoursSummary({
    required this.totalHours,
    required this.maxHours,
  });

  final String totalHours;
  final String maxHours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryText,
                ),
                children: [
                  const TextSpan(text: 'Total : '),
                  TextSpan(
                    text: totalHours,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Max : $maxHours',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RemunerationForm extends StatefulWidget {
  const _RemunerationForm();

  @override
  State<_RemunerationForm> createState() => _RemunerationFormState();
}

class _RemunerationFormState extends State<_RemunerationForm> {
  bool _alsaceMoselle = false;
  bool _isBrut = true;

  static const _majAdditionnellesOptions = ['0 %', '5 %', '10 %'];
  String _majAdditionnelles = _majAdditionnellesOptions[0];

  static const _majSupplementairesOptions = ['25 %', '50 %'];
  String _majSupplementaires = _majSupplementairesOptions[0];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Alsace-Moselle toggle
        Row(
          children: [
            Expanded(
              child: Text('Alsace-Moselle ?', style: AppTextStyles.labelLarge),
            ),
            Switch(
              value: _alsaceMoselle,
              onChanged: (v) => setState(() => _alsaceMoselle = v),
              activeColor: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Taux horaire
        Text('Taux horaire', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        _BrutNetSegmented(
          isBrut: _isBrut,
          onChanged: (b) => setState(() => _isBrut = b),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: '4',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '€/h (${_isBrut ? 'brut' : 'net'})',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Majorations — 2 dropdowns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DropdownField(
                label: 'Maj. heures additionnelles',
                value: _majAdditionnelles,
                options: _majAdditionnellesOptions,
                onChanged: (v) =>
                    setState(() => _majAdditionnelles = v ?? '0 %'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DropdownField(
                label: 'Maj. heures supplémentaires',
                value: _majSupplementaires,
                options: _majSupplementairesOptions,
                onChanged: (v) =>
                    setState(() => _majSupplementaires = v ?? '25 %'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Résultats
        Text(
          'RÉSULTATS',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondaryText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _ResultCard(
          title: 'Heure classique',
          brut: '4,00',
          net: '3,12',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _ResultCard(
          title: 'Heure complémentaire (0% de majoration sur le brut)',
          brut: '4,00',
          net: '3,58',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _ResultCard(
          title: 'Heure supplémentaire incluse dans la mensualisation (non majorée)',
          brut: '4,00',
          net: '3,58',
        ),
        const SizedBox(height: AppSpacing.sm),
        // Min légal
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.error,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Min légal : 3,18 € net/h',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Titre "Salaire mensuel de base"
        Text(
          'Salaire mensuel de base',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Carte calcul mensuel
        const _MonthlyCalculationCard(
          formula: '4 € × 50h × 52 / 12',
          brutMensuel: '866,68 €',
          netMensuel: '676,00 €',
        ),
      ],
    );
  }
}

/// Segmented control Brut / Net (pattern repris des autres tabs).
class _BrutNetSegmented extends StatelessWidget {
  const _BrutNetSegmented({required this.isBrut, required this.onChanged});
  final bool isBrut;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          _SegItem(label: 'Brut', isActive: isBrut, onTap: () => onChanged(true)),
          _SegItem(label: 'Net', isActive: !isBrut, onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _SegItem extends StatelessWidget {
  const _SegItem({
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
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive
                    ? AppColors.onPrimary
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

/// Dropdown field : label au-dessus + DropdownButtonFormField.
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: [
            for (final opt in options)
              DropdownMenuItem(value: opt, child: Text(opt)),
          ],
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }
}

/// Carte résultat : titre + Brut + Net sur la même ligne.
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.brut,
    required this.net,
  });

  final String title;
  final String brut;
  final String net;

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
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _BrutNetValue(label: 'Brut', value: brut)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _BrutNetValue(label: 'Net', value: net)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrutNetValue extends StatelessWidget {
  const _BrutNetValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$value €',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Récapitulatif Salaire
// -----------------------------------------------------------------

/// Section "Récapitulatif Salaire" : 3 cartes détaillées + min légal +
/// calcul mensuel + 4 accordéons (indemnités, fériés, congés, conditions).
class _SalaryRecapSection extends StatelessWidget {
  const _SalaryRecapSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // Accordéons (stubs)
        _PaySubItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Indemnités et frais',
          onTap: () => _stub(context, 'Indemnités et frais'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PaySubItem(
          icon: Icons.calendar_today_rounded,
          label: 'Repos & jours fériés',
          onTap: () => _stub(context, 'Repos & jours fériés'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PaySubItem(
          icon: Icons.beach_access_rounded,
          label: 'Congés annuels',
          onTap: () => _stub(context, 'Congés annuels'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PaySubItem(
          icon: Icons.playlist_add_check_rounded,
          label: 'Conditions particulières',
          onTap: () => _stub(context, 'Conditions particulières'),
        ),
      ],
    );
  }

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Carte résultat du récap : titre (body bold) + 2 rows Brut / Net
/// (label à gauche, valeur à droite en primary bold).
class _SalaryResultCard extends StatelessWidget {
  const _SalaryResultCard({
    required this.title,
    required this.brut,
    required this.net,
  });

  final String title;
  final String brut;
  final String net;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SalaryRow(label: 'Brut', value: brut),
          const SizedBox(height: AppSpacing.xs),
          _SalaryRow(label: 'Net', value: net),
        ],
      ),
    );
  }
}

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Carte "Salaire mensuel de base" : formule + brut/net mensuels.
class _MonthlyCalculationCard extends StatelessWidget {
  const _MonthlyCalculationCard({
    required this.formula,
    required this.brutMensuel,
    required this.netMensuel,
  });

  final String formula;
  final String brutMensuel;
  final String netMensuel;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            formula,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SalaryRow(label: 'Brut mensuel :', value: brutMensuel),
          const SizedBox(height: AppSpacing.xs),
          _SalaryRow(label: 'Net mensuel :', value: netMensuel),
        ],
      ),
    );
  }
}

/// Item d'accordéon stub : carte avec icône tintée + label + chevron bas.
class _PaySubItem extends StatelessWidget {
  const _PaySubItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Champ time picker : pastille cliquable avec texte + chevron bas.
class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
