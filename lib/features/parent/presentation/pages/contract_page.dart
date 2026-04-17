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
