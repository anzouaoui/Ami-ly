import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/child_model.dart';
import 'interest_tag_chip.dart';
import 'profile_form_field.dart';
import '../pages/child_diary_page.dart';

/// Carte éditable d'un enfant dans le profil parent.
///
/// Gère son propre état local (controllers + date de naissance + intérêts).
/// Appelle [onChanged] à chaque modification pour que la page parente
/// maintienne une copie à jour de [ChildModel] (utilisée lors de la
/// sauvegarde globale du profil).
class ChildProfileCard extends StatefulWidget {
  const ChildProfileCard({
    super.key,
    required this.child,
    required this.onChanged,
    required this.onDelete,
  });

  final ChildModel child;
  final ValueChanged<ChildModel> onChanged;
  final VoidCallback onDelete;

  @override
  State<ChildProfileCard> createState() => _ChildProfileCardState();
}

class _ChildProfileCardState extends State<ChildProfileCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late DateTime? _birthDate;
  late List<String> _interests;

  static final _dateFmt = DateFormat('dd/MM/yyyy', 'fr_FR');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.child.firstName);
    _descCtrl = TextEditingController(text: widget.child.description);
    _birthDate = widget.child.birthDate;
    _interests = List.of(widget.child.interests);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  ChildModel _toModel() => widget.child.copyWith(
        firstName: _nameCtrl.text.trim(),
        birthDate: _birthDate,
        description: _descCtrl.text.trim(),
        interests: List.of(_interests),
      );

  void _notify() => widget.onChanged(_toModel());

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 18),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      helpText: 'Date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      _notify();
    }
  }

  Future<void> _addInterest() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Centre d'intérêt"),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration:
                const InputDecoration(hintText: 'Ex : Peinture, Parc…'),
            onChanged: (_) => setDialogState(() {}),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) Navigator.of(ctx).pop(v.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: ctrl.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
    // ⚠️ Pas de ctrl.dispose() ici — même raison que dans _addChildDialog :
    // animation de fermeture encore active → '_dependents.isEmpty' crash.
    if (result != null && result.isNotEmpty && !_interests.contains(result)) {
      setState(() => _interests.add(result));
      _notify();
    }
  }

  void _removeInterest(String tag) {
    setState(() => _interests.remove(tag));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final ageLabel = _toModel().ageLabel;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.child_care_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Nouvel enfant',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.secondaryText, size: 22),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Retirer',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Informations et centres d\'intérêt',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Champs texte ─────────────────────────────────────────────────
          ProfileFormField(
            label: 'Prénom de l\'enfant',
            controller: _nameCtrl,
            onChanged: (_) {
              setState(() {}); // refresh header
              _notify();
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Date de naissance — champ tappable ouvrant le date picker
          _DateField(
            label: 'Date de naissance',
            value: _birthDate != null ? _dateFmt.format(_birthDate!) : '',
            ageLabel: ageLabel,
            onTap: _pickDate,
          ),
          const SizedBox(height: AppSpacing.md),

          ProfileFormField(
            label: 'Description',
            controller: _descCtrl,
            maxLines: 3,
            onChanged: (_) => _notify(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Centres d'intérêt ────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('Ce qu\'il/elle aime', style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in _interests)
                InterestTagChip(
                  label: tag,
                  onRemove: () => _removeInterest(tag),
                ),
              _AddInterestButton(onTap: _addInterest),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChildDiaryPage(
                    childName: _nameCtrl.text.trim().isNotEmpty
                        ? _nameCtrl.text.trim()
                        : widget.child.firstName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: Text(
              'Journal de ${_nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : widget.child.firstName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date field ───────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.ageLabel,
    required this.onTap,
  });

  final String label;
  final String value;
  final String ageLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.primaryText)),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InputDecorator(
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.secondaryText),
              suffixText: ageLabel.isNotEmpty ? ageLabel : null,
              suffixStyle: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText),
            ),
            child: Text(
              value.isNotEmpty ? value : 'jj/mm/aaaa',
              style: value.isNotEmpty
                  ? AppTextStyles.bodyMedium
                  : AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Add interest button ──────────────────────────────────────────────────────

class _AddInterestButton extends StatelessWidget {
  const _AddInterestButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded,
                size: 16, color: AppColors.secondaryText),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Ajouter',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
