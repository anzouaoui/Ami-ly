import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_contract_detail_page.dart';
import 'assmat_home_page.dart';
import 'assmat_contract_models.dart';
import 'assmat_new_contract_page.dart';

const _fullWeek = [
  ('Lundi', '08:00 – 18:00'),
  ('Mardi', '08:00 – 18:00'),
  ('Mercredi', '08:00 – 18:00'),
  ('Jeudi', '08:00 – 18:00'),
  ('Vendredi', '08:00 – 18:00'),
];

const _partWeek = [
  ('Mardi', '09:00 – 17:00'),
  ('Mercredi', '09:00 – 17:00'),
  ('Jeudi', '09:00 – 17:00'),
];

const _contracts = <ContractData>[];

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class AssMatContractPage extends StatefulWidget {
  const AssMatContractPage({super.key});

  @override
  State<AssMatContractPage> createState() => _AssMatContractPageState();
}

class _AssMatContractPageState extends State<AssMatContractPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ContractData> get _filtered {
    if (_query.isEmpty) return _contracts;
    final q = _query.toLowerCase();
    return _contracts
        .where((c) =>
            c.familyName.toLowerCase().contains(q) ||
            c.childName.toLowerCase().contains(q))
        .toList();
  }

  int get _activeCount =>
      _contracts.where((c) => c.status == ContractStatus.active).length;

  String get _totalMonthly {
    double total = 0;
    for (final c in _contracts.where((c) => c.status == ContractStatus.active)) {
      final clean = c.monthlyAmount.replaceAll(RegExp(r'[^\d]'), '');
      total += double.tryParse(clean) ?? 0;
    }
    return '${total.toStringAsFixed(0)} €';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 24),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menu',
          ),
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
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // CTA
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

                // Stat row
                Row(
                  children: [
                    Expanded(
                      child: _PageStatCard(
                        icon: Icons.work_outline_rounded,
                        iconColor: AppColors.primary,
                        value: '$_activeCount',
                        label: 'Contrats actifs',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PageStatCard(
                        icon: Icons.euro_rounded,
                        iconColor: AppColors.primary,
                        value: _totalMonthly,
                        label: 'Total mensuel',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PageStatCard(
                        icon: Icons.child_friendly_outlined,
                        iconColor: AppColors.accent,
                        value: '$_activeCount',
                        label: 'Enfants accueillis',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Search
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
              ],
            ),
          ),

          // ── Contract list ────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('Aucun contrat trouvé',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondaryText)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) =>
                        _ContractCard(contract: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page stat card (top summary)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Contract card
// ---------------------------------------------------------------------------

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.contract});
  final ContractData contract;

  @override
  Widget build(BuildContext context) {
    final c = contract;

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
          // ── Header: avatar + child name + family + status badge ──────────
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: c.avatarColor,
                child: Text(
                  c.childName[0],
                  style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700, color: Colors.black54),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.childName,
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(c.familyName,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
              _StatusBadge(status: c.status),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Mini stat row ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.schedule_outlined,
                  value: c.hoursPerWeek,
                  label: '/ semaine',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  icon: Icons.euro_outlined,
                  value: c.monthlyAmount,
                  label: '/ mois',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  icon: Icons.calendar_today_outlined,
                  value: c.weeksPerYear,
                  label: 'complète',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),

          // ── Footer: start date + voir détails ────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Début : ${c.startDate}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      AssMatContractDetailPage(contract: contract),
                )),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir détails',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryText),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w800)),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
