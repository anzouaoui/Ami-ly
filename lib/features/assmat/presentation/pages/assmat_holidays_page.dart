import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_home_page.dart';

class AssMatHolidaysPage extends StatefulWidget {
  const AssMatHolidaysPage({super.key});

  @override
  State<AssMatHolidaysPage> createState() => _AssMatHolidaysPageState();
}

class _AssMatHolidaysPageState extends State<AssMatHolidaysPage> {
  int _tab = 0;

  static const _tabs = ['Compteur', 'Simulateur', 'Historique', 'Règles URSSAF'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care_rounded,
                  size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('AMiLY',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Text(
              'Gestion des congés payés',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 26),
            ),
            const SizedBox(height: 4),
            Text(
              'Période de référence : 1er juin 2025 – 31 mai 2026',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Poser des congés ─────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const _AddHolidaySheet(),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Poser des congés'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle:
                      AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Tabs ─────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = i == _tab;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(
                          color: selected
                              ? AppColors.divider
                              : Colors.transparent,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        _tabs[i],
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? AppColors.primaryText
                              : AppColors.secondaryText,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Tab content ──────────────────────────────────
            switch (_tab) {
              0 => const _CompteurContent(),
              1 => const _SimulateurContent(),
              2 => const _HistoriqueContent(),
              _ => const _ReglesContent(),
            },
          ],
        ),
      ),
    );
  }
}

// ─── Tab 0 : Compteur ─────────────────────────────────────────────────────────

class _CompteurContent extends StatelessWidget {
  const _CompteurContent();

  static const int _acquis = 27;
  static const int _pris = 12;
  static const int _enAttente = 5;
  static const int _restants = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats 2×2
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.secondary,
                value: '$_acquis',
                label: 'Jours acquis',
                sublabel: 'ouvrables',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.secondary,
                value: '$_pris',
                label: 'Jours pris',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.schedule_outlined,
                iconColor: AppColors.accent,
                iconBg: AppColors.statYellowBg,
                value: '$_enAttente',
                label: 'En attente',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                icon: Icons.park_outlined,
                iconColor: const Color(0xFFE07B39),
                iconBg: const Color(0xFFFFF0E6),
                value: '$_restants',
                label: 'Jours restants',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Multi-segment progress card
        Container(
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
                  Expanded(
                    child: Text(
                      'Utilisation des congés',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_pris + _enAttente}/$_acquis jours ouvrables',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Multi-segment bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Flexible(
                        flex: _pris,
                        child: Container(color: AppColors.primary),
                      ),
                      Flexible(
                        flex: _enAttente,
                        child: Container(color: AppColors.accent),
                      ),
                      Flexible(
                        flex: _restants,
                        child: Container(color: AppColors.divider),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Legend
              Row(
                children: [
                  _LegendDot(color: AppColors.primary, label: 'Pris : ${_pris}j'),
                  const SizedBox(width: AppSpacing.sm),
                  _LegendDot(color: AppColors.accent, label: 'En attente : ${_enAttente}j'),
                  const SizedBox(width: AppSpacing.sm),
                  _LegendDot(color: AppColors.hint, label: 'Restant : ${_restants}j'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Calcul indemnité
        const _IndemniteCard(),
      ],
    );
  }
}

// ─── Calcul de l'indemnité ────────────────────────────────────────────────────

class _IndemniteCard extends StatelessWidget {
  const _IndemniteCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                  const Text('💰', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Calcul de l\'indemnité de congés payés',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'La méthode la plus avantageuse pour le salarié est retenue (art. L3141-24 Code du travail).',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.md),

              _MethodeCard(
                titre: 'Méthode 1 : Maintien de salaire',
                montant: '260.00 €',
                description: 'Salaire identique aux jours travaillés',
                isAvantageuse: false,
              ),
              const SizedBox(height: AppSpacing.sm),

              _MethodeCard(
                titre: 'Méthode 2 : Règle du 1/10ème',
                montant: '780.00 €',
                description: '10% de la rémunération brute annuelle',
                isAvantageuse: true,
              ),
              const SizedBox(height: AppSpacing.md),

              // Résultat retenu
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📌', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primaryText),
                          children: [
                            const TextSpan(text: 'Indemnité retenue : '),
                            TextSpan(
                              text: '780.00 €',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                                text: ' (méthode la plus favorable)'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _DetailCalculCard(),
      ],
    );
  }
}

class _MethodeCard extends StatelessWidget {
  const _MethodeCard({
    required this.titre,
    required this.montant,
    required this.description,
    required this.isAvantageuse,
  });
  final String titre;
  final String montant;
  final String description;
  final bool isAvantageuse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isAvantageuse
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            montant,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          if (isAvantageuse) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                '✓ Plus avantageuse',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Détail du calcul ─────────────────────────────────────────────────────────

class _DetailCalculCard extends StatelessWidget {
  const _DetailCalculCard();

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
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Center(
              child: Text(
                'i',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CalcRow(label: 'Type de contrat', value: 'Année incomplète (période partielle)'),
                const SizedBox(height: 6),
                _CalcRow(label: 'Semaines travaillées', value: '40 semaines + 10 jours supplémentaires'),
                const SizedBox(height: 6),
                _CalcRow(label: 'Jours de travail / semaine', value: '4 jours'),
                const SizedBox(height: 6),
                _CalcRow(label: 'Acquisition', value: '2,5 jours ouvrables / 4 semaines travaillées'),
                const SizedBox(height: 6),
                _CalcRow(label: 'Méthode de calcul', value: 'Semaines + jours supplémentaires'),
                const SizedBox(height: AppSpacing.sm),

                // Formula box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '[(40 × 4) + 10] × 2,5 ÷ (4 × 4) = 26.6 → arrondi = 27 jours',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Warning
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Résultat toujours arrondi à l\'entier supérieur',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  const _CalcRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryText),
        children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 1 : Simulateur ───────────────────────────────────────────────────────

class _SimulateurContent extends StatefulWidget {
  const _SimulateurContent();

  @override
  State<_SimulateurContent> createState() => _SimulateurContentState();
}

class _SimulateurContentState extends State<_SimulateurContent> {
  String _typeContrat = 'Année incomplète (période partielle)';
  final _semainesCtrl = TextEditingController(text: '40');
  final _joursSupCtrl = TextEditingController(text: '10');
  int _joursParSem = 4;
  final _salaireCtrl = TextEditingController(text: '650');
  final _moisCtrl = TextEditingController(text: '12');
  final _joursCongesCtrl = TextEditingController(text: '0');
  bool _calculated = false;

  static const _types = [
    'Année incomplète (période partielle)',
    'Année complète',
  ];

  static const _joursParSemOptions = [1, 2, 3, 4, 5];

  @override
  void dispose() {
    _semainesCtrl.dispose();
    _joursSupCtrl.dispose();
    _salaireCtrl.dispose();
    _moisCtrl.dispose();
    _joursCongesCtrl.dispose();
    super.dispose();
  }

  bool get _isIncomplet => _typeContrat == 'Année incomplète (période partielle)';

  int get _joursAcquis {
    if (!_isIncomplet) return 30;
    final sem = int.tryParse(_semainesCtrl.text) ?? 0;
    final sup = int.tryParse(_joursSupCtrl.text) ?? 0;
    final jps = _joursParSem;
    if (jps == 0) return 0;
    final raw = ((sem * jps + sup) * 2.5) / (jps * 4);
    return raw.ceil();
  }

  double get _salaireBrut => double.tryParse(_salaireCtrl.text) ?? 0;
  int get _moisTravailles => int.tryParse(_moisCtrl.text) ?? 12;

  // Méthode 1 : maintien de salaire — salaire journalier × jours acquis
  double get _methode1 {
    final jps = _joursParSem;
    if (jps == 0) return 0;
    final salaireJournalier = _salaireBrut / (jps * 52 / 12);
    return salaireJournalier * _joursAcquis;
  }

  // Méthode 2 : 1/10e de la rémunération brute sur la période
  double get _methode2 => _salaireBrut * _moisTravailles * 0.1;

  double get _indemniteRetenue =>
      _methode2 > _methode1 ? _methode2 : _methode1;
  int get _methodeRetenue => _methode2 > _methode1 ? 2 : 1;

  String get _formule {
    if (!_isIncomplet) return '30 jours ouvrables (année complète)';
    final sem = int.tryParse(_semainesCtrl.text) ?? 0;
    final sup = int.tryParse(_joursSupCtrl.text) ?? 0;
    final jps = _joursParSem;
    final raw = ((sem * jps + sup) * 2.5) / (jps * 4);
    return '[($sem × $jps) + $sup] × 2,5 ÷ ($jps × 4) = ${raw.toStringAsFixed(1)} → arrondi = $_joursAcquis jours';
  }

  InputDecoration _deco({String? hint, String? helper}) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
        helperText: helper,
        helperStyle:
            AppTextStyles.labelSmall.copyWith(color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Formulaire ───────────────────────────────
        Container(
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
                  const Text('🧮', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Simulateur de congés payés',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Saisissez vos données pour obtenir le calcul exact selon les règles URSSAF',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.md),

              // Type de contrat
              _SimLabel('Type de contrat'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _typeContrat,
                isExpanded: true,
                decoration: _deco(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryText),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primaryText),
                onChanged: (v) =>
                    setState(() => _typeContrat = v ?? _typeContrat),
              ),

              if (_isIncomplet) ...[
                const SizedBox(height: AppSpacing.md),
                _SimLabel('Semaines travaillées'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _semainesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _deco(),
                  style: AppTextStyles.bodyMedium,
                  onChanged: (_) => setState(() => _calculated = false),
                ),
                const SizedBox(height: AppSpacing.md),
                _SimLabel('Jours supplémentaires'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _joursSupCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _deco(helper: 'Au-delà des semaines entières'),
                  style: AppTextStyles.bodyMedium,
                  onChanged: (_) => setState(() => _calculated = false),
                ),
              ],

              const SizedBox(height: AppSpacing.md),
              _SimLabel('Jours travaillés / semaine'),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _joursParSem,
                isExpanded: true,
                decoration: _deco(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryText),
                items: _joursParSemOptions
                    .map((j) => DropdownMenuItem(
                          value: j,
                          child: Text('$j jour${j > 1 ? 's' : ''}'),
                        ))
                    .toList(),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primaryText),
                onChanged: (v) => setState(() {
                  _joursParSem = v ?? _joursParSem;
                  _calculated = false;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              _SimLabel('Salaire mensuel brut (€)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _salaireCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _deco(),
                style: AppTextStyles.bodyMedium,
                onChanged: (_) => setState(() => _calculated = false),
              ),
              const SizedBox(height: AppSpacing.md),
              _SimLabel('Mois travaillés'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _moisCtrl,
                keyboardType: TextInputType.number,
                decoration: _deco(),
                style: AppTextStyles.bodyMedium,
                onChanged: (_) => setState(() => _calculated = false),
              ),
              const SizedBox(height: AppSpacing.md),
              _SimLabel('Jours de congés à prendre'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _joursCongesCtrl,
                keyboardType: TextInputType.number,
                decoration: _deco(),
                style: AppTextStyles.bodyMedium,
                onChanged: (_) => setState(() => _calculated = false),
              ),
              const SizedBox(height: AppSpacing.md),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => _calculated = true),
                  icon: const Icon(Icons.trending_up_rounded, size: 18),
                  label: const Text('Calculer mes congés'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    textStyle: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Résultats ────────────────────────────────
        if (_calculated) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
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
                    const Text('📊', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Résultats',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Jours acquis
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_joursAcquis',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 36,
                        ),
                      ),
                      Text('jours acquis',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Formule
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    _formule,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Indemnités
                _SimRow(
                  label: 'Méthode 1 — Maintien de salaire',
                  value:
                      '${_methode1.toStringAsFixed(2)} €',
                  valueColor: _methodeRetenue == 1
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  bold: _methodeRetenue == 1,
                ),
                const SizedBox(height: 6),
                _SimRow(
                  label: 'Méthode 2 — 1/10e brut annuel',
                  value: '${_methode2.toStringAsFixed(2)} €',
                  valueColor: _methodeRetenue == 2
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  bold: _methodeRetenue == 2,
                ),
                const Divider(height: 20),
                _SimRow(
                  label: 'Indemnité retenue (méthode $_methodeRetenue)',
                  value: '${_indemniteRetenue.toStringAsFixed(2)} €',
                  valueColor: AppColors.primary,
                  bold: true,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Warning
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Résultat toujours arrondi à l\'entier supérieur',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SimLabel extends StatelessWidget {
  const _SimLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Tab 2 : Historique ───────────────────────────────────────────────────────

class _HistoriqueContent extends StatelessWidget {
  const _HistoriqueContent();

  static const _items = [
    _HistEntry(
      du: '21 juil. 2026',
      au: '4 août 2026',
      jours: 11,
      statut: 'En attente',
      type: 'Congé payé',
    ),
    _HistEntry(
      du: '23 déc. 2025',
      au: '2 janv. 2026',
      jours: 7,
      statut: 'Accepté',
      type: 'Congé payé',
    ),
    _HistEntry(
      du: '14 juil. 2025',
      au: '25 juil. 2025',
      jours: 10,
      statut: 'Accepté',
      type: 'Congé payé',
    ),
    _HistEntry(
      du: '12 mai 2025',
      au: '16 mai 2025',
      jours: 5,
      statut: 'Refusé',
      type: 'Congé sans solde',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _HistCard(entry: e),
            ),
          )
          .toList(),
    );
  }
}

class _HistEntry {
  const _HistEntry({
    required this.du,
    required this.au,
    required this.jours,
    required this.statut,
    required this.type,
  });
  final String du;
  final String au;
  final int jours;
  final String statut;
  final String type;
}

class _HistCard extends StatelessWidget {
  const _HistCard({required this.entry});
  final _HistEntry entry;

  Color get _color {
    return switch (entry.statut) {
      'Accepté' => AppColors.primary,
      'Refusé' => AppColors.error,
      _ => AppColors.accent,
    };
  }

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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.statYellowBg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Icon(Icons.beach_access_outlined,
                size: 22, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Du ${entry.du} au ${entry.au}',
                  style:
                      AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.type} · ${entry.jours} jours',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(
              entry.statut,
              style: AppTextStyles.labelSmall.copyWith(
                color: _color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 3 : Règles URSSAF ────────────────────────────────────────────────────

class _ReglesContent extends StatefulWidget {
  const _ReglesContent();

  @override
  State<_ReglesContent> createState() => _ReglesContentState();
}

class _ReglesContentState extends State<_ReglesContent> {
  final Set<int> _expanded = {0};

  List<_RegleSection> get _sections => [
    _RegleSection(
      emoji: '📅',
      title: 'Période de référence',
      blocks: [
        _RichPara([
          const _Span('La période de référence pour l\'acquisition des congés payés s\'étend du '),
          const _Span('1er juin au 31 mai', bold: true),
          const _Span(' de l\'année suivante.'),
        ]),
        _RichPara([const _Span('C\'est durant cette période que l\'assistante maternelle accumule ses droits à congés.')]),
        _RichPara([
          const _Span('En cas d\'embauche en cours d\'année, les droits sont calculés '),
          const _Span('au prorata', bold: true),
          const _Span(' des mois travaillés.'),
        ]),
      ],
    ),
    _RegleSection(
      emoji: '📊',
      title: 'Acquisition des droits',
      blocks: [
        _RichPara([
          const _Span('L\'assistante maternelle acquiert '),
          const _Span('2,5 jours ouvrables', bold: true),
          const _Span(' de congés par période de 4 semaines travaillées.'),
        ]),
        _RichPara([
          const _Span('Le maximum est de '),
          const _Span('30 jours ouvrables', bold: true),
          const _Span(' par an (soit 5 semaines).'),
        ]),
        _FormulaCard(
          title: 'Calcul selon le contrat :',
          items: [
            _FormulaItem(label: '• Année complète (52 sem.) : 30 jours acquis automatiquement'),
            _FormulaItem(
              label: '• Année incomplète – semaines entières :',
              formula: 'Semaines travaillées × 2,5 ÷ 4 semaines',
              example: 'Ex : 40 sem. × 2,5 ÷ 4 = 25 jours',
            ),
            _FormulaItem(
              label: '• Année incomplète – semaines + jours supplémentaires :',
              formula: '[(Sem. × jours/sem.) + jours ouvrés suppl.] × 2,5 ÷ (4 × jours/sem.)',
              example: 'Ex : [(40 × 4) + 10] × 2,5 ÷ (4 × 4) = 170 × 2,5 ÷ 16\n= 26,5 → 27 jours',
            ),
          ],
          warning: 'Le résultat est toujours arrondi à l\'entier supérieur.',
          footer: 'Ces jours sont acquis quelle que soit la durée hebdomadaire de travail du salarié.',
        ),
      ],
    ),
    _RegleSection(
      emoji: '📋',
      title: 'Calcul de l\'indemnité',
      blocks: [
        _RichPara([
          const _Span('L\'employeur doit appliquer la méthode '),
          const _Span('la plus avantageuse pour le salarié', bold: true),
          const _Span(' :'),
        ]),
        _NumberedList([
          [
            const _Span('Maintien de salaire : ', bold: true),
            const _Span('la même rémunération que si elle avait travaillé'),
          ],
          [
            const _Span('Règle du 1/10ème : ', bold: true),
            const _Span('10% de la rémunération brute totale perçue pendant la période de référence'),
          ],
        ]),
        _NoteCard([
          [
            const _Span('En année complète : ', bold: true),
            const _Span('les congés sont rémunérés quand ils sont pris (en remplacement du salaire).'),
          ],
          [
            const _Span('En année incomplète : ', bold: true),
            const _Span('l\'indemnité s\'ajoute au salaire mensuel de base.'),
          ],
        ]),
      ],
    ),
    _RegleSection(
      emoji: '🏛️',
      title: 'Modalités de paiement',
      blocks: [
        _RichPara([const _Span('L\'indemnité peut être versée :')]),
        _BulletList([
          'En une seule fois au mois de juin',
          'Lors de la prise principale des congés',
          'Au fur et à mesure de la prise des congés',
          'Par douzième chaque mois',
        ]),
        _WarningCard(
          'INTERDIT : Payer les congés par avance de 10% chaque mois dès le début du contrat. Cette pratique est illégale.',
        ),
      ],
    ),
    _RegleSection(
      emoji: '👥',
      title: 'Multi-employeurs & cas particuliers',
      blocks: [
        _RichPara([
          const _Span('Multi-employeurs : ', bold: true),
          const _Span(
              'Les dates de congés doivent être fixées d\'un commun accord avant le 1er mars. Sans accord, l\'assistante maternelle peut fixer 4 semaines l\'été + 1 semaine l\'hiver.'),
        ]),
        _RichPara([
          const _Span('Congés supplémentaires : ', bold: true),
          const _Span('2 jours supplémentaires par enfant à charge.'),
        ]),
        _RichPara([
          const _Span('Fractionnement : ', bold: true),
          const _Span(
              'Possible avec accord du salarié, selon les règles de la convention collective.'),
        ]),
        _RichPara([
          const _Span('Périodes assimilées : ', bold: true),
          const _Span(
              'Les congés déjà acquis, absences rémunérées et jours fériés comptent comme travail effectif pour l\'acquisition.'),
        ]),
      ],
    ),
  ];

  Widget _buildBlock(_ContentBlock block) {
    if (block is _RichPara) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text.rich(
          TextSpan(
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.primaryText, height: 1.5),
            children: block.spans
                .map((s) => TextSpan(
                      text: s.text,
                      style: s.bold
                          ? const TextStyle(fontWeight: FontWeight.w700)
                          : null,
                    ))
                .toList(),
          ),
        ),
      );
    }

    if (block is _NumberedList) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(block.items.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryText, height: 1.5),
                        children: block.items[i]
                            .map((s) => TextSpan(
                                  text: s.text,
                                  style: s.bold
                                      ? const TextStyle(
                                          fontWeight: FontWeight.w700)
                                      : null,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    }

    if (block is _NoteCard) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items.map((spans) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryText, height: 1.5),
                    children: spans
                        .map((s) => TextSpan(
                              text: s.text,
                              style: s.bold
                                  ? const TextStyle(fontWeight: FontWeight.w700)
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (block is _BulletList) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: block.items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryText,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryText, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    }

    if (block is _WarningCard) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.block_rounded, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final card = block as _FormulaCard;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.title,
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            ...card.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.formula != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.formula!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontFamily: 'monospace',
                                  color: AppColors.primaryText,
                                  height: 1.6,
                                ),
                              ),
                              if (item.example != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.example!,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.secondaryText,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
            if (card.warning != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.warning!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (card.footer != null)
              Text(
                card.footer!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Règles des congés payés – Assistante maternelle',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Source : pajemploi.urssaf.fr & Convention collective nationale',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: List.generate(_sections.length, (i) {
              final section = _sections[i];
              final isOpen = _expanded.contains(i);
              final isLast = i == _sections.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: () => setState(() {
                      if (isOpen) _expanded.remove(i); else _expanded.add(i);
                    }),
                    borderRadius: BorderRadius.only(
                      topLeft: i == 0 ? const Radius.circular(AppRadii.md) : Radius.zero,
                      topRight: i == 0 ? const Radius.circular(AppRadii.md) : Radius.zero,
                      bottomLeft: isLast && !isOpen ? const Radius.circular(AppRadii.md) : Radius.zero,
                      bottomRight: isLast && !isOpen ? const Radius.circular(AppRadii.md) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 14),
                      child: Row(
                        children: [
                          Text(section.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(section.title,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ),
                          Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: section.blocks.map(_buildBlock).toList(),
                      ),
                    ),
                  if (!isLast)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.statYellowBg,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryText, height: 1.5),
                    children: [
                      const TextSpan(
                          text:
                              'Ces informations sont données à titre indicatif. Pour toute question spécifique, consultez '),
                      TextSpan(
                        text: 'pajemploi.urssaf.fr',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                      const TextSpan(
                          text: ' ou contactez votre relais RAM.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Data model ──────────────────────────────────────────────────────────────────

class _RegleSection {
  const _RegleSection({
    required this.emoji,
    required this.title,
    required this.blocks,
  });
  final String emoji;
  final String title;
  final List<_ContentBlock> blocks;
}

sealed class _ContentBlock {}

class _RichPara extends _ContentBlock {
  _RichPara(this.spans);
  final List<_Span> spans;
}

class _NumberedList extends _ContentBlock {
  _NumberedList(this.items);
  final List<List<_Span>> items;
}

class _NoteCard extends _ContentBlock {
  _NoteCard(this.items);
  final List<List<_Span>> items;
}

class _BulletList extends _ContentBlock {
  _BulletList(this.items);
  final List<String> items;
}

class _WarningCard extends _ContentBlock {
  _WarningCard(this.text);
  final String text;
}

class _FormulaCard extends _ContentBlock {
  _FormulaCard({
    required this.title,
    required this.items,
    this.warning,
    this.footer,
  });
  final String title;
  final List<_FormulaItem> items;
  final String? warning;
  final String? footer;
}

class _FormulaItem {
  const _FormulaItem({required this.label, this.formula, this.example});
  final String label;
  final String? formula;
  final String? example;
}

class _Span {
  const _Span(this.text, {this.bold = false});
  final String text;
  final bool bold;
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    this.sublabel,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final String? sublabel;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(value,
              style:
                  AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center),
          if (sublabel != null)
            Text(sublabel!,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.hint),
                textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.secondaryText)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
        ),
        Text(value,
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SimRow extends StatelessWidget {
  const _SimRow(
      {required this.label,
      required this.value,
      required this.valueColor,
      this.bold = false});
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: valueColor,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Modal : Poser des congés ─────────────────────────────────────────────────

class _AddHolidaySheet extends StatefulWidget {
  const _AddHolidaySheet();

  @override
  State<_AddHolidaySheet> createState() => _AddHolidaySheetState();
}

class _AddHolidaySheetState extends State<_AddHolidaySheet> {
  String _type = 'Congé payé';
  final _debutCtrl = TextEditingController();
  final _finCtrl = TextEditingController();
  final _motifCtrl = TextEditingController();

  static const _types = [
    'Congé payé',
    'Congé sans solde',
    'Arrêt maladie',
    'Congé maternité / paternité',
    'Autre',
  ];

  static const int _joursRestants = 15;

  @override
  void dispose() {
    _debutCtrl.dispose();
    _finCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {});
    }
  }

  InputDecoration _deco({String? hint, Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                Text('Demande de congés',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.secondaryText,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Type de congé',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _type,
              isExpanded: true,
              decoration: _deco(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.secondaryText),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date de début',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _debutCtrl,
                        readOnly: true,
                        onTap: () => _pickDate(_debutCtrl),
                        decoration: _deco(
                          hint: 'jj/mm/aaaa',
                          suffix: const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.secondaryText),
                        ),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date de fin',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _finCtrl,
                        readOnly: true,
                        onTap: () => _pickDate(_finCtrl),
                        decoration: _deco(
                          hint: 'jj/mm/aaaa',
                          suffix: const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.secondaryText),
                        ),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Motif (optionnel)',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _motifCtrl,
              maxLines: 3,
              decoration: _deco(hint: 'Raison du congé…'),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.primaryText),
                            children: [
                              const TextSpan(text: 'Il vous reste '),
                              TextSpan(
                                text: '$_joursRestants jours',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const TextSpan(text: ' de congés disponibles.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notifications_outlined,
                          size: 16, color: AppColors.secondaryText),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Les parents seront automatiquement notifiés de votre demande.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.beach_access_outlined, size: 20),
                label: const Text('Poser le congé'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle:
                      AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
