import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _Feature {
  const _Feature(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const _kGold = Color(0xFFD4900A);
const _kGoldLight = Color(0xFFFFF3CD);
const _kGoldBorder = Color(0xFFFFD060);

class _LockedFeature {
  const _LockedFeature(this.title);
  final String title;
}

class _BonusTile {
  const _BonusTile(this.icon, this.label);
  final IconData icon;
  final String label;
}

// null = cross, '' = checkmark, other string = text label
class _CmpRow {
  const _CmpRow(this.label, this.start, this.pro);
  final String label;
  final String? start;
  final String? pro;
}

const _kStartFeatures = [
  _Feature('Profil visible', 'Créez votre profil professionnel visible par les parents'),
  _Feature('1 contact / jour', 'Accédez à un profil parent par jour'),
  _Feature('5 messages / jour', 'Messagerie limitée à 5 messages quotidiens'),
];

const _kStartLocked = [
  _LockedFeature('Facturation'),
  _LockedFeature('Journal'),
  _LockedFeature('Contrats'),
  _LockedFeature('Documents'),
];

const _kProFeatures = [
  _Feature('Accès illimité aux parents', 'Consultez tous les profils parents en recherche, sans limite'),
  _Feature('Messagerie illimitée', 'Échangez sans restriction avec les parents et collègues'),
  _Feature('Gestion des contrats', 'Créez, suivez et faites signer vos contrats CDI'),
  _Feature('Documents administratifs', 'Centralisez vaccination, autorisations, fiches santé...'),
  _Feature('Planning & congés', 'Calendrier complet avec gestion des disponibilités'),
  _Feature('Feuilles de présence auto', 'Envoi automatique pour signature hebdomadaire'),
  _Feature('Facturation', 'Générez vos factures mensuelles automatiquement'),
  _Feature('Journal quotidien', 'Repas, siestes, activités — tout en un seul endroit'),
  _Feature('Support prioritaire', 'Assistance dédiée sous 24h'),
];

const _kComparison = [
  _CmpRow('Profil visible',          '',        ''),
  _CmpRow('Espace entre assmats',    '',        ''),
  _CmpRow('Contacts parents',        '1/jour',  'Illimité'),
  _CmpRow('Messagerie',              '5/jour',  'Illimitée'),
  _CmpRow('Visibilité prioritaire',  null,      ''),
  _CmpRow('Badge Pro',               null,      ''),
  _CmpRow('Gestion contrats',        null,      ''),
  _CmpRow('Documents & facturation', null,      ''),
  _CmpRow('Planning & congés',       null,      ''),
  _CmpRow('Facturation',             null,      ''),
  _CmpRow('Journal quotidien',       null,      ''),
  _CmpRow('Support prioritaire',     null,      ''),
];

const _kBonusTiles = [
  _BonusTile(Icons.verified_outlined, 'Badge « AMiLY Pro »'),
  _BonusTile(Icons.visibility_outlined, 'Visibilité prioritaire'),
  _BonusTile(Icons.workspace_premium_outlined, 'Mise en avant premium'),
  _BonusTile(Icons.bolt_outlined, 'Accès anticipé'),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatProPage extends StatelessWidget {
  const AssMatProPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _kGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 13, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text('Offres AMiLY',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _BottomBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        children: [
          // ── Hero ──────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0B429), Color(0xFFD4900A)],
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: const Icon(Icons.star_outline_rounded,
                  size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Choisissez l\'offre qui vous correspond',
            style: AppTextStyles.titleLarge
                .copyWith(fontWeight: FontWeight.w800, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'AMiLY accompagne votre activité avec un modèle simple et transparent.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── AMiLY Start card ──────────────────────────
          _PlanCard(
            planName: 'AMiLY Start',
            icon: Icons.person_outline_rounded,
            badgeLabel: 'Gratuit',
            badgeBg: AppColors.divider,
            badgeFg: AppColors.secondaryText,
            price: '0€',
            priceUnit: '/ mois',
            features: _kStartFeatures,
            lockedFeatures: _kStartLocked,
            featureColor: AppColors.primary,
            isCurrent: true,
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── AMiLY Pro card ────────────────────────────
          _PlanCard(
            planName: 'AMiLY Pro',
            icon: Icons.workspace_premium_rounded,
            badgeLabel: 'RECOMMANDÉ',
            badgeBg: _kGold,
            badgeFg: Colors.white,
            price: '5,99€',
            priceUnit: '/ mois',
            features: _kProFeatures,
            featureColor: _kGold,
            highlight: true,
            cornerBadge: true,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Le saviez-vous ? ──────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F4),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: const Color(0xFFB2DFCC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text('Le saviez-vous ?',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryText, height: 1.5),
                    children: const [
                      TextSpan(
                          text:
                              'Chaque famille contribue à hauteur de '),
                      TextSpan(
                          text: '2,99€/mois',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              ' pour les services liés au contrat. Dès '),
                      TextSpan(
                          text: '2 contrats actifs',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              ', les revenus générés côté parents couvrent intégralement votre abonnement AMiLY Pro.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Start vs Pro comparison ───────────────────
          const _ComparisonTable(),
          const SizedBox(height: AppSpacing.md),

          // ── Assistant card ────────────────────────────
          CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.divider,
              radius: AppRadii.md,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: const Icon(Icons.smart_toy_outlined,
                        size: 24, color: AppColors.secondaryText),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assistant administratif & juridique',
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Chatbot IA pour vous aider au quotidien',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryText)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                          ),
                          child: Text('Bientôt disponible',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirection vers le paiement — à venir'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
                icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                label: const Text('Passer à AMiLY Pro — 5,99€/mois'),
                style: FilledButton.styleFrom(
                  backgroundColor: _kGold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined,
                    size: 13, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text('Paiement sécurisé',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText, fontSize: 11)),
                const SizedBox(width: 16),
                const Icon(Icons.bolt_rounded,
                    size: 13, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text('Sans engagement',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Comparison table ─────────────────────────────────────────────────────────

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('Start vs Pro',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          const Divider(height: 1),
          ..._kComparison.map((row) => _CmpRowTile(row: row)),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 10, AppSpacing.md, 10),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 64,
                  child: Center(
                    child: Text('Start',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Center(
                    child: Text('Pro',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: _kGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
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

class _CmpRowTile extends StatelessWidget {
  const _CmpRowTile({required this.row});
  final _CmpRow row;

  Widget _cell(String? value, {required bool isPro}) {
    if (value == null) {
      return const Icon(Icons.close_rounded, size: 16, color: Color(0xFFCCCCCC));
    }
    if (value.isEmpty) {
      return Icon(
        Icons.check_circle_outline_rounded,
        size: 18,
        color: isPro ? _kGold : AppColors.primary,
      );
    }
    return Text(
      value,
      style: AppTextStyles.bodySmall.copyWith(
        color: isPro ? _kGold : AppColors.secondaryText,
        fontWeight: isPro ? FontWeight.w700 : FontWeight.w400,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Text(row.label,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w500)),
              ),
              SizedBox(width: 64, child: Center(child: _cell(row.start, isPro: false))),
              SizedBox(width: 64, child: Center(child: _cell(row.pro, isPro: true))),
            ],
          ),
        ),
        const Divider(height: 1, indent: AppSpacing.md),
      ],
    );
  }
}

// ─── Plan card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.planName,
    required this.icon,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeFg,
    required this.price,
    required this.priceUnit,
    required this.features,
    required this.featureColor,
    this.lockedFeatures = const [],
    this.highlight = false,
    this.isCurrent = false,
    this.cornerBadge = false,
  });

  final String planName;
  final IconData icon;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeFg;
  final String price;
  final String priceUnit;
  final List<_Feature> features;
  final List<_LockedFeature> lockedFeatures;
  final Color featureColor;
  final bool highlight;
  final bool isCurrent;
  final bool cornerBadge;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: highlight ? _kGoldBorder : AppColors.divider,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: highlight
                        ? _kGoldLight
                        : AppColors.divider.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      size: 18,
                      color: highlight ? _kGold : AppColors.secondaryText),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(planName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
                if (!cornerBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(badgeLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: badgeFg,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
              ],
            ),
          ),

          // Price
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                        color: highlight ? _kGold : AppColors.primaryText)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(priceUnit,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.secondaryText)),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Features
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: featureColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.title,
                                    style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(f.subtitle,
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.secondaryText,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                // Locked features
                ...lockedFeatures.map((lf) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              size: 16, color: AppColors.hint),
                          const SizedBox(width: 10),
                          Text(
                            lf.title,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.hint,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.hint,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // Bonus tiles grid (Pro only)
          if (highlight) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.4,
                children: _kBonusTiles
                    .map((t) => Container(
                          decoration: BoxDecoration(
                            color: _kGoldLight,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(t.icon, size: 18, color: _kGold),
                              const SizedBox(height: 4),
                              Text(t.label,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],

          if (isCurrent)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text('Votre offre actuelle',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );

    if (!cornerBadge) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadii.md),
                bottomLeft: Radius.circular(AppRadii.sm),
              ),
            ),
            child: Text(badgeLabel,
                style: AppTextStyles.bodySmall.copyWith(
                    color: badgeFg,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5)),
          ),
        ),
      ],
    );
  }
}

// ─── Dashed border painter ────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashW = 6.0;
    const gapW = 4.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dashW), paint);
        dist += dashW + gapW;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
