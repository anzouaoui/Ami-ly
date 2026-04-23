import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_time_sheet_page.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _MockPhoto {
  const _MockPhoto(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kChildren = ['Lucas', 'Emma', 'Léa', 'Hugo'];

const _kWeekdays = [
  'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
];
const _kMonths = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatDayJourneyPage extends StatefulWidget {
  const AssMatDayJourneyPage({super.key});

  @override
  State<AssMatDayJourneyPage> createState() => _AssMatDayJourneyPageState();
}

class _AssMatDayJourneyPageState extends State<AssMatDayJourneyPage> {
  DateTime _date = DateTime(2026, 4, 23);
  int _childIndex = 0;

  void _prevDay() => setState(() => _date = _date.subtract(const Duration(days: 1)));
  void _nextDay() => setState(() => _date = _date.add(const Duration(days: 1)));

  String get _dateLabel =>
      '${_kWeekdays[_date.weekday - 1]} ${_date.day} ${_kMonths[_date.month - 1]} ${_date.year}';

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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Brouillon sauvegardé'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
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
                  child: const Text('Sauvegarder brouillon'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Journal envoyé aux parents'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Envoyer aux parents'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            Text('Journal quotidien',
                style: AppTextStyles.titleLarge
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 26)),
            const SizedBox(height: 4),
            Text('Suivi journalier de chaque enfant',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: AppSpacing.md),

            // ── Date navigator ───────────────────────────
            Row(
              children: [
                _NavBtn(icon: Icons.chevron_left_rounded, onTap: _prevDay),
                Expanded(
                  child: Center(
                    child: Text(_dateLabel,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
                _NavBtn(icon: Icons.chevron_right_rounded, onTap: _nextDay),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Child selector ───────────────────────────
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kChildren.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final selected = i == _childIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _childIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 88,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.divider,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: selected
                                ? AppColors.primary
                                : AppColors.divider.withValues(alpha: 0.5),
                            child: Text(
                              _kChildren[i][0],
                              style: AppTextStyles.titleMedium.copyWith(
                                color: selected
                                    ? AppColors.onPrimary
                                    : AppColors.secondaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _kChildren[i],
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: selected
                                  ? AppColors.primaryText
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Content for selected child ───────────────
            _DayJourneyContent(
              childName: _kChildren[_childIndex],
              date: _date,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Day journal content ──────────────────────────────────────────────────────

class _DayJourneyContent extends StatefulWidget {
  const _DayJourneyContent({required this.childName, required this.date});
  final String childName;
  final DateTime date;

  @override
  State<_DayJourneyContent> createState() => _DayJourneyContentState();
}

class _DayJourneyContentState extends State<_DayJourneyContent> {
  final _arriveeCtrl = TextEditingController();
  final _departCtrl = TextEditingController();

  // Repas
  final Set<String> _repas = {};
  static const _repasList = [
    'Petit-déjeuner', 'Collation matin', 'Déjeuner', 'Goûter',
  ];

  // Sieste
  final _siesteDebutCtrl = TextEditingController(text: '12:30');
  final _siesteFinCtrl = TextEditingController(text: '14:30');

  // Activités
  final Set<String> _activites = {};
  static const _activitesList = [
    'Peinture', 'Lecture', 'Jeux extérieurs', 'Musique',
    'Motricité', 'Pâte à modeler', 'Puzzle', 'Dessin',
  ];

  // Fournitures
  final Map<String, double> _fournitures = {
    'Couches': 1.0,
    'Lingettes': 1.0,
    'Lait en poudre': 1.0,
    'Liniment': 1.0,
  };
  static const _fournituresIcons = {
    'Couches': '🩹',
    'Lingettes': '🧻',
    'Lait en poudre': '🍼',
    'Liniment': '🧴',
  };

  // Photos
  final List<_MockPhoto> _photos = [
    _MockPhoto('Jeux calmes d\'int.', const Color(0xFF8BA5C8), Icons.sports_esports_outlined),
    _MockPhoto('Bonhomme de nei.', const Color(0xFF3B4A6B), Icons.ac_unit_rounded),
    _MockPhoto('Jardinage en pot', const Color(0xFF6BAB6E), Icons.eco_outlined),
  ];

  // Feuille de présence – commentaire
  final _presenceCommentCtrl = TextEditingController();

  // Présence notes rapides
  final _quickArriveeCtrl = TextEditingController(text: '08:00');
  final _quickDepartCtrl = TextEditingController();

  // Notes
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _arriveeCtrl.dispose();
    _departCtrl.dispose();
    _presenceCommentCtrl.dispose();
    _quickArriveeCtrl.dispose();
    _quickDepartCtrl.dispose();
    _siesteDebutCtrl.dispose();
    _siesteFinCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '') ?? 8,
      minute: int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        ctrl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  InputDecoration _deco({String? hint, Widget? suffix}) => InputDecoration(
        hintText: hint ?? '--:--',
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Feuille de présence ──────────────────────
        _Section(
          icon: Icons.schedule_outlined,
          title: 'Feuille de présence',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time pickers
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Heure d\'arrivée'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _arriveeCtrl,
                          readOnly: true,
                          onTap: () => _pickTime(_arriveeCtrl),
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
                        _FieldLabel('Heure de départ'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _departCtrl,
                          readOnly: true,
                          onTap: () => _pickTime(_departCtrl),
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
              const SizedBox(height: AppSpacing.sm),

              // Commentaire
              _FieldLabel('Commentaire (optionnel)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _presenceCommentCtrl,
                maxLines: 3,
                decoration: _deco(
                    hint: 'Retard, sortie anticipée, événement particulier...'),
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Présence enregistrée'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Enregistrer la présence'),
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
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AssMatTimeSheetPage(),
                    ),
                  ),
                  icon: const Icon(Icons.list_alt_outlined, size: 18),
                  label: const Text('Voir les feuilles hebdo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryText,
                    side: const BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    textStyle: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Info note
              Text(
                'Les heures saisies alimentent automatiquement la feuille de présence hebdomadaire envoyée au parent pour signature.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Présence (notes rapides) ─────────────────
        _Section(
          icon: Icons.schedule_outlined,
          title: 'Présence (notes rapides)',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Arrivée'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _quickArriveeCtrl,
                      readOnly: true,
                      onTap: () => _pickTime(_quickArriveeCtrl),
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
                    _FieldLabel('Départ'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _quickDepartCtrl,
                      readOnly: true,
                      onTap: () => _pickTime(_quickDepartCtrl),
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
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Repas ────────────────────────────────────
        _Section(
          icon: Icons.restaurant_menu_rounded,
          title: 'Repas',
          iconColor: const Color(0xFFB07040),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _repasList.map((meal) {
              final selected = _repas.contains(meal);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) _repas.remove(meal); else _repas.add(meal);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : AppColors.divider,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 13, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          meal,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primaryText
                                : AppColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Sieste ───────────────────────────────────
        _Section(
          icon: Icons.bedtime_outlined,
          iconColor: const Color(0xFF4A90D9),
          title: 'Sieste',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Début'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _siesteDebutCtrl,
                      readOnly: true,
                      onTap: () => _pickTime(_siesteDebutCtrl),
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
                    _FieldLabel('Fin'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _siesteFinCtrl,
                      readOnly: true,
                      onTap: () => _pickTime(_siesteFinCtrl),
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
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Activités ────────────────────────────────
        _Section(
          icon: Icons.palette_outlined,
          iconColor: const Color(0xFFE07830),
          title: 'Activités',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _activitesList.map((act) {
              final selected = _activites.contains(act);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) _activites.remove(act); else _activites.add(act);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    selected ? '✓ $act' : act,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selected ? Colors.white : AppColors.primaryText,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),


        // ── Notes ────────────────────────────────────
        _Section(
          icon: Icons.sticky_note_2_outlined,
          iconColor: const Color(0xFFE09820),
          title: 'Notes',
          child: TextFormField(
            controller: _notesCtrl,
            maxLines: 4,
            decoration: _deco(
                hint: 'Observations, humeur, événements particuliers...'),
            style: AppTextStyles.bodySmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Photos ───────────────────────────────────
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
              Row(
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      size: 18, color: Color(0xFF3A9A6E)),
                  const SizedBox(width: 8),
                  Text('Photos',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${_photos.length} photo(s)',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondaryText)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Thumbnails row
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final p = _photos[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          child: Container(
                            width: 110,
                            height: 110,
                            color: p.color,
                            child: Icon(p.icon,
                                size: 36, color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 110,
                          child: Text(
                            '${p.label}...',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryText, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Upload zone
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ajout de photos — à venir'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: AppColors.divider,
                    radius: AppRadii.sm,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 28, color: AppColors.secondaryText),
                        const SizedBox(height: 6),
                        Text('Ajouter des photos',
                            style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText)),
                        const SizedBox(height: 2),
                        Text('Glissez ou cliquez pour télécharger',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Fournitures ──────────────────────────────
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
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 18, color: Color(0xFF3A9A6E)),
                  const SizedBox(width: 8),
                  Text('Fournitures',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._fournitures.entries.map((e) {
                final pct = (e.value * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            _fournituresIcons[e.key] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(e.key,
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.full),
                            ),
                            child: Text('$pct%',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11)),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          thumbColor: AppColors.surface,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10),
                          overlayShape: SliderComponentShape.noOverlay,
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: e.value,
                          onChanged: (v) =>
                              setState(() => _fournitures[e.key] = v),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Niveaux sauvegardés'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryText,
                    side: const BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    textStyle: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  child: const Text('Sauvegarder les niveaux'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Save button ──────────────────────────────
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Journal enregistré'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text('Enregistrer le journal'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              textStyle:
                  AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 22),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });
  final IconData icon;
  final String title;
  final Widget child;
  final Color? iconColor;

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
            children: [
              Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.warningWhenOn = false,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool warningWhenOn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: warningWhenOn && value
                  ? AppColors.error
                  : AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: warningWhenOn ? AppColors.error : AppColors.primary,
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
    final rr = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rr);
    final metric = path.computeMetrics().first;
    double dist = 0;
    while (dist < metric.length) {
      canvas.drawPath(
        metric.extractPath(dist, dist + dashW),
        paint,
      );
      dist += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
