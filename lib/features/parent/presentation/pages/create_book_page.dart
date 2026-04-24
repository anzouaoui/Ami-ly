import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Theme data ───────────────────────────────────────────────────────────────

class _BookTheme {
  const _BookTheme({
    required this.name,
    required this.emoji,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
  });
  final String name;
  final String emoji;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;
}

final _kThemes = [
  const _BookTheme(
    name: 'AMiLY Classique',
    emoji: '🌿',
    description: 'Le thème signature AMiLY, vert sauge et crème',
    gradientStart: Color(0xFF4F7E6A),
    gradientEnd: Color(0xFFD4E8D8),
  ),
  const _BookTheme(
    name: 'Tendresse',
    emoji: '💕',
    description: 'Des tons pastel roses et crème très doux',
    gradientStart: Color(0xFFCF8080),
    gradientEnd: Color(0xFFF5E0D8),
  ),
  const _BookTheme(
    name: 'Océan',
    emoji: '🌊',
    description: 'Bleu apaisant pour les petits aventuriers',
    gradientStart: Color(0xFF4A8ED9),
    gradientEnd: Color(0xFFB8D9F5),
  ),
  const _BookTheme(
    name: 'Soleil',
    emoji: '☀️',
    description: 'Jaune chaud et festif, plein de joie',
    gradientStart: Color(0xFFF0B429),
    gradientEnd: Color(0xFFFFF3B0),
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class CreateBookPage extends StatefulWidget {
  const CreateBookPage({super.key});

  @override
  State<CreateBookPage> createState() => _CreateBookPageState();
}

class _CreateBookPageState extends State<CreateBookPage> {
  int _toolIndex = 0;

  final _childNameCtrl = TextEditingController();
  final _dedicaceCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _coverMsgCtrl = TextEditingController();
  final _endPageCtrl = TextEditingController();

  String _selectedTheme = 'AMiLY Classique';
  String _selectedFormat = 'pdf';
  String? _selectedLayout;
  final _emailCtrl = TextEditingController();
  bool _confirmed = false;

  static const _layouts = ['Classique', 'Moderne', 'Minimaliste', 'Coloré'];
  static const _stepCount = 6;

  static const _tools = [
    (Icons.auto_awesome_rounded, 'IA'),
    (Icons.image_outlined, 'Photos'),
    (Icons.grid_view_rounded, 'Mise en page'),
    (Icons.title_rounded, 'Texte'),
    (Icons.visibility_outlined, 'Aperçu'),
    (Icons.shopping_cart_outlined, 'Commander'),
  ];

  @override
  void dispose() {
    _childNameCtrl.dispose();
    _dedicaceCtrl.dispose();
    _titleCtrl.dispose();
    _coverMsgCtrl.dispose();
    _endPageCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  _BookTheme get _currentTheme =>
      _kThemes.firstWhere((t) => t.name == _selectedTheme,
          orElse: () => _kThemes.first);

  void _goNext() {
    if (_toolIndex < _stepCount - 1) {
      setState(() => _toolIndex++);
    } else {
      _confirmOrder();
    }
  }

  void _goPrev() {
    if (_toolIndex > 0) setState(() => _toolIndex--);
  }

  void _confirmOrder() {
    final email = _emailCtrl.text.trim().isNotEmpty
        ? _emailCtrl.text.trim()
        : 'votre@email.com';
    setState(() => _confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '🎉 Commande confirmée ! Votre livre sera envoyé à $email après validation du paiement.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _toolIndex == _stepCount - 1;
    String nextLabel;
    if (isLast) {
      nextLabel = 'Confirmer la commande';
    } else if (_toolIndex == 4) {
      nextLabel = 'Commander';
    } else {
      nextLabel = 'Suivant';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.md, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                    label: const Text('Retour'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondaryText,
                      textStyle: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.menu_book_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Livre de l\'année 2025–2026',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Toolbar ──────────────────────────────────
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tools.length, (i) {
                  final (icon, label) = _tools[i];
                  final active = _toolIndex == i;
                  return _ToolButton(
                    icon: icon,
                    label: label,
                    active: active,
                    onTap: () => setState(() => _toolIndex = i),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Panel ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                child: _confirmed
                    ? _PanelConfirmed(
                        email: _emailCtrl.text.trim().isNotEmpty
                            ? _emailCtrl.text.trim()
                            : 'votre@email.com',
                        format: _selectedFormat,
                        theme: _currentTheme,
                        onBack: () => Navigator.of(context).pop(),
                      )
                    : [
                  _PanelAI(
                    childNameCtrl: _childNameCtrl,
                    dedicaceCtrl: _dedicaceCtrl,
                    selectedTheme: _selectedTheme,
                    onSelectTheme: (v) =>
                        setState(() => _selectedTheme = v),
                  ),
                  _PanelPhotos(),
                  _PanelLayout(
                    layouts: _layouts,
                    selected: _selectedLayout,
                    onSelect: (v) => setState(() => _selectedLayout = v),
                  ),
                  _PanelText(
                    titleCtrl: _titleCtrl,
                    coverMsgCtrl: _coverMsgCtrl,
                    endPageCtrl: _endPageCtrl,
                  ),
                  _PanelPreview(
                    theme: _currentTheme,
                    childName: _childNameCtrl.text,
                  ),
                  _PanelOrder(
                    theme: _currentTheme,
                    selectedFormat: _selectedFormat,
                    onSelectFormat: (v) =>
                        setState(() => _selectedFormat = v),
                    emailCtrl: _emailCtrl,
                    onConfirm: _confirmOrder,
                  ),
                ][_toolIndex],
              ),
            ),


            // ── Bottom nav bar (masqué après confirmation) ─
            if (!_confirmed)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                      top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    // Précédent
                    TextButton.icon(
                      onPressed:
                          _toolIndex > 0 ? _goPrev : null,
                      icon: const Icon(Icons.chevron_left_rounded, size: 18),
                      label: const Text('Précédent'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        disabledForegroundColor:
                            AppColors.hint,
                        textStyle: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w500),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 12),
                      ),
                    ),
                    const Spacer(),
                    // Suivant / Confirmer (masqué sur l'étape Commander)
                    if (!isLast)
                    FilledButton.icon(
                      onPressed: _goNext,
                      icon: Icon(
                        _toolIndex == 4
                            ? Icons.shopping_cart_outlined
                            : Icons.chevron_right_rounded,
                        size: 18,
                      ),
                      iconAlignment: IconAlignment.end,
                      label: Text(nextLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.md),
                        ),
                        textStyle: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toolbar button ───────────────────────────────────────────────────────────

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(icon,
            size: 20,
            color:
                active ? AppColors.primary : AppColors.secondaryText),
      ),
    );
  }
}

// ─── Panel: IA ────────────────────────────────────────────────────────────────

class _PanelAI extends StatelessWidget {
  const _PanelAI({
    required this.childNameCtrl,
    required this.dedicaceCtrl,
    required this.selectedTheme,
    required this.onSelectTheme,
  });
  final TextEditingController childNameCtrl;
  final TextEditingController dedicaceCtrl;
  final String selectedTheme;
  final ValueChanged<String> onSelectTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Card 1 : Prénom ──────────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                icon: Icons.child_care_rounded,
                iconColor: AppColors.primary,
                title: 'Prénom de l\'enfant',
                subtitle:
                    'Personnalise le contenu et le titre du livre.',
              ),
              const SizedBox(height: AppSpacing.md),
              _BookField(
                controller: childNameCtrl,
                hint: 'Ex: Lucas',
                action: TextInputAction.next,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Card 2 : Thème ───────────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                icon: Icons.palette_rounded,
                iconColor: const Color(0xFFE07A2F),
                title: 'Choisissez un thème',
                subtitle:
                    'Le thème détermine les couleurs et le style du livre',
              ),
              const SizedBox(height: AppSpacing.md),
              ...List.generate(_kThemes.length, (i) {
                final theme = _kThemes[i];
                final active = selectedTheme == theme.name;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i < _kThemes.length - 1
                          ? AppSpacing.sm
                          : 0),
                  child: _ThemeTile(
                    theme: theme,
                    selected: active,
                    onTap: () => onSelectTheme(theme.name),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Card 3 : Dédicace ────────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dédicace (optionnel)',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Un petit mot affiché sur la couverture du livre',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primary, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.md),
              _BookField(
                controller: dedicaceCtrl,
                hint:
                    'Ex: Une année merveilleuse, pleine de découvertes et de sourires...',
                maxLines: 4,
                action: TextInputAction.done,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.theme,
    required this.selected,
    required this.onTap,
  });
  final _BookTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected
              ? theme.gradientEnd.withValues(alpha: 0.25)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: selected ? theme.gradientStart : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.sm - 1)),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.gradientStart, theme.gradientEnd],
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${theme.emoji}  ${theme.name}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    theme.description,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Panel: Photos ────────────────────────────────────────────────────────────

class _PanelPhotos extends StatelessWidget {
  const _PanelPhotos();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section title ────────────────────────────────
        Text(
          'Ajoutez les photos',
          style: AppTextStyles.bodyLarge
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '0 photo(s) sur 0 page(s) • Max 6 par page',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Journal import card ──────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.article_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Photos du journal quotidien',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Importez automatiquement les photos du journal dans les bons mois',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Importer les photos du journal'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Month cards ──────────────────────────────────
        ..._kMonths.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _MonthPhotoCard(month: m),
            )),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ─── Month data ───────────────────────────────────────────────────────────────

const _kMonths = [
  ('🍁', 'Septembre'),
  ('🎃', 'Octobre'),
  ('🍂', 'Novembre'),
  ('❄️', 'Décembre'),
  ('⛄', 'Janvier'),
  ('💝', 'Février'),
  ('🌱', 'Mars'),
  ('🌸', 'Avril'),
  ('🌼', 'Mai'),
  ('☀️', 'Juin'),
  ('🎨', 'Juillet'),
  ('🌻', 'Août'),
];

class _MonthPhotoCard extends StatelessWidget {
  const _MonthPhotoCard({required this.month});
  final (String, String) month;

  @override
  Widget build(BuildContext context) {
    final (emoji, name) = month;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
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
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              // Counter badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  '0/6',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Import button
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.upload_rounded,
                        size: 16, color: AppColors.secondaryText),
                    const SizedBox(width: 4),
                    Text(
                      'Importer',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aucune photo — importez les vôtres',
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.hint,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ─── Panel: Layout ────────────────────────────────────────────────────────────

class _PanelLayout extends StatelessWidget {
  const _PanelLayout({
    required this.layouts,
    required this.selected,
    required this.onSelect,
  });
  final List<String> layouts;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.grid_view_rounded,
            iconColor: AppColors.primary,
            title: 'Mise en page',
            subtitle: 'Choisissez le style visuel de votre livre.',
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.4,
            children: layouts.map((l) {
              final active = selected == l;
              return GestureDetector(
                onTap: () => onSelect(l),
                child: Container(
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.background,
                    borderRadius:
                        BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                      color: active
                          ? AppColors.primary
                          : AppColors.divider,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories_rounded,
                          size: 28,
                          color: active
                              ? AppColors.primary
                              : AppColors.secondaryText),
                      const SizedBox(height: 6),
                      Text(l,
                          style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: active
                                  ? AppColors.primary
                                  : AppColors.primaryText)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ─── Panel: Text ─────────────────────────────────────────────────────────────

class _PanelText extends StatelessWidget {
  const _PanelText({
    required this.titleCtrl,
    required this.coverMsgCtrl,
    required this.endPageCtrl,
  });
  final TextEditingController titleCtrl;
  final TextEditingController coverMsgCtrl;
  final TextEditingController endPageCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section title ────────────────────────────────
        Text(
          'Personnalisez les textes',
          style: AppTextStyles.bodyLarge
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Ajoutez des légendes aux photos et des commentaires pour chaque mois',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.secondaryText, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Titre du livre ───────────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TextCardHeader(emoji: '📖', label: 'Titre du livre'),
              const SizedBox(height: AppSpacing.sm),
              _BookField(
                controller: titleCtrl,
                hint: 'Ex: Notre année ensemble 2025–2026',
                action: TextInputAction.next,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Message de couverture ────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TextCardHeader(emoji: '✨', label: 'Message de couverture'),
              const SizedBox(height: AppSpacing.sm),
              _BookField(
                controller: coverMsgCtrl,
                hint: 'Un court message affiché en couverture...',
                maxLines: 3,
                action: TextInputAction.next,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Month caption cards ──────────────────────────
        ..._kMonths.map((m) {
          final (emoji, name) = m;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextCardHeader(emoji: emoji, label: name),
                  const SizedBox(height: AppSpacing.sm),
                  _BookField(
                    hint:
                        'Une légende pour les photos de $name...',
                    maxLines: 2,
                    action: TextInputAction.next,
                  ),
                ],
              ),
            ),
          );
        }),

        // ── Page de fin ──────────────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TextCardHeader(emoji: '💝', label: 'Page de fin'),
              const SizedBox(height: AppSpacing.sm),
              _BookField(
                controller: endPageCtrl,
                hint: 'Un dernier mot pour clôturer ce beau livre...',
                maxLines: 4,
                action: TextInputAction.done,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _TextCardHeader extends StatelessWidget {
  const _TextCardHeader({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ─── Panel: Preview ───────────────────────────────────────────────────────────

class _PanelPreview extends StatefulWidget {
  const _PanelPreview({
    required this.theme,
    required this.childName,
  });
  final _BookTheme theme;
  final String childName;

  @override
  State<_PanelPreview> createState() => _PanelPreviewState();
}

class _PanelPreviewState extends State<_PanelPreview> {
  int _page = 0;
  static const _totalPages = 2;

  @override
  Widget build(BuildContext context) {
    final name =
        widget.childName.isNotEmpty ? widget.childName : 'Mon enfant';
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section title ────────────────────────────────
        Row(
          children: [
            const Icon(Icons.visibility_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Aperçu du livre',
              style: AppTextStyles.bodyLarge
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Book cover ───────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            height: 340,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.gradientStart,
                  Color.lerp(
                      theme.gradientStart, theme.gradientEnd, 0.6)!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Cover content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📖',
                          style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 20),
                      Text(
                        'L\'année de $name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '2025–2026',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                // Page indicator badge
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(
                      '${_page + 1} / $_totalPages',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Pagination controls ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PageArrow(
              icon: Icons.chevron_left_rounded,
              enabled: _page > 0,
              onTap: () => setState(() => _page--),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Page ${_page + 1} sur $_totalPages',
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: AppSpacing.md),
            _PageArrow(
              icon: Icons.chevron_right_rounded,
              enabled: _page < _totalPages - 1,
              onTap: () => setState(() => _page++),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Summary card ─────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            '📚  0 photos • 0 pages illustrées • Thème : ${theme.emoji} ${theme.name}',
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primaryText : AppColors.hint,
        ),
      ),
    );
  }
}

// ─── Panel: Order ─────────────────────────────────────────────────────────────

class _OrderFormat {
  const _OrderFormat({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.shipping,
    required this.shippingLabel,
  });
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final double shipping;
  final String shippingLabel;
}

const _kFormats = [
  _OrderFormat(
    id: 'pdf',
    title: 'Version PDF numérique',
    subtitle: 'PDF • 2 pages • Envoi par e-mail',
    price: 9.99,
    shipping: 0,
    shippingLabel: '0,00 € (numérique)',
  ),
  _OrderFormat(
    id: 'physical',
    title: 'Livre physique 20×20 cm',
    subtitle: 'Impression • Livraison 10–14 jours',
    price: 29.90,
    shipping: 0,
    shippingLabel: '0,00 € (offerts)',
  ),
];

class _PanelOrder extends StatelessWidget {
  const _PanelOrder({
    required this.theme,
    required this.selectedFormat,
    required this.onSelectFormat,
    required this.emailCtrl,
    required this.onConfirm,
  });
  final _BookTheme theme;
  final String selectedFormat;
  final ValueChanged<String> onSelectFormat;
  final TextEditingController emailCtrl;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final fmt = _kFormats.firstWhere((f) => f.id == selectedFormat,
        orElse: () => _kFormats.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section title ────────────────────────────────
        Row(
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Commandez votre livre',
              style: AppTextStyles.bodyLarge
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Compact cover preview ────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.gradientStart,
                  Color.lerp(
                      theme.gradientStart, theme.gradientEnd, 0.6)!,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📖', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 10),
                const Text(
                  'Mon livre de l\'année',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2025–2026',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Format options ───────────────────────────────
        ..._kFormats.map((f) {
          final active = selectedFormat == f.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelectFormat(f.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color:
                        active ? AppColors.primary : AppColors.divider,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      active
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 22,
                      color: active
                          ? AppColors.primary
                          : AppColors.hint,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f.subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryText,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${f.price.toStringAsFixed(2).replaceAll('.', ',')} €',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // ── Price summary card ───────────────────────────
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _PriceLine(
                label: 'Sous-total',
                value:
                    '${fmt.price.toStringAsFixed(2).replaceAll('.', ',')} €',
              ),
              const SizedBox(height: 6),
              _PriceLine(
                label: 'Frais de port',
                value: fmt.shippingLabel,
                valueColor: AppColors.primary,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(color: AppColors.divider, height: 1),
              ),
              Row(
                children: [
                  Text('Total',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text(
                    '${fmt.price.toStringAsFixed(2).replaceAll('.', ',')} €',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Email / delivery card ────────────────────────
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    selectedFormat == 'pdf'
                        ? 'Adresse e-mail de réception'
                        : 'Adresse de livraison',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                selectedFormat == 'pdf'
                    ? 'Votre livre PDF sera envoyé à cette adresse'
                    : 'Indiquez l\'adresse pour la livraison du livre',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.md),
              _BookField(
                controller: emailCtrl,
                hint: selectedFormat == 'pdf'
                    ? 'votre@email.com'
                    : '12 rue des Lilas, 75001 Paris',
                keyboardType: selectedFormat == 'pdf'
                    ? TextInputType.emailAddress
                    : TextInputType.streetAddress,
                action: TextInputAction.done,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Commander button ─────────────────────────────
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.shopping_cart_outlined, size: 18),
            label: Text(
                'Commander — ${fmt.price.toStringAsFixed(2).replaceAll('.', ',')} €'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              textStyle: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('• ', style: TextStyle(color: AppColors.secondaryText)),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText)),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: valueColor ?? AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Panel: Confirmed ─────────────────────────────────────────────────────────

class _PanelConfirmed extends StatelessWidget {
  const _PanelConfirmed({
    required this.email,
    required this.format,
    required this.theme,
    required this.onBack,
  });
  final String email;
  final String format;
  final _BookTheme theme;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isPdf = format == 'pdf';
    final price = isPdf ? '9,99' : '29,90';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          // ── Checkmark circle ─────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Title ─────────────────────────────────────
          Text(
            'Commande confirmée ! 🎉',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Body ──────────────────────────────────────
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText, height: 1.6),
              children: [
                TextSpan(
                    text: isPdf
                        ? 'Votre livre '
                        : 'Votre livre '),
                const TextSpan(
                  text: '« L\'année de mon enfant »',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText),
                ),
                TextSpan(
                    text: isPdf
                        ? ' sera généré en PDF et envoyé à '
                        : ' sera imprimé et livré à '),
                TextSpan(
                  text: email,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
                TextSpan(
                    text: isPdf ? ' sous 24h.' : ' sous 10–14 jours.'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Summary card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Text(
                  '📖  0 photos • 2 pages • Thème ${theme.emoji} ${theme.name}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$price €',
                  style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Back button ───────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Retour au tableau de bord'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                textStyle: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}


class _BookField extends StatelessWidget {
  const _BookField({
    this.controller,
    required this.hint,
    this.maxLines = 1,
    this.action,
    this.keyboardType,
  });
  final TextEditingController? controller;
  final String hint;
  final int maxLines;
  final TextInputAction? action;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: action,
      keyboardType: keyboardType,
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
    );
  }
}
