import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class AssMatInvoicePage extends StatefulWidget {
  const AssMatInvoicePage({super.key});

  @override
  State<AssMatInvoicePage> createState() => _AssMatInvoicePageState();
}

class _AssMatInvoicePageState extends State<AssMatInvoicePage> {
  int _tab = 0;

  static const _tabs = ['Factures', 'Promesses d\'embauche', 'Contrats'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              'Facturation & Documents',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 26),
            ),
            const SizedBox(height: 4),
            Text(
              'Gérez vos factures, contrats et documents administratifs',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Export Pajemploi ────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send_outlined, size: 18),
                label: const Text('Export Pajemploi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Stats 2×2 ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.euro_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.secondary,
                    value: '2 340 €',
                    label: 'Revenus du mois',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt_outlined,
                    iconColor: AppColors.statBlueColor,
                    iconBg: AppColors.statBlueBg,
                    value: '2',
                    label: 'Factures ce mois',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.task_outlined,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.secondary,
                    value: '2',
                    label: 'Contrats actifs',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.note_add_outlined,
                    iconColor: AppColors.accent,
                    iconBg: AppColors.statYellowBg,
                    value: '1',
                    label: 'Promesse en attente',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Tabs ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = _tab == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppRadii.sm - 2),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.06),
                                    blurRadius: 4,
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
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
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Tab content ─────────────────────────────
            switch (_tab) {
              0 => const _FacturesContent(),
              1 => const _PromessesContent(),
              _ => const _ContratsContent(),
            },
          ],
        ),
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

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
          Text(
            value,
            style: AppTextStyles.titleLarge
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Factures ────────────────────────────────────────────────────────────

class _FacturesContent extends StatelessWidget {
  const _FacturesContent();

  static const _factures = [
    _FactureData(
      famille: 'Famille Dupont',
      enfant: 'Lucas',
      mois: 'Mars 2026',
      montant: '780 €',
      statut: _FactureStatut.payee,
      datePaiement: '01/04/2026',
    ),
    _FactureData(
      famille: 'Famille Leroy',
      enfant: 'Emma',
      mois: 'Mars 2026',
      montant: '588 €',
      statut: _FactureStatut.payee,
      datePaiement: '01/04/2026',
    ),
    _FactureData(
      famille: 'Famille Dupont',
      enfant: 'Lucas',
      mois: 'Février 2026',
      montant: '756 €',
      statut: _FactureStatut.payee,
      datePaiement: '01/03/2026',
    ),
    _FactureData(
      famille: 'Famille Leroy',
      enfant: 'Emma',
      mois: 'Février 2026',
      montant: '588 €',
      statut: _FactureStatut.enAttente,
      datePaiement: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _NewInvoiceSheet(),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Générer une facture'),
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
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < _factures.length; i++) ...[
          _FactureTile(data: _factures[i]),
          if (i < _factures.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

enum _FactureStatut { payee, enAttente }

class _FactureData {
  const _FactureData({
    required this.famille,
    required this.enfant,
    required this.mois,
    required this.montant,
    required this.statut,
    required this.datePaiement,
  });
  final String famille;
  final String enfant;
  final String mois;
  final String montant;
  final _FactureStatut statut;
  final String? datePaiement;
}

class _FactureTile extends StatelessWidget {
  const _FactureTile({required this.data});
  final _FactureData data;

  @override
  Widget build(BuildContext context) {
    final isPaid = data.statut == _FactureStatut.payee;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Icon(Icons.attach_money_rounded,
                size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.famille} – ${data.enfant}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaid && data.datePaiement != null
                      ? '${data.mois} · Payée\nle ${data.datePaiement}'
                      : data.mois,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Amount
          Text(
            data.montant,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(
              isPaid ? 'Payée' : 'En attente',
              style: AppTextStyles.labelSmall.copyWith(
                color: isPaid ? AppColors.primary : AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Download
          Icon(Icons.download_outlined,
              size: 20, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}

// ─── Tab: Promesses d'embauche ────────────────────────────────────────────────

enum _PromesseStatut { signee, enAttente, expiree }

class _PromesseData {
  const _PromesseData({
    required this.famille,
    required this.enfant,
    required this.debutPrevu,
    required this.heures,
    required this.statut,
  });
  final String famille;
  final String enfant;
  final String debutPrevu;
  final String heures;
  final _PromesseStatut statut;
}

class _PromessesContent extends StatelessWidget {
  const _PromessesContent();

  static const _promesses = [
    _PromesseData(
      famille: 'Famille Bernard',
      enfant: 'Léa',
      debutPrevu: '01/09/2026',
      heures: '38h/sem',
      statut: _PromesseStatut.signee,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _NewPromesseSheet(),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Nouvelle promesse d\'embauche'),
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
        const SizedBox(height: AppSpacing.md),
        ..._promesses.map((p) => _PromesseTile(data: p)),
      ],
    );
  }
}

class _PromesseTile extends StatelessWidget {
  const _PromesseTile({required this.data});
  final _PromesseData data;

  @override
  Widget build(BuildContext context) {
    final (badgeLabel, badgeColor) = switch (data.statut) {
      _PromesseStatut.signee => ('Signée', AppColors.primary),
      _PromesseStatut.enAttente => ('En attente', AppColors.accent),
      _PromesseStatut.expiree => ('Expirée', AppColors.error),
    };

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
            child: const Icon(Icons.note_add_outlined,
                size: 22, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.famille} – ${data.enfant}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Début prévu : ${data.debutPrevu} · ${data.heures}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(
              badgeLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Contrats ────────────────────────────────────────────────────────────

class _ContratData {
  const _ContratData({
    required this.famille,
    required this.nomEnfant,
    required this.creeLe,
    required this.statut,
  });
  final String famille;
  final String nomEnfant;
  final String creeLe;
  final String statut;
}

class _ContratsContent extends StatelessWidget {
  const _ContratsContent();

  static const _contrats = [
    _ContratData(
      famille: 'Famille Dupont',
      nomEnfant: 'Lucas Dupont',
      creeLe: '01/09/2025',
      statut: 'Actif',
    ),
    _ContratData(
      famille: 'Famille Leroy',
      nomEnfant: 'Emma Leroy',
      creeLe: '15/10/2025',
      statut: 'Actif',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _contrats.length; i++) ...[
          _ContratTile(data: _contrats[i]),
          if (i < _contrats.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ContratTile extends StatelessWidget {
  const _ContratTile({required this.data});
  final _ContratData data;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Icons.task_outlined,
                    size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.famille} – ${data.nomEnfant}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Créé le ${data.creeLe}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  data.statut,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.download_outlined,
                  size: 20, color: AppColors.secondaryText),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Modal : Nouvelle facture ─────────────────────────────────────────────────

class _NewInvoiceSheet extends StatefulWidget {
  const _NewInvoiceSheet();

  @override
  State<_NewInvoiceSheet> createState() => _NewInvoiceSheetState();
}

class _NewInvoiceSheetState extends State<_NewInvoiceSheet> {
  String? _contrat;
  String? _mois;
  final _anneeCtrl = TextEditingController(text: '2026');
  final _heuresCtrl = TextEditingController(text: '160');
  final _repasCtrl = TextEditingController(text: '20');
  final _heuresComplCtrl = TextEditingController(text: '0');
  final _entretienCtrl = TextEditingController(text: '85');
  final _commentaireCtrl = TextEditingController();

  static const _contratOptions = [
    'Famille Dupont – Lucas Dupont',
    'Famille Leroy – Emma Leroy',
  ];
  static const _moisOptions = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  void dispose() {
    _anneeCtrl.dispose();
    _heuresCtrl.dispose();
    _repasCtrl.dispose();
    _heuresComplCtrl.dispose();
    _entretienCtrl.dispose();
    _commentaireCtrl.dispose();
    super.dispose();
  }

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
            // ── Header ──────────────────────────────────
            Row(
              children: [
                const Spacer(),
                Text(
                  'Nouvelle facture mensuelle',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
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

            // ── Famille / Enfant ─────────────────────────
            _SheetLabel('Famille / Enfant'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _contrat,
              isExpanded: true,
              decoration: _sheetInputDeco(),
              hint: Text('Sélectionner un contrat',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.hint)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.secondaryText),
              items: _contratOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _contrat = v),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Mois / Année ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Mois'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _mois,
                        isExpanded: true,
                        decoration: _sheetInputDeco(),
                        hint: Text('Mois',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.hint)),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.secondaryText),
                        items: _moisOptions
                            .map((m) =>
                                DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (v) => setState(() => _mois = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Année'),
                      const SizedBox(height: 6),
                      _SheetField(
                          controller: _anneeCtrl,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Heures / Repas ───────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Heures effectuées'),
                      const SizedBox(height: 6),
                      _SheetField(
                          controller: _heuresCtrl,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Nb repas'),
                      const SizedBox(height: 6),
                      _SheetField(
                          controller: _repasCtrl,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Heures compl. / Entretien ────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Heures\ncomplémentaires'),
                      const SizedBox(height: 6),
                      _SheetField(
                          controller: _heuresComplCtrl,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Indemnité entretien (€)'),
                      const SizedBox(height: 6),
                      _SheetField(
                          controller: _entretienCtrl,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Commentaire ──────────────────────────────
            _SheetLabel('Commentaire'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _commentaireCtrl,
              maxLines: 4,
              decoration: _sheetInputDeco().copyWith(
                hintText: 'Notes éventuelles…',
                hintStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.hint),
              ),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Bouton ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.receipt_long_outlined, size: 20),
                label: const Text('Générer la facture'),
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

InputDecoration _sheetInputDeco() => InputDecoration(
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

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      );
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.controller, this.keyboardType, this.hint});
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _sheetInputDeco().copyWith(
          hintText: hint,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
        ),
        style: AppTextStyles.bodyMedium,
      );
}

// ─── Modal : Nouvelle promesse d'embauche ─────────────────────────────────────

class _NewPromesseSheet extends StatefulWidget {
  const _NewPromesseSheet();

  @override
  State<_NewPromesseSheet> createState() => _NewPromesseSheetState();
}

class _NewPromesseSheetState extends State<_NewPromesseSheet> {
  final _familleCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _naissanceCtrl = TextEditingController();
  final _debutCtrl = TextEditingController();
  final _heuresCtrl = TextEditingController(text: '40');
  final _joursCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();

  @override
  void dispose() {
    _familleCtrl.dispose();
    _prenomCtrl.dispose();
    _naissanceCtrl.dispose();
    _debutCtrl.dispose();
    _heuresCtrl.dispose();
    _joursCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {});
    }
  }

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
            // ── Header ──────────────────────────────────
            Row(
              children: [
                const Spacer(),
                Text(
                  'Promesse d\'embauche',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
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

            // ── Nom famille / Prénom enfant ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Nom de la famille'),
                      const SizedBox(height: 6),
                      _SheetField(
                        controller: _familleCtrl,
                        hint: 'Famille…',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Prénom de l\'enfant'),
                      const SizedBox(height: 6),
                      _SheetField(
                        controller: _prenomCtrl,
                        hint: 'Prénom',
                      ),
                    ],
                  ),
                ),
              ],
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
                      _SheetLabel('Date de naissance\nenfant'),
                      const SizedBox(height: 6),
                      _SheetDateField(
                        controller: _naissanceCtrl,
                        onTap: () => _pickDate(_naissanceCtrl),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Date de début prévue'),
                      const SizedBox(height: 6),
                      _SheetDateField(
                        controller: _debutCtrl,
                        onTap: () => _pickDate(_debutCtrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Heures / Jours ───────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Heures / semaine\nprévues'),
                      const SizedBox(height: 6),
                      _SheetField(
                        controller: _heuresCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Jours d\'accueil prévus'),
                      const SizedBox(height: 6),
                      _SheetField(
                        controller: _joursCtrl,
                        hint: 'Lundi – Vendredi',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Conditions particulières ─────────────────
            _SheetLabel('Conditions particulières'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _conditionsCtrl,
              maxLines: 4,
              decoration: _sheetInputDeco().copyWith(
                hintText: 'Conditions spécifiques…',
                hintStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.hint),
              ),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Bouton ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.description_outlined, size: 20),
                label: const Text('Générer la promesse'),
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

class _SheetDateField extends StatelessWidget {
  const _SheetDateField({required this.controller, required this.onTap});
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: _sheetInputDeco().copyWith(
          hintText: 'jj/mm/aaaa',
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
          suffixIcon: const Icon(Icons.calendar_today_outlined,
              size: 18, color: AppColors.secondaryText),
        ),
        style: AppTextStyles.bodyMedium,
      );
}
