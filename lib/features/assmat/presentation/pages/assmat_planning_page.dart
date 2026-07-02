import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_home_page.dart';

const _kMonthsShort = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

class AssMatPlanningPage extends StatefulWidget {
  const AssMatPlanningPage({super.key});

  @override
  State<AssMatPlanningPage> createState() => _AssMatPlanningPageState();
}

class _AssMatPlanningPageState extends State<AssMatPlanningPage> {
  int _tab = 0; // 0 planning semaine, 1 calendrier, 2 congés, 3 stats
  int _year = 2026;

  // Week of 20–24 avril 2026 as the starting mock week
  DateTime _weekStart = DateTime(2026, 4, 20);

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 4));

  void _prevWeek() => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label — à venir'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  String _fmtDateShort(DateTime d) =>
      '${d.day} ${_kMonthsShort[d.month - 1]}';

  String get _weekLabel =>
      'Semaine du ${_fmtDateShort(_weekStart)} au ${_fmtDateShort(_weekEnd)}';

  String get _monthLabel =>
      '${_months[_weekStart.month - 1]} ${_weekStart.year}';

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
            // ── Header ──────────────────────────────────
            Text(
              'Planning & Activité',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 26),
            ),
            const SizedBox(height: 4),
            Text(
              'Planning, congés, statistiques d\'activité',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Export / Partager ────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _stub('Export PDF'),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Export PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryText,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      textStyle: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _stub('Partager'),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Partager'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryText,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      textStyle: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Congés CTA + Year nav ────────────────────
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const _AddHolidaysSheet(),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Poser des congés'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      textStyle: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _year--),
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: AppColors.primaryText,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32),
                    ),
                    Text(
                      '$_year',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _year++),
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: AppColors.primaryText,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Tabs 2×2 ────────────────────────────────
            _TabGrid(current: _tab, onTap: (i) => setState(() => _tab = i)),
            const SizedBox(height: AppSpacing.md),

            // ── Tab content ──────────────────────────────
            switch (_tab) {
              0 => _PlanningSemaineContent(
                  weekLabel: _weekLabel,
                  monthLabel: _monthLabel,
                  onPrev: _prevWeek,
                  onNext: _nextWeek,
                  weekStart: _weekStart,
                  onApply: () => _stub('Appliquer à la semaine'),
                  onExport: () => _stub('Export PDF'),
                ),
              1 => const _CalendrierContent(),
              2 => const _CongesContent(),
              _ => const _StatistiquesContent(),
            },
          ],
        ),
      ),
    );
  }
}

// ─── Tab grid 2×2 ─────────────────────────────────────────────────────────────

class _TabGrid extends StatelessWidget {
  const _TabGrid({required this.current, required this.onTap});
  final int current;
  final ValueChanged<int> onTap;

  static const _labels = [
    'Planning semaine',
    'Calendrier annuel',
    'Congés',
    'Statistiques',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        children: [
          Row(children: [_Tab(0, current, onTap), _Tab(1, current, onTap)]),
          const SizedBox(height: 3),
          Row(children: [_Tab(2, current, onTap, badge: 1), _Tab(3, current, onTap)]),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.index, this.current, this.onTap, {this.badge});
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  final int? badge;

  static const _labels = [
    'Planning semaine',
    'Calendrier annuel',
    'Congés',
    'Statistiques',
  ];

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm - 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _labels[index],
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab 0 : Planning semaine ─────────────────────────────────────────────────

class _PlanningSemaineContent extends StatelessWidget {
  const _PlanningSemaineContent({
    required this.weekLabel,
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
    required this.weekStart,
    required this.onApply,
    required this.onExport,
  });

  final String weekLabel;
  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final DateTime weekStart;
  final VoidCallback onApply;
  final VoidCallback onExport;

  static const _dayNames = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  // Schedule: list of (childName, start, end) per day (from Firebase)
  static const _schedule = <List<(String, String, String)>>[];

  double _slotHours(String start, String end) {
    final s = start.split(':');
    final e = end.split(':');
    final sm = int.parse(s[0]) * 60 + int.parse(s[1]);
    final em = int.parse(e[0]) * 60 + int.parse(e[1]);
    return (em - sm) / 60.0;
  }

  String _fmtH(double h) =>
      h == h.truncateToDouble() ? '${h.toInt()}h' : '${h.toStringAsFixed(1)}h';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week navigator
        Row(
          children: [
            IconButton(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.primaryText,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    weekLabel,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    monthLabel,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppColors.primaryText,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('Appliquer à la semaine'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  textStyle: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Export PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  textStyle: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Hours chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule_outlined,
                  size: 15, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '47h / semaine',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Stats 3 cards
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: Icons.schedule_outlined,
                iconColor: AppColors.primary,
                value: '47h',
                label: 'Total semaine',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.calendar_month_outlined,
                iconColor: AppColors.accent,
                value: '204h',
                label: 'Estimation mois',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.bar_chart_outlined,
                iconColor: AppColors.primary,
                value: '9.4h',
                label: 'Moyenne / jour',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Daily schedule
        // Daily schedule
        ...List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final entries = _schedule[i];
          final totalH = entries.fold(
              0.0, (sum, e) => sum + _slotHours(e.$2, e.$3));

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Day header ──────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dayNames[i],
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${day.day} ${_kMonthsShort[day.month - 1]}.',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      if (entries.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                            border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _fmtH(totalH),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── Time slots ──────────────────────────
                  if (entries.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ...entries.map((e) {
                      final (name, start, end) = e;
                      final h = _slotHours(start, end);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppRadii.sm),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$start → $end',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text.rich(
                                      TextSpan(children: [
                                        TextSpan(
                                          text: name,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                  color: AppColors
                                                      .secondaryText),
                                        ),
                                        TextSpan(
                                          text: ' (${_fmtH(h)})',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit & delete buttons
                              Builder(builder: (ctx) => IconButton(
                                onPressed: () => showModalBottomSheet(
                                  context: ctx,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _AddScheduleSheet(
                                    dayIndex: i,
                                    date: day,
                                    initialStart: start,
                                    initialEnd: end,
                                    initialName: name,
                                  ),
                                ),
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: AppColors.primary),
                                padding: EdgeInsets.zero,
                                constraints:
                                    const BoxConstraints(minWidth: 32, minHeight: 32),
                              )),
                              IconButton(
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Supprimer l\'horaire — à venir'),
                                  behavior: SnackBarBehavior.floating,
                                )),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 18, color: AppColors.error),
                                padding: EdgeInsets.zero,
                                constraints:
                                    const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],

                  // ── + Ajouter ───────────────────────────
                  const SizedBox(height: 4),
                  Builder(builder: (ctx) => GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _AddScheduleSheet(
                        dayIndex: i,
                        date: day,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded,
                              size: 16, color: AppColors.secondaryText),
                          const SizedBox(width: 4),
                          Text(
                            'Ajouter',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          );
        }),

        // ── Récapitulatif par enfant ─────────────
        const SizedBox(height: AppSpacing.sm),
        _ChildSummarySection(schedule: _schedule),

        // ── Barres par jour ──────────────────────
        const SizedBox(height: AppSpacing.sm),
        _WeekDayBarsSection(schedule: _schedule, weekStart: weekStart),
      ],
    );
  }
}

// ─── Tab 1 : Calendrier annuel ────────────────────────────────────────────────

class _CalendrierContent extends StatelessWidget {
  const _CalendrierContent();

  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(12, (m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _MonthCard(month: m + 1, year: 2026, label: _months[m]),
        );
      }),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard(
      {required this.month, required this.year, required this.label});
  final int month;
  final int year;
  final String label;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Monday = 1, Sunday = 7
    final startOffset = (firstDay.weekday - 1) % 7;

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
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          // Day headers
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d) {
              return Expanded(
                child: Center(
                  child: Text(d,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startOffset) return const SizedBox.shrink();
              final day = i - startOffset + 1;
              final date = DateTime(year, month, day);
              final isWeekend = date.weekday >= 6;
              final isToday = date.year == 2026 &&
                  date.month == 4 &&
                  date.day == 23;
              return Container(
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : isWeekend
                          ? AppColors.divider.withValues(alpha: 0.4)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isToday
                          ? AppColors.onPrimary
                          : isWeekend
                              ? AppColors.hint
                              : AppColors.primaryText,
                      fontWeight:
                          isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2 : Congés ───────────────────────────────────────────────────────────

class _CongesContent extends StatelessWidget {
  const _CongesContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CongeCard(
          famille: 'Famille Dupont',
          enfant: 'Lucas',
          du: '21 juil. 2026',
          au: '4 août 2026',
          statut: 'En attente',
          color: AppColors.accent,
        ),
      ],
    );
  }
}

class _CongeCard extends StatelessWidget {
  const _CongeCard({
    required this.famille,
    required this.enfant,
    required this.du,
    required this.au,
    required this.statut,
    required this.color,
  });
  final String famille;
  final String enfant;
  final String du;
  final String au;
  final String statut;
  final Color color;

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
                Text('$famille – $enfant',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Du $du au $au',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(
              statut,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 3 : Statistiques ─────────────────────────────────────────────────────

class _StatistiquesContent extends StatelessWidget {
  const _StatistiquesContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.schedule_outlined,
                iconColor: AppColors.primary,
                iconBg: AppColors.secondary,
                value: '204h',
                label: 'Heures ce mois',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                icon: Icons.euro_rounded,
                iconColor: AppColors.statBlueColor,
                iconBg: AppColors.statBlueBg,
                value: '2 340 €',
                label: 'Revenus estimés',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.child_care_outlined,
                iconColor: AppColors.primary,
                iconBg: AppColors.secondary,
                value: '2',
                label: 'Enfants actifs',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                icon: Icons.bar_chart_outlined,
                iconColor: AppColors.accent,
                iconBg: AppColors.statYellowBg,
                value: '9.4h',
                label: 'Moy. / jour',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _MonthlyBarChart(),
      ],
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  _MonthlyBarChart();

  final _data = const <(String, double)>[];

  @override
  Widget build(BuildContext context) {
    final maxVal = _data.map((e) => e.$2).reduce((a, b) => a > b ? a : b);
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
          Text('Heures par mois — 2026',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _data.map((e) {
                final ratio = maxVal > 0 ? e.$2 / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (e.$2 > 0)
                          Text(
                            '${e.$2.toInt()}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 90 * ratio,
                          decoration: BoxDecoration(
                            color: e.$2 > 0
                                ? AppColors.primary
                                : AppColors.divider,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(e.$1,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
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
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

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
            decoration:
                BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Récapitulatif par enfant ─────────────────────────────────────────────────

class _ChildSummarySection extends StatelessWidget {
  const _ChildSummarySection({required this.schedule});
  final List<List<(String, String, String)>> schedule;

  Map<String, double> get _totals {
    final map = <String, double>{};
    for (final day in schedule) {
      for (final (name, start, end) in day) {
        final s = start.split(':');
        final e = end.split(':');
        final h = (int.parse(e[0]) * 60 + int.parse(e[1]) -
                int.parse(s[0]) * 60 - int.parse(s[1])) /
            60.0;
        map[name] = (map[name] ?? 0) + h;
      }
    }
    return map;
  }

  String _fmtH(double h) =>
      h == h.truncateToDouble() ? '${h.toInt()}.0h' : '${h.toStringAsFixed(1)}h';

  @override
  Widget build(BuildContext context) {
    final totals = _totals;
    final maxH =
        totals.values.isEmpty ? 1.0 : totals.values.reduce((a, b) => a > b ? a : b);

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
              const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Récapitulatif par enfant',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...totals.entries.map((entry) {
            final ratio = maxH > 0 ? entry.value / maxH : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(
                      entry.key,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _fmtH(entry.value),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Barres par jour de la semaine ────────────────────────────────────────────

class _WeekDayBarsSection extends StatelessWidget {
  const _WeekDayBarsSection({required this.schedule, required this.weekStart});
  final List<List<(String, String, String)>> schedule;
  final DateTime weekStart;

  static const _dayAbbr = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  double _dayHours(int i) => schedule[i].fold(0.0, (sum, e) {
        final s = e.$2.split(':');
        final en = e.$3.split(':');
        return sum +
            (int.parse(en[0]) * 60 + int.parse(en[1]) -
                    int.parse(s[0]) * 60 - int.parse(s[1])) /
                60.0;
      });

  String _fmtH(double h) =>
      h == h.truncateToDouble() ? '${h.toInt()}.0h' : '${h.toStringAsFixed(1)}h';

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(5, (i) => _dayHours(i));
    final maxH = hours.isEmpty ? 1.0 : hours.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (i) {
              final h = hours[i];
              final ratio = maxH > 0 ? h / maxH : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dayAbbr[i],
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (_, constraints) => Container(
                          height: 6,
                          width: constraints.maxWidth * ratio,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmtH(h),
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Scroll indicator
          Row(
            children: [
              Icon(Icons.chevron_left_rounded,
                  color: AppColors.secondaryText, size: 20),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.55,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondaryText.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.secondaryText, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Modal : Ajouter un horaire ───────────────────────────────────────────────

class _AddScheduleSheet extends StatefulWidget {
  const _AddScheduleSheet({
    required this.dayIndex,
    required this.date,
    this.initialStart,
    this.initialEnd,
    this.initialName,
  });
  final int dayIndex;
  final DateTime date;
  final String? initialStart;
  final String? initialEnd;
  final String? initialName;

  bool get isEdit => initialStart != null;

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  late int _selectedDay;
  late final TextEditingController _debutCtrl;
  late final TextEditingController _finCtrl;
  late final TextEditingController _enfantCtrl;

  static const _dayNames = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.dayIndex;
    _debutCtrl = TextEditingController(text: widget.initialStart ?? '08:00');
    _finCtrl   = TextEditingController(text: widget.initialEnd   ?? '18:00');
    _enfantCtrl = TextEditingController(text: widget.initialName ?? '');
    _debutCtrl.addListener(() => setState(() {}));
    _finCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debutCtrl.dispose();
    _finCtrl.dispose();
    _enfantCtrl.dispose();
    super.dispose();
  }

  DateTime _dayDate(int i) =>
      widget.date.subtract(Duration(days: widget.dayIndex - i));

  String _dayLabel(int i) {
    final d = _dayDate(i);
    return '${_dayNames[i]} — ${d.day} ${_kMonthsShort[d.month - 1]}';
  }

  double get _duree {
    double _parse(String t) {
      final p = t.split(':');
      if (p.length < 2) return 0;
      return (int.tryParse(p[0]) ?? 0) + (int.tryParse(p[1]) ?? 0) / 60.0;
    }
    final diff = _parse(_finCtrl.text) - _parse(_debutCtrl.text);
    return diff > 0 ? diff : 0;
  }

  String get _dureeLabel =>
      _duree == _duree.truncateToDouble()
          ? '${_duree.toInt()}.0h'
          : '${_duree.toStringAsFixed(1)}h';

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '') ?? 8,
      minute: int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md,
          AppSpacing.md, AppSpacing.md + bottom),
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
            // ── Header ──────────────────────────────────
            Row(
              children: [
                const Spacer(),
                Text(widget.isEdit ? 'Modifier l\'horaire' : 'Ajouter un horaire',
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

            // ── Jour ─────────────────────────────────────
            Text('Jour',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedDay,
              isExpanded: true,
              decoration: _deco(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.secondaryText),
              items: List.generate(
                7,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(_dayLabel(i)),
                ),
              ),
              onChanged: (v) => setState(() => _selectedDay = v ?? _selectedDay),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Début / Fin ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Début',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _debutCtrl,
                        readOnly: true,
                        onTap: () => _pickTime(_debutCtrl),
                        decoration: _deco(
                          suffix: const Icon(Icons.schedule_outlined,
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
                      Text('Fin',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _finCtrl,
                        readOnly: true,
                        onTap: () => _pickTime(_finCtrl),
                        decoration: _deco(
                          suffix: const Icon(Icons.schedule_outlined,
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

            // ── Enfant ───────────────────────────────────
            Text('Enfant (optionnel)',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _enfantCtrl,
              decoration: _deco(hint: 'Nom de l\'enfant'),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Durée calculée ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.secondaryText),
                  children: [
                    const TextSpan(text: 'Durée : '),
                    TextSpan(
                      text: _dureeLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Bouton ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: AppTextStyles.labelLarge
                      .copyWith(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                child: Text(widget.isEdit ? 'Modifier' : 'Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modal : Demande de congés ────────────────────────────────────────────────

class _AddHolidaysSheet extends StatefulWidget {
  const _AddHolidaysSheet();

  @override
  State<_AddHolidaysSheet> createState() => _AddHolidaysSheetState();
}

class _AddHolidaysSheetState extends State<_AddHolidaysSheet> {
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

  static const int _joursRestants = 0;

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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    const isNegative = _joursRestants < 0;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md,
          AppSpacing.md, AppSpacing.md + bottom),
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
            // ── Header ──────────────────────────────────
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

            // ── Type de congé ────────────────────────────
            Text('Type de congé',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500)),
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

            // ── Dates ────────────────────────────────────
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

            // ── Motif ────────────────────────────────────
            Text('Motif (optionnel)',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _motifCtrl,
              maxLines: 4,
              decoration: _deco(hint: 'Raison du congé…'),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Info card ────────────────────────────────
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
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: AppColors.accent),
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
                                  color: isNegative
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
                              const TextSpan(
                                  text: ' de congés disponibles.'),
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
                      const Icon(Icons.arrow_circle_down_outlined,
                          size: 16, color: AppColors.error),
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

            // ── Bouton ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.beach_access_outlined, size: 20),
                label: const Text('Poser le congé'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: AppTextStyles.labelLarge
                      .copyWith(fontWeight: FontWeight.w600),
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
