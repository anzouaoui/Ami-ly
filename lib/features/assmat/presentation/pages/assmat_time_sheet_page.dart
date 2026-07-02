import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';


const _kMonthsFull = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatTimeSheetPage extends StatefulWidget {
  const AssMatTimeSheetPage({super.key});

  @override
  State<AssMatTimeSheetPage> createState() => _AssMatTimeSheetPageState();
}

class _AssMatTimeSheetPageState extends State<AssMatTimeSheetPage> {
  String? _selectedMonth;

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
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Page header ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Icons.assignment_turned_in_outlined,
                    size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Feuilles de présence',
                        style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800, fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      'Suivi des heures effectuées et signature hebdomadaire par les parents.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Génération hebdomadaire ──────────────────
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
                Text('Génération hebdomadaire',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Génère et envoie pour signature les feuilles de la semaine passée.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Génération en cours — à venir'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Générer la semaine passée'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      textStyle: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Export PDF mensuel ───────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EE),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: const Color(0xFFFFD4A8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined,
                        size: 20, color: Color(0xFFE07830)),
                    const SizedBox(width: 8),
                    Text('Export PDF mensuel',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Téléchargez en un seul PDF toutes les feuilles signées du mois — utile pour Pajemploi, la CAF ou vos archives.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Mois :',
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  hint: const SizedBox.shrink(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide:
                          const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide:
                          const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondaryText),
                  items: _kMonthsFull
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m,
                                style: AppTextStyles.bodySmall),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedMonth = v),
                ),
                if (_selectedMonth != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Export PDF $_selectedMonth — à venir'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text('Télécharger $_selectedMonth'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE07830),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.md),
                        ),
                        textStyle: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── En attente de signature ──────────────────
          _PendingSignatureSection(
            onSendForSignature: () =>
                ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rappel envoyé aux parents'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Signées ──────────────────────────────────
          const _SignedSection(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Pending signature section ────────────────────────────────────────────────

class _PendingItem {
  const _PendingItem(
      {required this.childName, required this.weekLabel, required this.total});
  final String childName;
  final String weekLabel;
  final String total;
}

const _kPendingItems = <_PendingItem>[];

class _PendingSignatureSection extends StatelessWidget {
  const _PendingSignatureSection({required this.onSendForSignature});
  final VoidCallback onSendForSignature;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En attente de signature (${_kPendingItems.length})',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._kPendingItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.childName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    '${item.weekLabel} • ${item.total}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(
                      'En attente de signature',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF856404),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _IconActionBtn(
                        icon: Icons.visibility_outlined,
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Aperçu — à venir'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _IconActionBtn(
                        icon: Icons.notifications_outlined,
                        onTap: onSendForSignature,
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _IconActionBtn extends StatelessWidget {
  const _IconActionBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryText),
      ),
    );
  }
}

// ─── Signed section ───────────────────────────────────────────────────────────

class _SignedItem {
  const _SignedItem(
      {required this.childName, required this.weekLabel, required this.total});
  final String childName;
  final String weekLabel;
  final String total;
}

const _kSignedItems = <_SignedItem>[];

class _SignedSection extends StatelessWidget {
  const _SignedSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signées (${_kSignedItems.length})',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._kSignedItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.childName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    '${item.weekLabel} • ${item.total}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4EDDA),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(
                      'Signée',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF155724),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _IconActionBtn(
                    icon: Icons.visibility_outlined,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aperçu — à venir'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

