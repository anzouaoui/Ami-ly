import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatLegalConsultationPage extends StatefulWidget {
  const AssMatLegalConsultationPage({super.key});

  @override
  State<AssMatLegalConsultationPage> createState() =>
      _AssMatLegalConsultationPageState();
}

class _AssMatLegalConsultationPageState
    extends State<AssMatLegalConsultationPage> {
  int _step = 0; // 0-based

  // Step 1 fields
  final _firstNameCtrl = TextEditingController(text: 'Marie');
  final _lastNameCtrl = TextEditingController(text: 'Dupont');
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();

  // Step 1 — motif
  String? _selectedMotif;
  static const _motifs = [
    'Litige avec un parent',
    'Rupture de contrat',
    'Impayés / contentieux',
    'Rédaction de contrat',
    'Question sur Pajemploi',
    'Droit du travail',
    'Autre',
  ];

  // Step 1 — urgency + consent
  String _urgency = 'standard';
  bool _consent = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step++);
  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Page header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: const Icon(Icons.balance_outlined,
                        size: 26, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consultation\njuridique',
                            style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w800, fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          '30 min au téléphone avec un avocat du barreau de Paris.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Retour'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondaryText,
                      textStyle: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Step indicator ────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _StepIndicator(current: _step, total: 3),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Step content ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                child: [
                  _StepOne(
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                    emailCtrl: _emailCtrl,
                    phoneCtrl: _phoneCtrl,
                    subjectCtrl: _subjectCtrl,
                    motifs: _motifs,
                    selectedMotif: _selectedMotif,
                    onMotifChanged: (v) => setState(() => _selectedMotif = v),
                    urgency: _urgency,
                    onUrgencyChanged: (v) => setState(() => _urgency = v),
                    consent: _consent,
                    onConsentChanged: (v) => setState(() => _consent = v),
                    onNext: _consent ? _next : null,
                  ),
                  _StepTwo(
                    firstName: _firstNameCtrl.text,
                    lastName: _lastNameCtrl.text,
                    phone: _phoneCtrl.text,
                    email: _emailCtrl.text,
                    motif: _selectedMotif ?? '',
                    description: _subjectCtrl.text,
                    urgency: _urgency,
                    onBack: _back,
                    onNext: _next,
                  ),
                  _StepThree(
                    phone: _phoneCtrl.text,
                    urgency: _urgency,
                    onConfirm: () => Navigator.of(context).pop(),
                  ),
                ][_step],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final done = i ~/ 2 < current;
          return Expanded(
            child: Container(
              height: 1.5,
              color: done ? AppColors.primary : AppColors.divider,
            ),
          );
        }
        final step = i ~/ 2;
        final isActive = step == current;
        final isDone = step < current;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border.all(
              color: isDone || isActive
                  ? AppColors.primary
                  : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDone || isActive
                    ? AppColors.primary
                    : AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Step 1: Votre demande ────────────────────────────────────────────────────

class _StepOne extends StatefulWidget {
  const _StepOne({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.subjectCtrl,
    required this.motifs,
    required this.selectedMotif,
    required this.onMotifChanged,
    required this.urgency,
    required this.onUrgencyChanged,
    required this.consent,
    required this.onConsentChanged,
    required this.onNext,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController subjectCtrl;
  final List<String> motifs;
  final String? selectedMotif;
  final ValueChanged<String?> onMotifChanged;
  final String urgency;
  final ValueChanged<String> onUrgencyChanged;
  final bool consent;
  final ValueChanged<bool> onConsentChanged;
  final VoidCallback? onNext;

  @override
  State<_StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<_StepOne> {
  static const _maxChars = 500;

  @override
  void initState() {
    super.initState();
    widget.subjectCtrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.subjectCtrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final charCount = widget.subjectCtrl.text.length;

    return _FormCard(
      title: 'Votre demande',
      subtitle:
          'Toutes les informations sont confidentielles et transmises uniquement à l\'avocat partenaire.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Coordonnées'),
          const SizedBox(height: AppSpacing.sm),
          _FormField(
              label: 'Prénom',
              controller: widget.firstNameCtrl,
              hint: 'Marie',
              action: TextInputAction.next),
          const SizedBox(height: AppSpacing.sm),
          _FormField(
              label: 'Nom',
              controller: widget.lastNameCtrl,
              hint: 'Dupont',
              action: TextInputAction.next),
          const SizedBox(height: AppSpacing.sm),
          _FormField(
              label: 'Téléphone (pour le rappel)',
              controller: widget.phoneCtrl,
              hint: '06 12 34 56 78',
              type: TextInputType.phone,
              action: TextInputAction.next),
          const SizedBox(height: AppSpacing.sm),
          _FormField(
              label: 'Email',
              controller: widget.emailCtrl,
              hint: 'marie@email.com',
              type: TextInputType.emailAddress,
              action: TextInputAction.next),
          const SizedBox(height: AppSpacing.md),

          // Nature de la demande dropdown
          _SectionLabel('Nature de la demande'),
          const SizedBox(height: AppSpacing.sm),
          _MotifDropdown(
            motifs: widget.motifs,
            selected: widget.selectedMotif,
            onChanged: widget.onMotifChanged,
          ),
          const SizedBox(height: AppSpacing.md),

          // Description with char counter
          _SectionLabel('Description de la situation'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: widget.subjectCtrl,
            maxLines: 5,
            maxLength: _maxChars,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodySmall,
            decoration: InputDecoration(
              hintText:
                  'Décrivez brièvement votre situation pour permettre à l\'avocat de préparer l\'appel...',
              hintStyle:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.hint),
              hintMaxLines: 3,
              filled: true,
              fillColor: AppColors.background,
              counterText: '$charCount/$_maxChars',
              counterStyle: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText, fontSize: 11),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Niveau d'urgence
          _SectionLabel('Niveau d\'urgence'),
          const SizedBox(height: AppSpacing.sm),
          _UrgencyTile(
            value: 'standard',
            label: 'Standard',
            price: '59 €',
            delay: 'Rappel sous 48–72h',
            selected: widget.urgency == 'standard',
            onTap: () => widget.onUrgencyChanged('standard'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _UrgencyTile(
            value: 'urgent',
            label: 'Urgent',
            price: '79 €',
            delay: 'Rappel sous 24h',
            selected: widget.urgency == 'urgent',
            onTap: () => widget.onUrgencyChanged('urgent'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Pièces jointes
          _SectionLabel('Pièces jointes (optionnel)'),
          const SizedBox(height: 4),
          Text(
            'Contrat, courrier, etc. — 3 fichiers max, 5 Mo chacun.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomPaint(
            painter: _DashedBorderPainter(
                color: AppColors.divider, radius: AppRadii.sm),
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ajout de fichier — à venir'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_outlined,
                        size: 18, color: AppColors.secondaryText),
                    const SizedBox(width: 8),
                    Text('Ajouter un fichier',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Consentement
          InkWell(
            onTap: () => widget.onConsentChanged(!widget.consent),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.consent
                          ? AppColors.primary
                          : AppColors.divider,
                      width: widget.consent ? 2 : 1.5,
                    ),
                    color: widget.consent
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                  child: widget.consent
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'J\'accepte que mes informations soient transmises à l\'avocat partenaire pour traiter ma demande.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          _NextButton(
            label: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            onTap: widget.onNext,
          ),
        ],
      ),
    );
  }
}

// ─── Urgency tile ─────────────────────────────────────────────────────────────

class _UrgencyTile extends StatelessWidget {
  const _UrgencyTile({
    required this.value,
    required this.label,
    required this.price,
    required this.delay,
    required this.selected,
    required this.onTap,
  });
  final String value;
  final String label;
  final String price;
  final String delay;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                  width: selected ? 2 : 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primaryText
                              : AppColors.primaryText)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined,
                          size: 13, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      Text(delay,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondaryText, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Text(price,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
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

// ─── Motif dropdown ───────────────────────────────────────────────────────────

class _MotifDropdown extends StatelessWidget {
  const _MotifDropdown({
    required this.motifs,
    required this.selected,
    required this.onChanged,
  });
  final List<String> motifs;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text('Sélectionnez un motif',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.hint)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: AppColors.secondaryText),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.primaryText),
          items: motifs
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Step 2: Récapitulatif ────────────────────────────────────────────────────

class _StepTwo extends StatelessWidget {
  const _StepTwo({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.motif,
    required this.description,
    required this.urgency,
    required this.onBack,
    required this.onNext,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String motif;
  final String description;
  final String urgency;
  final VoidCallback onBack;
  final VoidCallback onNext;

  bool get _isUrgent => urgency == 'urgent';

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      title: 'Récapitulatif',
      subtitle: 'Vérifiez vos informations avant de confirmer.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecapField(label: 'NOM', value: '$firstName $lastName'),
          const SizedBox(height: AppSpacing.md),
          _RecapField(label: 'TÉLÉPHONE', value: phone.isEmpty ? '—' : phone),
          const SizedBox(height: AppSpacing.md),
          _RecapField(label: 'EMAIL', value: email.isEmpty ? '—' : email),
          const SizedBox(height: AppSpacing.md),
          _RecapField(
              label: 'TYPE DE DEMANDE',
              value: motif.isEmpty ? '—' : motif),
          if (description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DESCRIPTION',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primaryText, height: 1.4)),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Urgency summary card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isUrgent ? 'Rappel urgent' : 'Rappel standard',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _isUrgent ? 'Rappel sous 24h' : 'Rappel sous 48–72h',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _isUrgent ? '79 €' : '59 €',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    ),
                    Text('30 min d\'appel',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Security note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Paiement sécurisé. Vos données restent confidentielles et ne sont partagées qu\'avec l\'avocat partenaire.',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Double button row
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Modifier'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  minimumSize: Size.zero,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    textStyle: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  child: Text(
                      'Confirmer et payer ${_isUrgent ? '79' : '59'} €'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _RecapField extends StatelessWidget {
  const _RecapField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Step 3: Confirmation ─────────────────────────────────────────────────────

class _StepThree extends StatelessWidget {
  const _StepThree({
    required this.phone,
    required this.urgency,
    required this.onConfirm,
  });
  final String phone;
  final String urgency;
  final VoidCallback onConfirm;

  bool get _isUrgent => urgency == 'urgent';

  @override
  Widget build(BuildContext context) {
    final delay = _isUrgent ? '24h' : '48–72h';
    final displayPhone = phone.isEmpty ? 'votre numéro' : phone;
    // Stable mock reference for demo
    final ref = 'demo-${phone.isEmpty ? '000' : (phone.hashCode.abs() % 900 + 100)}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),

          // Checkmark
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            'Demande envoyée !',
            style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Body with bold phone
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText, height: 1.5),
              children: [
                const TextSpan(
                    text:
                        'Un avocat partenaire du barreau de Paris vous rappellera au '),
                TextSpan(
                  text: displayPhone,
                  style: const TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700),
                ),
                TextSpan(
                    text:
                        ' rappel sous $delay. Vous recevrez aussi un email de confirmation.'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E0),
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(color: const Color(0xFFF4C4B0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 14, color: Color(0xFFB85C38)),
                const SizedBox(width: 6),
                Text('En attente de rappel',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFFB85C38),
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Reference
          Text('Référence : $ref',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText, fontSize: 12)),
          const SizedBox(height: AppSpacing.lg),

          // Back button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onConfirm,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                minimumSize: Size.zero,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                textStyle: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              child: const Text('Retour au tableau de bord'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ─── Shared form widgets ──────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard(
      {required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

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
          Text(title,
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText, height: 1.4)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: AppTextStyles.bodySmall
            .copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryText));
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.type,
    this.action,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? type;
  final TextInputAction? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: type,
          textInputAction: action,
          maxLines: 1,
          style: AppTextStyles.bodySmall,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.bodySmall.copyWith(color: AppColors.hint),
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      disabledBackgroundColor: AppColors.divider,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      textStyle:
          AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
    );
    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          )
        : Text(label) as Widget;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
    );
  }
}
