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
              else if (_tab == _ContractTab.caf)
                const _CafTabContent()
              else if (_tab == _ContractTab.pajemploi)
                const _PajemploiTabContent()
              else if (_tab == _ContractTab.endOfContract)
                const _EndOfContractTabContent()
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
            label: 'Fin de contrat',
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
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    height: 1.2,
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

          // Calcul automatique (résumé du contrat à signer)
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Calcul automatique',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SalarySummaryCard(),
          const SizedBox(height: AppSpacing.lg),

          // Simulation CMG (version compacte — détail complet dispo en CAF tab)
          const _ContractCmgCard(),
          const SizedBox(height: AppSpacing.lg),

          // Génération & Signature
          FilledButton.icon(
            onPressed: () => _onGenerateSign(context),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text(
              'Générer et envoyer pour signature',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _DocuSignInfoCard(),
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

  void _onGenerateSign(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération DocuSign — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Catégorie d'âge d'un enfant dans la simulation CAF.
enum _ChildAgeCategory {
  under3('Moins de 3 ans'),
  between3and6('Entre 3 et 6 ans'),
  over6('Plus de 6 ans');

  const _ChildAgeCategory(this.label);
  final String label;
}

/// Contenu de l'onglet "CAF" : formulaire de simulation CMG + résultats
/// révélés après clic sur "Lancer la simulation".
class _CafTabContent extends StatefulWidget {
  const _CafTabContent();

  @override
  State<_CafTabContent> createState() => _CafTabContentState();
}

class _CafTabContentState extends State<_CafTabContent> {
  bool _launched = false;
  String _careType = 'Temps complet';
  final List<_ChildAgeCategory> _children = [_ChildAgeCategory.under3];

  void _addChild() {
    setState(() => _children.add(_ChildAgeCategory.under3));
  }

  void _removeChild(int index) {
    if (_children.length <= 1) return;
    setState(() => _children.removeAt(index));
  }

  void _updateChild(int index, _ChildAgeCategory cat) {
    setState(() => _children[index] = cat);
  }

  void _launch() {
    setState(() => _launched = true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SimulationForm(
            careType: _careType,
            onCareTypeChanged: (v) =>
                setState(() => _careType = v ?? 'Temps complet'),
            children: _children,
            onAddChild: _addChild,
            onRemoveChild: _removeChild,
            onChildChanged: _updateChild,
            onLaunch: _launch,
          ),
          if (_launched) ...[
            const SizedBox(height: AppSpacing.md),
            const _SalarySummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const _CmgResultsCard(),
          ],
          const SizedBox(height: AppSpacing.md),
          const _CafDisclaimer(),
        ],
      ),
    );
  }
}

/// Carte formulaire de simulation CMG.
class _SimulationForm extends StatelessWidget {
  const _SimulationForm({
    required this.careType,
    required this.onCareTypeChanged,
    required this.children,
    required this.onAddChild,
    required this.onRemoveChild,
    required this.onChildChanged,
    required this.onLaunch,
  });

  final String careType;
  final ValueChanged<String?> onCareTypeChanged;
  final List<_ChildAgeCategory> children;
  final VoidCallback onAddChild;
  final void Function(int) onRemoveChild;
  final void Function(int, _ChildAgeCategory) onChildChanged;
  final VoidCallback onLaunch;

  static const _careOptions = ['Temps complet', 'Temps partiel'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero : icône + titre + sous-titres
          Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Simulation CMG',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Complément de libre choix du Mode de Garde',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Estimez le montant de l\'aide CAF pour l\'emploi d\'une assistante maternelle agréée',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Revenus N-2
          const ProfileFormField(
            label: 'Revenus annuels du foyer (N-2)',
            hintText: 'Ex: 35000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),

          // Type de garde
          _DropdownField(
            label: 'Type de garde',
            value: careType,
            options: _careOptions,
            onChanged: onCareTypeChanged,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Âge de chaque enfant gardé
          Text(
            'Âge de chaque enfant gardé',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < children.length; i++) ...[
            _ChildAgeRow(
              index: i,
              category: children[i],
              canRemove: children.length > 1,
              onChanged: (cat) => onChildChanged(i, cat),
              onRemove: () => onRemoveChild(i),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Ajouter un enfant
          OutlinedButton.icon(
            onPressed: onAddChild,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Ajouter un enfant'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Lancer la simulation
          FilledButton.icon(
            onPressed: onLaunch,
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Lancer la simulation'),
          ),
        ],
      ),
    );
  }
}

/// Row d'un enfant : "Enfant N" + dropdown tranche d'âge + croix de retrait.
class _ChildAgeRow extends StatelessWidget {
  const _ChildAgeRow({
    required this.index,
    required this.category,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _ChildAgeCategory category;
  final bool canRemove;
  final ValueChanged<_ChildAgeCategory> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            'Enfant ${index + 1}',
            style: AppTextStyles.labelMedium,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: DropdownButtonFormField<_ChildAgeCategory>(
            initialValue: category,
            items: [
              for (final cat in _ChildAgeCategory.values)
                DropdownMenuItem(
                  value: cat,
                  child: Text(cat.label),
                ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            isExpanded: true,
          ),
        ),
        if (canRemove)
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.secondaryText,
            ),
            onPressed: onRemove,
            tooltip: 'Retirer cet enfant',
          ),
      ],
    );
  }
}

/// Carte récap salaire avec badge "Incomplet", liste de lignes,
/// total mensuel highlight, salaire annuel et formule.
class _SalarySummaryCard extends StatelessWidget {
  const _SalarySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge
          const Align(
            alignment: Alignment.centerLeft,
            child: _StatusBadge(
              icon: Icons.info_outline_rounded,
              label: 'Incomplet',
              color: AppColors.accent,
              bgColor: AppColors.statYellowBg,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Lignes
          const _KeyValueRow(
            label: 'Heures mensualisées',
            value: '216.67h',
            valueBold: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _KeyValueRow(
            label: 'Salaire net mensuel',
            value: '676,00 €',
            valueBold: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _KeyValueRow(
            label: 'Salaire brut mensuel',
            value: '866,68 €',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _KeyValueRow(
            label: 'Ind. entretien',
            value: '75,83 €',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _KeyValueRow(
            label: 'Ind. repas',
            value: '86,67 €',
          ),
          const SizedBox(height: AppSpacing.md),

          // Total mensuel highlight
          const _HighlightRow(
            label: 'Total mensuel',
            value: '838,50 €',
          ),
          const SizedBox(height: AppSpacing.md),

          // Salaire annuel
          const _KeyValueRow(
            label: 'Salaire annuel net',
            value: '8 112,00 €',
            valueBold: true,
          ),
          const SizedBox(height: AppSpacing.md),

          // Formule
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.divider.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              '50h × 52 / 12',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte résultats simulation CMG avec badge "Éligible".
class _CmgResultsCard extends StatelessWidget {
  const _CmgResultsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: _StatusBadge(
              icon: Icons.check_circle_rounded,
              label: 'Éligible au CMG',
              color: AppColors.success,
              bgColor: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          const _KeyValueRow(
            label: 'Aide CMG/mois',
            value: '684,21 €',
            valueColor: AppColors.success,
            valueBold: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _KeyValueRow(
            label: 'Cotisations prises en charge',
            value: '153,11 €',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _KeyValueRow(
            label: 'Total aide/mois',
            value: '837,32 €',
            valueColor: AppColors.success,
            valueBold: true,
          ),
          const SizedBox(height: AppSpacing.md),

          // Reste à charge highlight
          const _HighlightRow(
            label: 'Reste à charge',
            value: '15,00 €',
          ),
        ],
      ),
    );
  }
}

/// Pill de statut : icône + label, bg teinté.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Ligne label (gauche) → valeur (droite), avec options de mise en forme.
class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    this.valueBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool valueBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? AppColors.primaryText,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Ligne highlight (fond vert clair) : label + valeur large verte en bold.
class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Disclaimer bas de page CAF : barèmes indicatifs.
class _CafDisclaimer extends StatelessWidget {
  const _CafDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(
        'Simulation indicative — barèmes CAF au 1er avril 2026. Source : caf.fr',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Onglet Pajemploi — wizard 5 étapes
// -----------------------------------------------------------------

/// Étape du wizard Pajemploi.
class _PajemploiStep {
  const _PajemploiStep({
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;
}

const _pajemploiSteps = <_PajemploiStep>[
  _PajemploiStep(icon: Icons.calendar_today_rounded, label: 'Informations'),
  _PajemploiStep(icon: Icons.schedule_rounded, label: 'Heures'),
  _PajemploiStep(icon: Icons.euro_rounded, label: 'Salaire'),
  _PajemploiStep(icon: Icons.coffee_rounded, label: 'Indemnités'),
  _PajemploiStep(icon: Icons.description_rounded, label: 'Récap'),
];

/// Couleurs spécifiques Pajemploi (one-off, pas dans la palette générale).
class _PajemploiColors {
  _PajemploiColors._();
  static const simBlue = Color(0xFF4A90E2);
  static const progressBg = Color(0xFFFDF5F0);
  static const infoBg = Color(0xFFFDF9F5);
  static const fieldBg = Color(0xFFF5F5F5);
}

class _PajemploiTabContent extends StatefulWidget {
  const _PajemploiTabContent();

  @override
  State<_PajemploiTabContent> createState() => _PajemploiTabContentState();
}

class _PajemploiTabContentState extends State<_PajemploiTabContent> {
  int _currentStep = 1;
  bool _simulationMode = false;
  bool _explanationsOn = true;

  String _month = 'avril 2026';

  void _prev() {
    if (_currentStep > 1) setState(() => _currentStep--);
  }

  void _next() {
    if (_currentStep < _pajemploiSteps.length) {
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PajemploiHeroCard(
            currentStep: _currentStep,
            simulationMode: _simulationMode,
            onSimulationModeChanged: (v) =>
                setState(() => _simulationMode = v),
            explanationsOn: _explanationsOn,
            onExplanationsChanged: (v) => setState(() => _explanationsOn = v),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_currentStep == 1)
            _PajemploiStep1Form(
              month: _month,
              onMonthChanged: (v) => setState(() => _month = v),
            )
          else
            const _PajemploiStepPlaceholder(),
          const SizedBox(height: AppSpacing.lg),
          _WizardButtons(
            canGoPrev: _currentStep > 1,
            canGoNext: _currentStep < _pajemploiSteps.length,
            onPrev: _prev,
            onNext: _next,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Historique des déclarations passées
          const _DeclarationHistorySection(),
        ],
      ),
    );
  }
}

/// Carte d'en-tête : titre + toggles + titre étape + progress + step icons.
class _PajemploiHeroCard extends StatelessWidget {
  const _PajemploiHeroCard({
    required this.currentStep,
    required this.simulationMode,
    required this.onSimulationModeChanged,
    required this.explanationsOn,
    required this.onExplanationsChanged,
  });

  final int currentStep;
  final bool simulationMode;
  final ValueChanged<bool> onSimulationModeChanged;
  final bool explanationsOn;
  final ValueChanged<bool> onExplanationsChanged;

  @override
  Widget build(BuildContext context) {
    final total = _pajemploiSteps.length;
    final progress = currentStep / total;
    final step = _pajemploiSteps[currentStep - 1];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre principal
          Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Moteur de calcul Pajemploi',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Calcul automatique conforme aux règles URSSAF pour assistantes maternelles',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Row : badge Simulation + toggle Mode simulation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SimulationBadge(),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: simulationMode,
                      onChanged: onSimulationModeChanged,
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        'Mode simulation',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Row : toggle Explications
          Row(
            children: [
              Switch(
                value: explanationsOn,
                onChanged: onExplanationsChanged,
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.secondaryText,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Explications',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Titre étape
          Text(
            'Étape $currentStep/$total ${step.label}',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.full),
            child: Container(
              height: 8,
              color: _PajemploiColors.progressBg,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 5 step icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < total; i++)
                _StepIcon(
                  icon: _pajemploiSteps[i].icon,
                  isActive: i + 1 == currentStep,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pill bleu "Simulation".
class _SimulationBadge extends StatelessWidget {
  const _SimulationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: _PajemploiColors.simBlue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.visibility_outlined,
            color: _PajemploiColors.simBlue,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Simulation',
            style: AppTextStyles.labelMedium.copyWith(
              color: _PajemploiColors.simBlue,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cercle 36px avec icône indiquant l'état d'une étape (actif/inactif).
class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.icon, required this.isActive});
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : _PajemploiColors.fieldBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: isActive ? AppColors.onPrimary : AppColors.secondaryText,
      ),
    );
  }
}

/// Formulaire de l'étape 1 : bannière info + Mois concerné + Assistante maternelle.
class _PajemploiStep1Form extends StatelessWidget {
  const _PajemploiStep1Form({
    required this.month,
    required this.onMonthChanged,
  });

  final String month;
  final ValueChanged<String> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _PajemploiColors.infoBg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Commençons par les informations de base. Les heures mensualisées seront calculées automatiquement.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Mois concerné
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primaryText,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Mois concerné', style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _FilledField(
            value: month,
            trailing: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Row : Heures hebdo + Semaines d'accueil
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProfileFormField(
                  label: 'Heures hebdo contractuelles',
                  initialValue: '40',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ProfileFormField(
                  label: 'Semaines d\'accueil / an',
                  initialValue: '47',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Heures mensualisées (computed, read-only highlight)
          _ComputedField(
            label: 'Heures mensualisées',
            value: '156.67',
            hint: 'Calculé : heures × semaines / 12',
          ),
          const SizedBox(height: AppSpacing.md),

          // Row : Jours d'activité + Jours fériés travaillés
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProfileFormField(
                  label: 'Jours d\'activité',
                  initialValue: '20',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ProfileFormField(
                  label: 'Jours fériés travaillés',
                  initialValue: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Assistante maternelle
          Text('Assistante maternelle', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          const _FilledField(value: 'Sophie Martin'),
        ],
      ),
    );
  }
}

/// Champ read-only affichant une valeur calculée (fond primary tinté).
class _ComputedField extends StatelessWidget {
  const _ComputedField({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ "filled" gris clair avec valeur + trailing optionnel.
class _FilledField extends StatelessWidget {
  const _FilledField({required this.value, this.trailing});
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: _PajemploiColors.fieldBg,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Placeholder pour les étapes 2-5 (specs à venir).
class _PajemploiStepPlaceholder extends StatelessWidget {
  const _PajemploiStepPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Contenu à venir',
            style: AppTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }
}

/// Section Historique : titre + compteur + liste de [DeclarationCard].
class _DeclarationHistorySection extends StatelessWidget {
  const _DeclarationHistorySection();

  static const _declarations = <_DeclarationData>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Historique des déclarations',
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${_declarations.length} déclarations validées',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < _declarations.length; i++) ...[
          _DeclarationCard(data: _declarations[i]),
          if (i < _declarations.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// Données d'une déclaration Pajemploi passée.
class _DeclarationData {
  const _DeclarationData({
    required this.month,
    required this.assmat,
    required this.hours,
    required this.days,
    required this.brut,
    required this.net,
    required this.total,
  });

  final String month;
  final String assmat;
  final String hours;
  final String days;
  final String brut;
  final String net;
  final String total;
}

/// Carte d'une déclaration passée : mois + assmat + heures + brut/net + total
/// + pastille "Validée".
class _DeclarationCard extends StatelessWidget {
  const _DeclarationCard({required this.data});
  final _DeclarationData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header : mois + badge Validée
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.month,
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const _StatusBadge(
                icon: Icons.check_circle_rounded,
                label: 'Validée',
                color: AppColors.success,
                bgColor: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Sous-titre : assmat + heures · jours
          Text(
            data.assmat,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${data.hours}  ·  ${data.days}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Montants
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brut : ${data.brut}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                'Net : ${data.net}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                data.total,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Boutons wizard Précédent / Suivant.
class _WizardButtons extends StatelessWidget {
  const _WizardButtons({
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: canGoPrev ? onPrev : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Précédent'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton.icon(
            onPressed: canGoNext ? onNext : null,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Suivant'),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Onglet Fin de contrat
// -----------------------------------------------------------------

/// Données saisies à l'Étape 2 qui alimentent le calcul des indemnités.
typedef _CalculationData = ({
  int anciennete,
  double salaireMensuel,
  double totalSalairesBruts,
  int joursConges,
});

/// Formate un montant en euros : `1234.5` → `"1 234,50 €"`.
String _formatEuro(double value) {
  final rounded = (value * 100).round() / 100;
  final parts = rounded.toStringAsFixed(2).split('.');
  return '${parts[0]},${parts[1]} €';
}

/// Motif de rupture du contrat.
enum _RuptureMotif {
  retrait(
    Icons.person_off_rounded,
    'Retrait d\'enfant',
    'L\'enfant n\'a plus besoin d\'être gardé (déménagement, changement de situation...)',
  ),
  scolarisation(
    Icons.calendar_month_rounded,
    'Scolarisation',
    'L\'enfant entre à l\'école maternelle ou primaire',
  ),
  demission(
    Icons.description_rounded,
    'Démission de l\'assmat',
    'L\'assistante maternelle décide de mettre fin au contrat',
  ),
  fauteGrave(
    Icons.warning_amber_rounded,
    'Faute grave',
    'Manquement grave rendant impossible le maintien du contrat',
  ),
  fauteLourde(
    Icons.warning_amber_rounded,
    'Faute lourde',
    'Faute avec intention de nuire (violence, vol...)',
  ),
  retraitAgrement(
    Icons.balance_rounded,
    'Retrait d\'agrément',
    'L\'agrément de l\'assistante maternelle est retiré ou suspendu',
  ),
  finPeriodeEssai(
    Icons.event_note_rounded,
    'Fin de période d\'essai',
    'Rupture pendant la période d\'essai (CDI)',
  ),
  departRetraite(
    Icons.payments_rounded,
    'Départ à la retraite',
    'L\'assistante maternelle fait valoir ses droits à la retraite',
  ),
  deces(
    Icons.warning_amber_rounded,
    'Décès',
    'Décès de l\'employeur, de l\'enfant ou de l\'assistante maternelle',
  );

  const _RuptureMotif(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

/// Contenu de l'onglet "Fin de contrat" : étape 1 — sélection du motif.
class _EndOfContractTabContent extends StatefulWidget {
  const _EndOfContractTabContent();

  @override
  State<_EndOfContractTabContent> createState() =>
      _EndOfContractTabContentState();
}

class _EndOfContractTabContentState extends State<_EndOfContractTabContent> {
  _RuptureMotif? _selected;
  bool _isCdd = false;
  _CalculationData? _calculation;

  void _onCalculated(_CalculationData data) {
    setState(() => _calculation = data);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte motifs
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero : icône balance + titre + sous-titre
                Row(
                  children: [
                    const Icon(
                      Icons.balance_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Étape 1 — Type de rupture',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sélectionnez le motif de fin de contrat',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 9 options de motifs
                for (var i = 0; i < _RuptureMotif.values.length; i++) ...[
                  _RuptureOption(
                    motif: _RuptureMotif.values[i],
                    isSelected: _selected == _RuptureMotif.values[i],
                    onTap: () => setState(
                      () => _selected = _RuptureMotif.values[i],
                    ),
                  ),
                  if (i < _RuptureMotif.values.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Toggle CDD (hors carte)
          _CddToggle(
            value: _isCdd,
            onChanged: (v) => setState(() => _isCdd = v),
          ),
          // Étape 2 + résultats : visibles uniquement après sélection d'un
          // motif à l'étape 1.
          if (_selected != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _ContractDataCard(onCalculated: _onCalculated),

            // Résultats (apparaissent après clic Calculer)
            if (_calculation != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _PreavisResultCard(anciennete: _calculation!.anciennete),
              const SizedBox(height: AppSpacing.lg),
              _IndemnitesSoldeCard(data: _calculation!),
              const SizedBox(height: AppSpacing.lg),
              const _DocumentsFinCard(),
              const SizedBox(height: AppSpacing.lg),
              const _RecapDroitsCard(),
            ],
          ],
        ],
      ),
    );
  }
}

/// Toggle "Contrat à durée déterminée (CDD)" affiché sous la carte motifs.
class _CddToggle extends StatelessWidget {
  const _CddToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Contrat à durée déterminée (CDD)',
              style: AppTextStyles.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Étape 2 du flow de rupture : données financières du contrat.
class _ContractDataCard extends StatefulWidget {
  const _ContractDataCard({required this.onCalculated});

  /// Appelé quand l'utilisateur clique "Calculer" — transmet l'ensemble
  /// des valeurs saisies au parent pour calculer les indemnités.
  final ValueChanged<_CalculationData> onCalculated;

  @override
  State<_ContractDataCard> createState() => _ContractDataCardState();
}

class _ContractDataCardState extends State<_ContractDataCard> {
  int _anciennete = 24;
  double _salaireMensuel = 600;
  double _totalSalairesBruts = 14400;
  int _joursConges = 5;
  bool _dispensePreavis = false;

  void _onCalculer() {
    widget.onCalculated((
      anciennete: _anciennete,
      salaireMensuel: _salaireMensuel,
      totalSalairesBruts: _totalSalairesBruts,
      joursConges: _joursConges,
    ));
  }

  String get _ancienneteHint {
    final years = _anciennete ~/ 12;
    final months = _anciennete % 12;
    return '$years an(s) et $months mois';
  }

  void _onAncienneteChanged(String v) {
    final parsed = int.tryParse(v);
    if (parsed != null && parsed >= 0) {
      setState(() => _anciennete = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Étape 2 — Données du contrat',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Renseignez les informations financières',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Ancienneté + hint dynamique
          ProfileFormField(
            label: 'Ancienneté (en mois)',
            initialValue: '$_anciennete',
            keyboardType: TextInputType.number,
            onChanged: _onAncienneteChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _ancienneteHint,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Salaire mensuel brut
          ProfileFormField(
            label: 'Salaire mensuel brut (€)',
            initialValue: '600',
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed != null && parsed >= 0) {
                setState(() => _salaireMensuel = parsed);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Total salaires bruts + hint
          ProfileFormField(
            label: 'Total des salaires bruts perçus (€)',
            initialValue: '14400',
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed != null && parsed >= 0) {
                setState(() => _totalSalairesBruts = parsed);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Somme de tous les salaires bruts depuis le début du contrat',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Jours de congés acquis non pris
          ProfileFormField(
            label: 'Jours de congés acquis non pris',
            initialValue: '5',
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed >= 0) {
                setState(() => _joursConges = parsed);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Toggle dispense préavis
          Row(
            children: [
              Switch(
                value: _dispensePreavis,
                onChanged: (v) => setState(() => _dispensePreavis = v),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'L\'employeur dispense l\'assmat d\'effectuer le préavis',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bouton Calculer
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _onCalculer,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              label: const Text('Calculer'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: const Size(0, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte "Indemnités & Solde de tout compte" — apparaît après clic Calculer.
class _IndemnitesSoldeCard extends StatelessWidget {
  const _IndemnitesSoldeCard({required this.data});

  final _CalculationData data;

  // Règles simplifiées :
  // - Indemnité compensatrice = jours congés non pris × (salaire mensuel / 22)
  // - Indemnité de rupture = total salaires bruts / 80
  double get _salaireJournalier => data.salaireMensuel / 22;
  double get _indemniteCompensatrice => data.joursConges * _salaireJournalier;
  double get _indemniteRupture => data.totalSalairesBruts / 80;
  double get _total => _indemniteCompensatrice + _indemniteRupture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Indemnités & Solde de tout compte',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Montants estimés selon les informations saisies',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Indemnité compensatrice
          _IndemniteRow(
            title: 'Indemnité compensatrice de congés payés',
            amount: _formatEuro(_indemniteCompensatrice),
            description:
                '${data.joursConges} jour(s) acquis non pris × salaire journalier brut',
            chipLabel: 'Soumise aux cotisations',
            chipFilled: false,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // Indemnité de rupture
          _IndemniteRow(
            title: 'Indemnité de rupture (1/80e des salaires bruts)',
            amount: _formatEuro(_indemniteRupture),
            description:
                'Exonérée de cotisations sociales et non imposable.',
            chipLabel: 'Exonérée de cotisations',
            chipFilled: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total estimé des indemnités',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatEuro(_total),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Info box régularisation + solde de tout compte
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.divider.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                          ),
                          children: [
                            const TextSpan(text: '💡 '),
                            TextSpan(
                              text: 'Régularisation',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' : en année incomplète, comparez les heures réellement travaillées avec celles rémunérées et régularisez la différence.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                          ),
                          children: [
                            const TextSpan(
                              text: '💡 Le solde de tout compte doit être versé le ',
                            ),
                            TextSpan(
                              text: 'dernier jour travaillé',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
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

/// Une ligne d'indemnité : titre + montant en grand, description + chip.
class _IndemniteRow extends StatelessWidget {
  const _IndemniteRow({
    required this.title,
    required this.amount,
    required this.description,
    required this.chipLabel,
    required this.chipFilled,
  });

  final String title;
  final String amount;
  final String description;
  final String chipLabel;

  /// `true` → pill tintée secondary ; `false` → pill blanche à bordure.
  final bool chipFilled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              amount,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: _InfoChip(label: chipLabel, filled: chipFilled),
        ),
      ],
    );
  }
}

/// Pilule étiquette : filled (fond secondary) ou outlined (blanc + border).
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.filled});
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: filled ? AppColors.secondary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
          color: filled ? AppColors.secondary : AppColors.divider,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: filled ? AppColors.primary : AppColors.primaryText,
        ),
      ),
    );
  }
}

/// Document à remettre en fin de contrat.
class _FinDocument {
  const _FinDocument({
    required this.title,
    required this.description,
    required this.mandatory,
  });

  final String title;
  final String description;
  final bool mandatory;
}

/// Carte "Documents de fin de contrat" — liste des documents à remettre
/// le dernier jour du contrat, avec badge "Obligatoire" rouge.
class _DocumentsFinCard extends StatelessWidget {
  const _DocumentsFinCard();

  static const _documents = <_FinDocument>[
    _FinDocument(
      title: 'Certificat de travail',
      description:
          'Atteste de la période d\'emploi. Obligatoire sous peine de 750 € d\'amende.',
      mandatory: true,
    ),
    _FinDocument(
      title: 'Reçu pour solde de tout compte',
      description:
          'Détaille toutes les sommes versées (salaire, congés, indemnités). En 2 exemplaires.',
      mandatory: true,
    ),
    _FinDocument(
      title: 'Attestation France Travail',
      description:
          'Indispensable pour que l\'assmat puisse ouvrir ses droits au chômage.',
      mandatory: true,
    ),
    _FinDocument(
      title: 'Dernière déclaration Pajemploi',
      description:
          'Déclarer le dernier salaire + indemnités soumises à cotisations.',
      mandatory: true,
    ),
    _FinDocument(
      title: 'Lettre de rupture / licenciement',
      description: 'Courrier écrit et daté notifiant la fin de contrat.',
      mandatory: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          Row(
            children: [
              const Icon(
                Icons.description_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Documents de fin de contrat',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'À remettre le dernier jour du contrat — sous peine d\'amende',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Liste documents
          for (var i = 0; i < _documents.length; i++) ...[
            _FinDocItem(number: i + 1, doc: _documents[i]),
            if (i < _documents.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Bouton générer récap
          OutlinedButton.icon(
            onPressed: () => _onGenerateRecap(context),
            icon: const Icon(Icons.description_outlined, size: 20),
            label: const Text(
              'Générer le récapitulatif\nde fin de contrat',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(height: 1.2),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
          ),
        ],
      ),
    );
  }

  void _onGenerateRecap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Récapitulatif fin de contrat — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Ligne d'un document : numéro circulaire + titre/description + badge
/// "Obligatoire" rouge si mandatory.
class _FinDocItem extends StatelessWidget {
  const _FinDocItem({required this.number, required this.doc});

  final int number;
  final _FinDocument doc;

  @override
  Widget build(BuildContext context) {
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
          // Cercle numéro
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.divider.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Titre + description + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  doc.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                if (doc.mandatory) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const _MandatoryBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge rouge "Obligatoire" pour les documents légalement requis.
class _MandatoryBadge extends StatelessWidget {
  const _MandatoryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text(
        'Obligatoire',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Type d'une cellule du tableau récap droits.
enum _DroitType { yes, no, text }

/// Contenu d'une cellule : coche, croix, ou texte pur (ex: "IRCEM").
class _DroitCell {
  const _DroitCell._(this.type, this.text);
  const _DroitCell.yes({String? extra}) : this._(_DroitType.yes, extra);
  const _DroitCell.no() : this._(_DroitType.no, null);
  const _DroitCell.text(String value) : this._(_DroitType.text, value);

  final _DroitType type;
  final String? text;
}

/// Ligne du tableau récap droits.
class _DroitRow {
  const _DroitRow({
    required this.situation,
    required this.indemnite,
    required this.conges,
    required this.preavis,
  });

  final String situation;
  final _DroitCell indemnite;
  final _DroitCell conges;
  final _DroitCell preavis;
}

/// Tableau "Récapitulatif des droits selon le type de rupture" — affiche
/// pour chaque motif si les 3 droits (indemnité, congés, préavis) s'appliquent.
class _RecapDroitsCard extends StatelessWidget {
  const _RecapDroitsCard();

  static const _rows = <_DroitRow>[
    _DroitRow(
      situation: 'Retrait d\'enfant (+9 mois)',
      indemnite: _DroitCell.yes(extra: '1/80e brut'),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.yes(),
    ),
    _DroitRow(
      situation: 'Retrait d\'enfant (<9 mois)',
      indemnite: _DroitCell.no(),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.yes(),
    ),
    _DroitRow(
      situation: 'Démission',
      indemnite: _DroitCell.no(),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.yes(),
    ),
    _DroitRow(
      situation: 'Faute grave (>1 an)',
      indemnite: _DroitCell.yes(extra: '1/120e net'),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.no(),
    ),
    _DroitRow(
      situation: 'Faute lourde',
      indemnite: _DroitCell.no(),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.no(),
    ),
    _DroitRow(
      situation: 'Retrait d\'agrément',
      indemnite: _DroitCell.no(),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.no(),
    ),
    _DroitRow(
      situation: 'Fin de période d\'essai',
      indemnite: _DroitCell.no(),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.no(),
    ),
    _DroitRow(
      situation: 'Retraite',
      indemnite: _DroitCell.text('IRCEM'),
      conges: _DroitCell.yes(),
      preavis: _DroitCell.yes(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.secondaryText,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Récapitulatif des droits selon le type de rupture',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Header de colonnes
          const _DroitHeaderRow(),
          const Divider(height: 1, color: AppColors.divider),

          // Rows de données (stripe alternée)
          for (var i = 0; i < _rows.length; i++)
            _DroitDataRow(row: _rows[i], isEven: i.isEven),
        ],
      ),
    );
  }
}

class _DroitHeaderRow extends StatelessWidget {
  const _DroitHeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelMedium.copyWith(
      color: AppColors.secondaryText,
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 3, child: Text('Situation', style: style)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(
              'Indemnité de rupture',
              style: style,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text('Congés payés', style: style, maxLines: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text('Préavis', style: style, maxLines: 1),
          ),
        ],
      ),
    );
  }
}

class _DroitDataRow extends StatelessWidget {
  const _DroitDataRow({required this.row, required this.isEven});

  final _DroitRow row;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven
          ? AppColors.divider.withValues(alpha: 0.15)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row.situation,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: _DroitCellView(cell: row.indemnite),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: _DroitCellView(cell: row.conges),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: _DroitCellView(cell: row.preavis),
          ),
        ],
      ),
    );
  }
}

/// Rend une cellule selon son type :
///   - [_DroitType.no] : croix rouge
///   - [_DroitType.yes] : coche verte (+ texte additionnel optionnel)
///   - [_DroitType.text] : texte pur (ex: "IRCEM")
class _DroitCellView extends StatelessWidget {
  const _DroitCellView({required this.cell});
  final _DroitCell cell;

  @override
  Widget build(BuildContext context) {
    switch (cell.type) {
      case _DroitType.no:
        return const Icon(
          Icons.close_rounded,
          color: AppColors.error,
          size: 18,
        );

      case _DroitType.text:
        return Text(
          cell.text ?? '',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

      case _DroitType.yes:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.onPrimary,
                size: 14,
              ),
            ),
            if (cell.text != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  cell.text!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ],
        );
    }
  }
}

/// Résultat du calcul de préavis — apparaît après clic "Calculer".
class _PreavisResultCard extends StatelessWidget {
  const _PreavisResultCard({required this.anciennete});

  /// Ancienneté en mois.
  final int anciennete;

  /// ≥ 12 mois → 1 mois ; sinon → 15 jours (règles simplifiées).
  ({String badge, String description}) get _preavis {
    if (anciennete >= 12) {
      return (
        badge: '1\nmois',
        description:
            'Préavis d\'un mois pour une ancienneté d\'un an ou plus.',
      );
    }
    return (
      badge: '15\njours',
      description:
          'Préavis de 15 jours pour une ancienneté de moins d\'un an.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final preavis = _preavis;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Préavis', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Badge rond + description
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  preavis.badge,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  preavis.description,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Info box
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.divider.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Le préavis commence à la réception de la lettre de rupture. '
                    'S\'il coïncide avec des congés, il est suspendu et reprend au retour.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
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

/// Carte d'une option de motif : icône ronde + titre + description.
/// Surlignée (border primary 2px) quand sélectionnée.
class _RuptureOption extends StatelessWidget {
  const _RuptureOption({
    required this.motif,
    required this.isSelected,
    required this.onTap,
  });

  final _RuptureMotif motif;
  final bool isSelected;
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
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.divider.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  motif.icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(motif.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      motif.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

/// Modèle d'un créneau journalier.
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

  late final Map<String, _DaySchedule> _schedule = {
    for (final d in _dayNames)
      d: _DaySchedule(
        active: false,
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
        const _PaySubItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Indemnités et frais',
          children: _IndemnitesFraisForm(),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _PaySubItem(
          icon: Icons.calendar_today_rounded,
          label: 'Repos & jours fériés',
          children: _ReposFeriesForm(),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _PaySubItem(
          icon: Icons.beach_access_rounded,
          label: 'Congés annuels',
          children: _CongesAnnuelsForm(),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _PaySubItem(
          icon: Icons.playlist_add_check_rounded,
          label: 'Conditions particulières',
          children: _ConditionsParticulieresForm(),
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

/// Item d'accordéon du récap salaire : carte avec icône tintée + label +
/// chevron bas. Deux modes :
///   - [onTap] fourni + [children] null → se comporte comme un stub (tap =
///     callback, chevron statique)
///   - [children] fourni → se déplie avec animation (chevron rotatif)
class _PaySubItem extends StatefulWidget {
  const _PaySubItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.children,
    this.initiallyExpanded = false,
  }) : assert(
          onTap != null || children != null,
          'Fournir onTap (stub) ou children (expandable).',
        );

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? children;
  final bool initiallyExpanded;

  @override
  State<_PaySubItem> createState() => _PaySubItemState();
}

class _PaySubItemState extends State<_PaySubItem> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _isExpandable => widget.children != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isExpandable
                  ? () => setState(() => _expanded = !_expanded)
                  : widget.onTap,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Padding(
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
                      child: Icon(
                        widget.icon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpandable && _expanded ? 0 : -0.5,
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

          // Body (si expandable)
          if (_isExpandable)
            AnimatedCrossFade(
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: widget.children!,
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Repos & jours fériés
// -----------------------------------------------------------------

class _ReposFeriesForm extends StatefulWidget {
  const _ReposFeriesForm();

  @override
  State<_ReposFeriesForm> createState() => _ReposFeriesFormState();
}

class _ReposFeriesFormState extends State<_ReposFeriesForm> {
  static const _restDayOptions = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  String _restDay = 'Dimanche';

  static const _exceptionalWorkOptions = [
    'Rémunéré',
    'Récupéré',
    'Rémunéré + récupéré',
  ];
  String _exceptionalWork = 'Rémunéré';

  static const _firstMayOptions = [
    'Chômé',
    'Travaillé (majoré 100 %)',
  ];
  String _firstMay = 'Chômé';

  static const _holidays = [
    '1er janvier',
    'Vendredi Saint (Alsace-Moselle)',
    'Lundi de Pâques',
    '8 mai',
    'Jeudi de l\'Ascension',
    'Lundi de Pentecôte',
    'Abolition de l\'esclavage (DROM)',
    '14 juillet',
    '15 août',
    '1er novembre',
    '11 novembre',
    '25 décembre',
    '26 décembre (Alsace-Moselle)',
  ];
  final Map<String, bool> _selectedHolidays = {
    for (final h in _holidays) h: false,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row : Jour de repos + Travail exceptionnel
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DropdownField(
                label: 'Jour de repos',
                value: _restDay,
                options: _restDayOptions,
                onChanged: (v) => setState(() => _restDay = v ?? 'Dimanche'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DropdownField(
                label: 'Travail exceptionnel',
                value: _exceptionalWork,
                options: _exceptionalWorkOptions,
                onChanged: (v) =>
                    setState(() => _exceptionalWork = v ?? 'Rémunéré'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 1er Mai (full width)
        _DropdownField(
          label: '1er Mai',
          value: _firstMay,
          options: _firstMayOptions,
          onChanged: (v) => setState(() => _firstMay = v ?? 'Chômé'),
        ),
        const SizedBox(height: AppSpacing.md),

        // Jours fériés travaillés
        Text(
          'Jours fériés travaillés',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final h in _holidays)
          _HolidayCheckbox(
            label: h,
            value: _selectedHolidays[h] ?? false,
            onChanged: (v) => setState(() => _selectedHolidays[h] = v),
          ),
        const SizedBox(height: AppSpacing.md),

        // Majoration numérique
        const ProfileFormField(
          label: 'Majoration jours fériés (% — min 10%)',
          initialValue: '10',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

/// Checkbox compacte pour la liste des jours fériés — même ergonomie
/// que [FilterCheckboxTile] mais inline ici pour éviter l'import
/// cross-feature.
class _HolidayCheckbox extends StatelessWidget {
  const _HolidayCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: const CircleBorder(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Indemnités et frais
// -----------------------------------------------------------------

class _IndemnitesFraisForm extends StatefulWidget {
  const _IndemnitesFraisForm();

  @override
  State<_IndemnitesFraisForm> createState() => _IndemnitesFraisFormState();
}

class _IndemnitesFraisFormState extends State<_IndemnitesFraisForm> {
  bool _amFournitRepas = false;
  bool _amFournitCouches = true;
  bool _amFournitHygiene = true;
  bool _vehiculeFourni = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row : Indemnité d'entretien + Indemnité repas
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileFormField(
                label: 'Entretien (€/jour)',
                initialValue: '3,00',
                keyboardType: TextInputType.number,
                required: true,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProfileFormField(
                label: 'Repas (€/jour)',
                initialValue: '4,50',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.secondaryText,
              size: 14,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Entretien : min légal 2,65 € / jour travaillé',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Fournitures
        Text(
          'Fournitures',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        _HolidayCheckbox(
          label: 'L\'assistante maternelle fournit les repas',
          value: _amFournitRepas,
          onChanged: (v) => setState(() => _amFournitRepas = v),
        ),
        _HolidayCheckbox(
          label: 'L\'assistante maternelle fournit les couches',
          value: _amFournitCouches,
          onChanged: (v) => setState(() => _amFournitCouches = v),
        ),
        _HolidayCheckbox(
          label: 'L\'assistante maternelle fournit les produits d\'hygiène',
          value: _amFournitHygiene,
          onChanged: (v) => setState(() => _amFournitHygiene = v),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Déplacements
        Text(
          'Déplacements',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        _HolidayCheckbox(
          label: 'Véhicule fourni par l\'assistante maternelle',
          value: _vehiculeFourni,
          onChanged: (v) => setState(() => _vehiculeFourni = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileFormField(
                label: 'Indemnité km (€/km)',
                initialValue: '0,00',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProfileFormField(
                label: 'Distance moy. (km/j)',
                initialValue: '0',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Autres frais
        const ProfileFormField(
          label: 'Autres frais / notes',
          hintText: 'Précisez tout autre frais convenu…',
          maxLines: 3,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Congés annuels
// -----------------------------------------------------------------

class _CongesAnnuelsForm extends StatelessWidget {
  const _CongesAnnuelsForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileFormField(
          label: 'Semaines de congés payés',
          initialValue: '5',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Inclus dans la mensualisation',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// DocuSign info card
// -----------------------------------------------------------------

/// Info card bleue décrivant le flow de signature électronique.
class _DocuSignInfoCard extends StatelessWidget {
  const _DocuSignInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.statBlueBg,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.statBlueColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_rounded,
            color: AppColors.statBlueColor,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signature DocuSign',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.statBlueColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Le contrat sera envoyé aux deux parties pour signature électronique officielle. Téléchargeable en PDF et stocké dans vos documents.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
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

// -----------------------------------------------------------------
// Conditions particulières
// -----------------------------------------------------------------

class _ConditionsParticulieresForm extends StatelessWidget {
  const _ConditionsParticulieresForm();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Textarea libre
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Activités, cahier de liaison, animaux...',
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // Info tile : Indemnité de fin de contrat
        _InfoTile(
          label: 'Indemnité de fin de contrat',
          value: 'Après 9 mois : 1/80e du total des salaires bruts.',
        ),
        SizedBox(height: AppSpacing.sm),

        // Info tile : Retraite & Prévoyance
        _InfoTile(
          label: 'Retraite & Prévoyance',
          value: 'Ircem AGIRC/ARRCO & Ircem Prévoyance',
        ),
      ],
    );
  }
}

/// Info tile : label (labelLarge) + valeur (bodySmall secondary) dans une
/// carte légèrement teintée.
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Simulation CMG (version compacte pour l'onglet Contrat)
// -----------------------------------------------------------------

/// Carte compacte "Simulation CMG" affichée dans l'onglet Contrat avant
/// la signature : titre + sous-titre + input Revenus N-2.
///
/// La simulation détaillée complète (inputs + résultats + éligibilité)
/// est dans l'onglet CAF via [_CafTabContent].
class _ContractCmgCard extends StatelessWidget {
  const _ContractCmgCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header : icône + titre
          Row(
            children: [
              const Icon(
                Icons.shield_moon_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Simulation CMG',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Sous-titre
          Text(
            'Complément de libre choix du Mode de Garde',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Champ Revenus N-2
          const ProfileFormField(
            label: 'Revenus annuels (N-2)',
            initialValue: '30000',
            keyboardType: TextInputType.number,
            hintText: 'Revenus du foyer en €',
          ),
        ],
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
