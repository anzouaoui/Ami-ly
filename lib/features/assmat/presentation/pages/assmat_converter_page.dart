import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatConverterPage extends StatefulWidget {
  const AssMatConverterPage({super.key});

  @override
  State<AssMatConverterPage> createState() => _AssMatConverterPageState();
}

class _AssMatConverterPageState extends State<AssMatConverterPage> {
  // HM → HC
  final _hmHoursCtrl = TextEditingController(text: '1');
  int _hmMinutes = 30;

  // HC → HM
  final _hcCtrl = TextEditingController(text: '1,33');

  static const _minuteOptions = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  @override
  void dispose() {
    _hmHoursCtrl.dispose();
    _hcCtrl.dispose();
    super.dispose();
  }

  // HM → HC: hours + minutes/60
  String get _hmResult {
    final h = int.tryParse(_hmHoursCtrl.text) ?? 0;
    final result = h + _hmMinutes / 60;
    return result.toStringAsFixed(2).replaceAll('.', ',');
  }

  // HC → HM: floor + round(frac*60)
  ({int hours, int minutes}) get _hcResult {
    final raw = _hcCtrl.text.replaceAll(',', '.');
    final val = double.tryParse(raw) ?? 0;
    final h = val.floor();
    final m = ((val - h) * 60).round();
    return (hours: h, minutes: m);
  }

  @override
  Widget build(BuildContext context) {
    final hc = _hcResult;

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
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
        children: [
          // ── Header ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Icons.schedule_outlined,
                    size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CALCULETTES',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 1.2)),
                  Text('Convertisseur d\'heures',
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Card 1: HM → HC ─────────────────────────
          _ConverterCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DirectionHeader(
                  from: 'HEURES-\nMINUTES',
                  to: 'HEURES-\nCENTIÈMES',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _HoursField(
                      controller: _hmHoursCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(width: 8),
                    Text('Heures',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondaryText)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MinutesDropdown(
                        value: _hmMinutes,
                        options: _minuteOptions,
                        onChanged: (v) => setState(() => _hmMinutes = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('= ',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondaryText)),
                    Text(_hmResult,
                        style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 36)),
                    const SizedBox(width: 6),
                    Text('HEURES',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Card 2: HC → HM ─────────────────────────
          _ConverterCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DirectionHeader(
                  from: 'HEURES-\nCENTIÈMES',
                  to: 'HEURES-\nMINUTES',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _HoursField(
                      controller: _hcCtrl,
                      decimal: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(width: 8),
                    Text('heures  =',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondaryText)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${hc.hours}',
                        style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 36)),
                    const SizedBox(width: 4),
                    Text('HEURES',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                    const SizedBox(width: 12),
                    Text('${hc.minutes}',
                        style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 36)),
                    const SizedBox(width: 4),
                    Text('MINUTES',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
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

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _ConverterCard extends StatelessWidget {
  const _ConverterCard({required this.child});
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
      child: child,
    );
  }
}

class _DirectionHeader extends StatelessWidget {
  const _DirectionHeader({required this.from, required this.to});
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodySmall.copyWith(
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 0.8,
        height: 1.3);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(from, style: style),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded,
              size: 14, color: AppColors.secondaryText),
        ),
        Text(to, style: style),
      ],
    );
  }
}

class _HoursField extends StatelessWidget {
  const _HoursField({
    required this.controller,
    required this.onChanged,
    this.decimal = false,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          if (!decimal) FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.background,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    );
  }
}

class _MinutesDropdown extends StatelessWidget {
  const _MinutesDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final int value;
  final List<int> options;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          items: options
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('$m minutes',
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w500)),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: AppColors.secondaryText),
          style: AppTextStyles.bodySmall,
          dropdownColor: AppColors.surface,
        ),
      ),
    );
  }
}
