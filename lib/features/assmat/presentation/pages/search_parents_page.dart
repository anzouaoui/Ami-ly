import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _ChildData {
  const _ChildData({
    required this.firstName,
    required this.age,
    required this.interests,
  });

  final String firstName;
  final String age;
  final List<String> interests;
}

class _FamilyData {
  const _FamilyData({
    required this.displayName,
    required this.initials,
    required this.city,
    required this.startDate,
    required this.scheduleType,
    required this.schedule,
    required this.avatarColor,
    this.tags = const [],
    this.kids = const [],
    this.quote,
  });

  final String displayName;
  final String initials;
  final String city;
  final String startDate;
  final String scheduleType;
  final String schedule;
  final Color avatarColor;
  final List<String> tags;
  final List<_ChildData> kids;
  final String? quote;
}

const _families = <_FamilyData>[];

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class SearchParentsPage extends StatefulWidget {
  const SearchParentsPage({super.key});

  @override
  State<SearchParentsPage> createState() => _SearchParentsPageState();
}

class _SearchParentsPageState extends State<SearchParentsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FamilyData> get _filtered {
    if (_query.isEmpty) return _families;
    final q = _query.toLowerCase();
    return _families
        .where((f) =>
            f.city.toLowerCase().contains(q) ||
            f.displayName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        size: 28, color: AppColors.secondaryText),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Parents en recherche',
                        style: AppTextStyles.headlineMedium
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Consultez les familles qui recherchent une assistante maternelle '
                  'et envoyez une demande de contact',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),

          // Search card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: AppShadows.sm,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par ville...',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.secondaryText),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.secondaryText, size: 22),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusChip(
                    label:
                        '${filtered.length} famille${filtered.length > 1 ? 's' : ''} en recherche',
                    dotColor: const Color(0xFF4CAF50),
                    bgColor: const Color(0xFFE8F5E9),
                    textColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Family list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Aucune famille trouvée',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) =>
                        _FamilyCard(family: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Family card
// ---------------------------------------------------------------------------

class _FamilyCard extends StatefulWidget {
  const _FamilyCard({required this.family});
  final _FamilyData family;

  @override
  State<_FamilyCard> createState() => _FamilyCardState();
}

class _FamilyCardState extends State<_FamilyCard> {
  bool _contacted = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.family;
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
          // ── Header row ───────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: f.avatarColor,
                child: Text(
                  f.initials,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          f.displayName,
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const _StatusChip(
                          label: 'En recherche',
                          dotColor: Color(0xFF4CAF50),
                          bgColor: Color(0xFFE8F5E9),
                          textColor: Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 2),
                        Text(f.city,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Critères de recherche ─────────────────────────────────────
          Text(
            'CRITÈRES DE RECHERCHE',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          _CriteriaRow(
            icon: Icons.event_outlined,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primaryText),
                children: [
                  const TextSpan(text: 'Début :  '),
                  TextSpan(
                    text: f.startDate,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _CriteriaRow(
            icon: Icons.schedule_outlined,
            child: Text(f.scheduleType,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primaryText)),
          ),
          const SizedBox(height: AppSpacing.xs),
          _CriteriaRow(
            icon: Icons.child_friendly_outlined,
            child: Text(
              '${f.kids.length} enfant${f.kids.length > 1 ? 's' : ''}',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.primaryText),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _CriteriaRow(
            icon: Icons.work_outline_rounded,
            child: Text(f.schedule,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText)),
          ),

          // ── Tags ──────────────────────────────────────────────────────
          if (f.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: f.tags.map((t) => _OutlinedChip(label: t)).toList(),
            ),
          ],

          // ── Children cards ────────────────────────────────────────────
          if (f.kids.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...f.kids.map((k) => Padding(
                  padding: EdgeInsets.only(
                      bottom: k != f.kids.last ? AppSpacing.sm : 0),
                  child: _ChildCard(child: k),
                )),
          ],

          // ── Quote ─────────────────────────────────────────────────────
          if (f.quote != null) ...[
            const SizedBox(height: AppSpacing.md),
            _QuoteBlock(text: f.quote!),
          ],

          const SizedBox(height: AppSpacing.md),

          // ── Action button ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _contacted
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(
                            Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Demande envoyée'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: () => setState(() => _contacted = true),
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: const Text('Demander un contact'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                        ),
                      ),
              ),
              if (!_contacted) ...[
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Text(
                    'Le parent recevra\nvotre profil',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ],
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.dotColor,
    required this.bgColor,
    required this.textColor,
  });

  final String label;
  final Color dotColor;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  const _CriteriaRow({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}

class _OutlinedChip extends StatelessWidget {
  const _OutlinedChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child});
  final _ChildData child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F5),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.child_friendly_outlined,
                size: 20, color: Color(0xFFE07A5F)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText),
                    children: [
                      TextSpan(
                        text: child.firstName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: '  (${child.age})',
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                if (child.interests.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    child.interests.join('   '),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
