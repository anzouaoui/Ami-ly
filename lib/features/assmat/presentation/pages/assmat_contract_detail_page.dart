import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_contract_models.dart';

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class AssMatContractDetailPage extends StatefulWidget {
  const AssMatContractDetailPage({super.key, required this.contract});
  final ContractData contract;

  @override
  State<AssMatContractDetailPage> createState() =>
      _AssMatContractDetailPageState();
}

class _AssMatContractDetailPageState extends State<AssMatContractDetailPage> {
  int _tabIndex = 0;

  static const _tabs = ['Contrat', 'Suivi mensuel', 'Pajemploi'];

  @override
  Widget build(BuildContext context) {
    final c = widget.contract;
    final isActive = c.status == ContractStatus.active;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(c.childName,
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(width: AppSpacing.sm),
                _StatusBadge(status: c.status),
              ],
            ),
            Text(c.familyName,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_outlined,
                        size: 16, color: AppColors.primaryText),
                    const SizedBox(width: 6),
                    Text('PDF',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primaryText)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Segmented tab bar ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final active = i == _tabIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          boxShadow: active ? AppShadows.sm : null,
                        ),
                        child: Text(
                          _tabs[i],
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? AppColors.primaryText
                                : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Tab content ──────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _ContratTab(contract: c, isActive: isActive),
                _SuiviMensuelTab(contract: c),
                _PajemploiTab(contract: c),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 — Contrat
// ---------------------------------------------------------------------------

class _ContratTab extends StatelessWidget {
  const _ContratTab({required this.contract, required this.isActive});
  final ContractData contract;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final c = contract;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat grid 2×2
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.schedule_outlined,
                  iconColor: AppColors.primary,
                  value: c.hoursPerWeek,
                  label: '/ semaine',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.euro_outlined,
                  iconColor: AppColors.primary,
                  value: c.baseSalary,
                  label: 'salaire mensuel',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.bar_chart_rounded,
                  iconColor: AppColors.accent,
                  value: c.monthlyAmount,
                  label: 'total mensuel',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF26A69A),
                  value: c.vacationWeeks,
                  label: 'sem. congés',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Contract details card
          _SectionCard(
            title: 'Informations du contrat CDI',
            groups: [
              [
                _DetailRow(
                  label: 'Type',
                  value: 'Année complète (${c.weeksPerYear} sem)',
                ),
                _DetailRow(label: 'Début', value: c.startDate),
                _DetailRow(label: 'Fin', value: c.contractEndDate),
              ],
              [
                _DetailRow(label: 'Tarif horaire net', value: c.hourlyRateNet),
                _DetailRow(label: 'Tarif horaire brut', value: c.hourlyRateGross),
                _DetailRow(label: 'Heures mensualisées', value: c.monthlyHours),
              ],
              [
                _DetailRow(label: 'Entretien/h', value: c.maintenanceRate),
                _DetailRow(label: 'Repas/j', value: c.mealRate),
              ],
              [
                _DetailRow(label: 'Repos hebdo', value: c.weeklyRest),
                _DetailRow(label: '1er Mai', value: c.mayFirst),
                _DetailRow(label: 'Pajemploi+', value: c.pajemploiPlus),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Planning hebdomadaire
          _SectionCard(
            title: 'Planning hebdomadaire',
            children: [
              const SizedBox(height: AppSpacing.xs),
              ...c.weeklySchedule.asMap().entries.map((e) {
                final isEven = e.key.isEven;
                final (day, hours) = e.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 10),
                  decoration: BoxDecoration(
                    color: isEven ? AppColors.background : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(day,
                            style: AppTextStyles.bodySmall
                                .copyWith(fontWeight: FontWeight.w700)),
                      ),
                      Text(hours,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                );
              }),
            ],
          ),

          if (isActive) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('Télécharger'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 — Suivi mensuel
// ---------------------------------------------------------------------------

class _SuiviMensuelTab extends StatefulWidget {
  const _SuiviMensuelTab({required this.contract});
  final ContractData contract;

  @override
  State<_SuiviMensuelTab> createState() => _SuiviMensuelTabState();
}

class _SuiviMensuelTabState extends State<_SuiviMensuelTab> {
  static const _monthLabels = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  int _selectedMonth = 2; // 0-based → Mars
  int _selectedYear = 2026;

  final _hoursCtrl = TextEditingController(text: '168');
  final _absenceCtrl = TextEditingController(text: '0');
  final _congesCtrl = TextEditingController(text: '0');
  final _adjustCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _hoursCtrl.addListener(_rebuild);
    _absenceCtrl.addListener(_rebuild);
    _congesCtrl.addListener(_rebuild);
    _adjustCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _hoursCtrl.removeListener(_rebuild);
    _absenceCtrl.removeListener(_rebuild);
    _congesCtrl.removeListener(_rebuild);
    _adjustCtrl.removeListener(_rebuild);
    _hoursCtrl.dispose();
    _absenceCtrl.dispose();
    _congesCtrl.dispose();
    _adjustCtrl.dispose();
    super.dispose();
  }

  String get _monthLabel => '${_monthLabels[_selectedMonth]} $_selectedYear';

  // ── Calculation helpers ──────────────────────────────────────────────────

  double get _hours => double.tryParse(_hoursCtrl.text) ?? 0;
  double get _absenceDays => double.tryParse(_absenceCtrl.text) ?? 0;
  double get _adjustment => double.tryParse(_adjustCtrl.text) ?? 0;

  double get _baseSalary => _parseNum(widget.contract.baseSalary);
  double get _maintenanceRate => _parseNum(widget.contract.maintenanceRate);
  double get _mealRate => _parseNum(widget.contract.mealRate);
  double get _hourlyRateNet => _parseNum(widget.contract.hourlyRateNet);

  double get _workingDays => _hours / 8;

  double get _salaryAdjusted {
    if (_absenceDays <= 0) return _baseSalary;
    final dailyRate = _baseSalary / 21;
    return (_baseSalary - _absenceDays * dailyRate).clamp(0, double.infinity);
  }

  double get _indemnites => (_maintenanceRate + _mealRate) * _workingDays;
  double get _totalAPayer => _salaryAdjusted + _indemnites + _adjustment;

  // CMG 2026: plafond taux horaire net ≈ 14.93 € (tranche haute)
  bool get _cmgRespected => _hourlyRateNet <= 14.93;

  void _showMonthPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MonthPickerSheet(
        initialMonth: _selectedMonth,
        initialYear: _selectedYear,
        onSelected: (m, y) => setState(() {
          _selectedMonth = m;
          _selectedYear = y;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plannedHours = widget.contract.monthlyHours;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month selector + validate button ──────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showMonthPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_monthLabel,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 22, color: AppColors.secondaryText),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_monthLabel validé'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Valider le mois'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Input grid 2×2 ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _InputCard(
                  label: 'Heures réalisées',
                  controller: _hoursCtrl,
                  helper: 'Prévu : $plannedHours',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InputCard(
                  label: "Jours d'absence",
                  controller: _absenceCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InputCard(
                  label: 'Jours de congés',
                  controller: _congesCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InputCard(
                  label: 'Ajustement (€)',
                  controller: _adjustCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Résumé calculé ────────────────────────────────────────────
          _SummaryCard(
            title: 'Résumé du mois – $_monthLabel',
            baseSalary: _baseSalary,
            salaryAdjusted: _salaryAdjusted,
            indemnites: _indemnites,
            adjustment: _adjustment,
            total: _totalAPayer,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Statut CMG ────────────────────────────────────────────────
          _CmgStatusCard(respected: _cmgRespected),

          const SizedBox(height: AppSpacing.lg),

          // ── Historique des mois ───────────────────────────────────────
          _HistorySection(history: _mockHistory),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  static const _mockHistory = [
    _MonthHistory(month: 'Mars',    year: 2026, hours: 168, validated: false),
    _MonthHistory(month: 'Février', year: 2026, hours: 160, adjustment: -36, validated: true),
    _MonthHistory(month: 'Janvier', year: 2026, hours: 176, adjustment: 12,  validated: true),
  ];
}

// Month picker bottom sheet
class _MonthPickerSheet extends StatefulWidget {
  const _MonthPickerSheet({
    required this.initialMonth,
    required this.initialYear,
    required this.onSelected,
  });

  final int initialMonth;
  final int initialYear;
  final void Function(int month, int year) onSelected;

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  static const _labels = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    _month = widget.initialMonth;
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() => _year--),
              ),
              Text('$_year',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => setState(() => _year++),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Month grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.0,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(12, (i) {
              final selected = i == _month;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onSelected(i, _year);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    _labels[i].substring(0, 3),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: selected ? AppColors.onPrimary : AppColors.primaryText,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History data model
// ---------------------------------------------------------------------------

class _MonthHistory {
  const _MonthHistory({
    required this.month,
    required this.year,
    required this.hours,
    required this.validated,
    this.adjustment,
  });

  final String month;
  final int year;
  final double hours;
  final bool validated;
  final double? adjustment;
}

// ---------------------------------------------------------------------------
// History section
// ---------------------------------------------------------------------------

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.history});
  final List<_MonthHistory> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historique des mois',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.md),
        ...history.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _HistoryRow(entry: h),
            )),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});
  final _MonthHistory entry;

  @override
  Widget build(BuildContext context) {
    final adj = entry.adjustment;
    final adjColor = (adj ?? 0) >= 0 ? AppColors.primary : AppColors.error;
    final adjText =
        adj == null ? null : '${adj >= 0 ? '+' : ''}${adj.toStringAsFixed(0)}€';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            entry.validated
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_outlined,
            size: 20,
            color: entry.validated
                ? AppColors.primary
                : const Color(0xFFF5A623),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${entry.month} ${entry.year}',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${entry.hours.toStringAsFixed(0)}h',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          if (adjText != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(adjText,
                style: AppTextStyles.bodySmall.copyWith(
                    color: adjColor, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.hint),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.baseSalary,
    required this.salaryAdjusted,
    required this.indemnites,
    required this.adjustment,
    required this.total,
  });

  final String title;
  final double baseSalary;
  final double salaryAdjusted;
  final double indemnites;
  final double adjustment;
  final double total;

  String _fmt(double v) => '${v.toStringAsFixed(2)} €';

  @override
  Widget build(BuildContext context) {
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
          Text(title,
              style:
                  AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
              label: 'Salaire net mensualisé', value: _fmt(baseSalary)),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
              label: 'Salaire net ajusté', value: _fmt(salaryAdjusted)),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
              label: 'Indemnités (entretien + repas)',
              value: _fmt(indemnites)),
          if (adjustment != 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(label: 'Ajustement', value: _fmt(adjustment)),
          ],
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Total à payer',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(
                  _fmt(total),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
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
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CMG status card
// ---------------------------------------------------------------------------

class _CmgStatusCard extends StatelessWidget {
  const _CmgStatusCard({required this.respected});
  final bool respected;

  @override
  Widget build(BuildContext context) {
    final color = respected ? AppColors.primary : AppColors.error;
    final bgColor = respected
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFCE4EC);
    final icon = respected
        ? Icons.verified_outlined
        : Icons.warning_amber_rounded;
    final title = respected ? 'Plafonds CMG respectés' : 'Plafonds CMG dépassés';
    final subtitle = respected
        ? 'Aucun dépassement détecté pour ce mois.'
        : 'Vérifiez le tarif horaire net applicable.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.labelMedium.copyWith(
                        color: color, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input card
// ---------------------------------------------------------------------------

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.label,
    required this.controller,
    this.helper,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.number,
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(helper!,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.secondaryText)),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3 — Pajemploi
// ---------------------------------------------------------------------------

// Parses the first number from contract strings like '3.5 €', '4 € (assmat)'
double _parseNum(String s) {
  final m = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(s);
  if (m == null) return 0;
  return double.tryParse(m.group(0)!.replaceAll(',', '.')) ?? 0;
}

class _PajemploiTab extends StatefulWidget {
  const _PajemploiTab({required this.contract});
  final ContractData contract;

  @override
  State<_PajemploiTab> createState() => _PajemploiTabState();
}

class _PajemploiTabState extends State<_PajemploiTab> {
  static const _monthLabels = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  int _selectedMonth = 2;
  int _selectedYear = 2026;

  String get _monthLabel => '${_monthLabels[_selectedMonth]} $_selectedYear';

  void _showMonthPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MonthPickerSheet(
        initialMonth: _selectedMonth,
        initialYear: _selectedYear,
        onSelected: (m, y) => setState(() {
          _selectedMonth = m;
          _selectedYear = y;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contract;

    final baseSalary       = _parseNum(c.baseSalary);
    final plannedHours     = _parseNum(c.monthlyHours);
    final maintenanceRate  = _parseNum(c.maintenanceRate);
    final mealRate         = _parseNum(c.mealRate);
    final workingDays      = plannedHours / 8;
    final indemEntretien   = maintenanceRate * workingDays;
    final indemRepas       = mealRate * workingDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month selector ──────────────────────────────────────────────
          GestureDetector(
            onTap: _showMonthPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_monthLabel,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 22, color: AppColors.secondaryText),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Récapitulatif card ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: const Color(0xFFB2DFDB)),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.send_rounded,
                          size: 20, color: Color(0xFF26A69A)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Récapitulatif Pajemploi – $_monthLabel',
                              style: AppTextStyles.titleMedium
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Informations à reporter sur pajemploi.urssaf.fr',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats block
                Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    children: [
                      _PajemploiStat(
                        label: "NOMBRE D'HEURES",
                        value: '${plannedHours.toStringAsFixed(0)}h',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _PajemploiStat(
                        label: 'SALAIRE NET',
                        value: '${baseSalary.toStringAsFixed(2)} €',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _PajemploiStat(
                        label: "INDEMNITÉS D'ENTRETIEN",
                        value: '${indemEntretien.toStringAsFixed(2)} €',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _PajemploiStat(
                        label: 'INDEMNITÉS DE REPAS',
                        value: '${indemRepas.toStringAsFixed(2)} €',
                      ),
                    ],
                  ),
                ),

                // ── Action buttons ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: Column(
                    children: [
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label:
                            const Text('Générer déclaration Pajemploi'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize:
                              const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined,
                            size: 18),
                        label: const Text('Télécharger PDF'),
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(double.infinity, 48),
                          foregroundColor: AppColors.primaryText,
                          side: const BorderSide(
                              color: AppColors.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadii.md),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Historique des déclarations ──────────────────────────────
          Text('Historique des déclarations',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          ..._mockDeclarations.map((d) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _DeclarationRow(declaration: d),
              )),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  static const _mockDeclarations = [
    _PajemploiDeclaration(
        month: 'Février', year: 2026, hours: 160, total: 744.0),
    _PajemploiDeclaration(
        month: 'Janvier', year: 2026, hours: 176, total: 792.0),
  ];
}

class _PajemploiDeclaration {
  const _PajemploiDeclaration({
    required this.month,
    required this.year,
    required this.hours,
    required this.total,
  });

  final String month;
  final int year;
  final double hours;
  final double total;
}

class _DeclarationRow extends StatelessWidget {
  const _DeclarationRow({required this.declaration});
  final _PajemploiDeclaration declaration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(declaration.month,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('${declaration.year}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
          Text(
            '${declaration.hours.toStringAsFixed(0)}h',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              '${declaration.total.toStringAsFixed(2)} €',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              'Déclaré',
              style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PajemploiStat extends StatelessWidget {
  const _PajemploiStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondaryText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
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
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    this.children,
    this.groups,
  }) : assert(children != null || groups != null);

  final String title;
  // Flat list of rows (no group dividers)
  final List<Widget>? children;
  // Grouped rows — each group is separated by a divider
  final List<List<Widget>>? groups;

  @override
  Widget build(BuildContext context) {
    final allGroups = groups ?? [children!];

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
          Text(title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: AppSpacing.md),
          for (int g = 0; g < allGroups.length; g++) ...[
            if (g > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.divider),
            ],
            ...allGroups[g].map((row) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: row,
                )),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ContractStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, borderColor, textColor) = switch (status) {
      ContractStatus.active => (
          'Actif',
          const Color(0xFF4CAF50),
          const Color(0xFF2E7D32),
        ),
      ContractStatus.suspended => (
          'Suspendu',
          const Color(0xFFFFC107),
          const Color(0xFFF57F17),
        ),
      ContractStatus.ended => (
          'Terminé',
          AppColors.hint,
          AppColors.secondaryText,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: borderColor),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall
              .copyWith(color: textColor, fontWeight: FontWeight.w700)),
    );
  }
}
