import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class AssMatNewContractPage extends StatefulWidget {
  const AssMatNewContractPage({super.key});

  @override
  State<AssMatNewContractPage> createState() => _AssMatNewContractPageState();
}

class _AssMatNewContractPageState extends State<AssMatNewContractPage> {
  final Set<int> _expanded = {};
  final Set<int> _visited = {};

  static const _sections = [
    _SectionMeta(
      icon: Icons.people_outline_rounded,
      title: 'Particulier employeur',
      subtitle: 'Coordonnées de la famille',
    ),
    _SectionMeta(
      icon: Icons.person_outline_rounded,
      title: 'Assistant maternel',
      subtitle: 'Numéro d\'agrément et capacité',
    ),
    _SectionMeta(
      icon: Icons.child_care_outlined,
      title: 'Enfant & engagement',
      subtitle: 'Enfant accueilli et dates du contrat',
    ),
    _SectionMeta(
      icon: Icons.schedule_outlined,
      title: 'Durée et horaires d\'accueil',
      subtitle: 'Volume horaire hebdomadaire',
    ),
    _SectionMeta(
      icon: Icons.euro_outlined,
      title: 'Rémunération',
      subtitle: 'Taux horaire et salaire mensuel',
    ),
    _SectionMeta(
      icon: Icons.credit_card_outlined,
      title: 'Indemnités et frais',
      subtitle: 'Entretien, repas et kilométrique',
    ),
    _SectionMeta(
      icon: Icons.calendar_month_outlined,
      title: 'Repos hebdomadaire & jours fériés',
      subtitle: 'Repos, jours fériés et 1er mai',
    ),
    _SectionMeta(
      icon: Icons.umbrella_outlined,
      title: 'Congés annuels',
      subtitle: 'Semaines de congés payés et mensualisation',
    ),
    _SectionMeta(
      icon: Icons.article_outlined,
      title: 'Conditions particulières',
      subtitle: 'Clauses spécifiques au contrat',
    ),
  ];

  void _toggle(int index) {
    setState(() {
      _visited.add(index);
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        _expanded.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 88,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nouveau contrat CDI',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Contrat à durée indéterminée — Assistant maternel agréé',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText),
            ),
            Text(
              'Convention collective IDCC 3239',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              // +1 for the intro card
              itemCount: _sections.length + 1,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                if (i == 0) return const _IntroCard();
                final idx = i - 1;
                final expanded = _expanded.contains(idx);
                final visited = _visited.contains(idx);
                return _AccordionSection(
                  meta: _sections[idx],
                  expanded: expanded,
                  visited: visited,
                  onTap: () => _toggle(idx),
                  child: _SectionBody(index: idx),
                );
              },
            ),
          ),
          _BottomBar(
            visitedCount: _visited.length,
            total: _sections.length,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _SectionMeta {
  const _SectionMeta({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
}

// ─── Intro card ───────────────────────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment remplir ce formulaire ?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dépliez chaque section et renseignez les champs obligatoires (marqués *). '
                  'AMiLY pré-calcule automatiquement certaines valeurs à partir de vos saisies.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.onSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Accordion ───────────────────────────────────────────────────────────────

class _AccordionSection extends StatelessWidget {
  const _AccordionSection({
    required this.meta,
    required this.expanded,
    required this.visited,
    required this.onTap,
    required this.child,
  });

  final _SectionMeta meta;
  final bool expanded;
  final bool visited;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: expanded ? AppColors.primaryText : AppColors.divider,
          width: expanded ? 1.5 : 1,
        ),
        boxShadow: expanded
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md - 1.5),
        child: Stack(
          children: [
            // Content column — drives the overall height
            Padding(
              padding: EdgeInsets.only(left: expanded ? 4 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: visited && !expanded
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.secondary,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.sm),
                            ),
                            child: Icon(
                              visited && !expanded
                                  ? Icons.check_rounded
                                  : meta.icon,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meta.title,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  meta.subtitle,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (visited && !expanded)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Renseigné',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          AnimatedRotation(
                            turns: expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: child,
                    ),
                ],
              ),
            ),
            // Left accent strip — stretches to Stack height via Positioned
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: expanded ? 4 : 0,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section bodies ───────────────────────────────────────────────────────────

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return switch (index) {
      0 => const _EmployeurBody(),
      1 => const _AssmatBody(),
      2 => const _EnfantBody(),
      3 => const _HorairesBody(),
      4 => const _RemunerationBody(),
      5 => const _IndemnitesBody(),
      6 => const _ReposBody(),
      7 => const _CongesBody(),
      8 => const _ConditionsBody(),
      _ => const SizedBox.shrink(),
    };
  }
}

// Section 0 — Particulier employeur
class _EmployeurBody extends StatelessWidget {
  const _EmployeurBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownField(
          label: 'En qualité de',
          isRequired: true,
          items: ['Mère', 'Père', 'Tuteur légal', 'Représentant légal'],
        ),
        SizedBox(height: AppSpacing.sm),
        _Field(label: 'Nom de naissance', hint: 'Dupont', isRequired: true),
        SizedBox(height: AppSpacing.sm),
        _Field(label: 'Nom d\'usage', hint: 'Dupont (si différent)'),
        SizedBox(height: AppSpacing.sm),
        _Field(label: 'Prénom', hint: 'Marie', isRequired: true),
        SizedBox(height: AppSpacing.sm),
        _Field(label: 'Adresse', hint: '12 rue des Roses'),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _Field(label: 'Ville', hint: 'Paris'),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: _Field(
                  label: 'Code postal',
                  hint: '75001',
                  keyboardType: TextInputType.number),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        _Field(
            label: 'Téléphone',
            hint: '06 00 00 00 00',
            keyboardType: TextInputType.phone),
        SizedBox(height: AppSpacing.sm),
        _Field(
            label: 'E-mail',
            hint: 'marie.dupont@email.fr',
            keyboardType: TextInputType.emailAddress),
        SizedBox(height: AppSpacing.sm),
        _PrefixField(
          label: 'N° Pajemploi',
          prefix: 'Y',
          hint: '000 000 000 000',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 4),
        _Hint(
            text:
                'Le numéro Pajemploi commence par Y — il vous est fourni à l\'inscription sur pajemploi.urssaf.fr'),
      ],
    );
  }
}

// Section 1 — Assistant maternel
class _AssmatBody extends StatelessWidget {
  const _AssmatBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Identité ──────────────────────────────
        const _SectionDivider(label: 'Identité'),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
            label: 'Nom de naissance', hint: 'Martin', isRequired: true),
        const SizedBox(height: AppSpacing.sm),
        const _Field(label: 'Nom d\'usage', hint: 'Martin (si différent)'),
        const SizedBox(height: AppSpacing.sm),
        const _Field(label: 'Prénom', hint: 'Sophie', isRequired: true),
        const SizedBox(height: AppSpacing.sm),
        const _Field(label: 'Adresse', hint: '8 allée des Lilas'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: const [
            Expanded(
              flex: 3,
              child: _Field(label: 'Ville', hint: 'Lyon'),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: _Field(
                  label: 'Code postal',
                  hint: '69001',
                  keyboardType: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
            label: 'Téléphone',
            hint: '06 00 00 00 00',
            keyboardType: TextInputType.phone),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
            label: 'E-mail',
            hint: 'sophie.martin@email.fr',
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: AppSpacing.sm),
        const _PrefixField(
          label: 'N° de Sécurité sociale',
          prefix: '2',
          hint: '00 00 00 000 000 00',
          keyboardType: TextInputType.number,
        ),

        // ── Agrément ──────────────────────────────
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(
            label: 'Agrément', icon: Icons.verified_outlined),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
            label: 'Référence de l\'agrément',
            hint: '2023-000-000-000',
            isRequired: true),
        const SizedBox(height: 4),
        const _Hint(
            text: 'Délivré par le Conseil Départemental de votre commune'),
        const SizedBox(height: AppSpacing.sm),
        const _Field(label: 'Département délivrant', hint: 'Rhône (69)'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Expanded(
              child: _DateField(label: 'Date de délivrance', isRequired: true),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: _DateField(label: 'Date du dernier renouvellement'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: const [
            Expanded(
              child: _Field(
                  label: 'Capacité simultanée',
                  hint: '4',
                  keyboardType: TextInputType.number,
                  suffix: 'enfants',
                  isRequired: true),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _Field(
                  label: 'Déjà accueillis',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  suffix: 'enfants'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Nombre d\'enfants déjà accueillis au moment de la signature'),

        // ── Assurance RC Professionnelle ──────────
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(
            label: 'Assurance RC Professionnelle',
            icon: Icons.shield_outlined),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
          label: 'Compagnie',
          hint: 'MAIF, Groupama, MMA…',
          isRequired: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        const _Field(label: 'N° de police', hint: '000-000-000'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: const [
            Expanded(
                child: _DateField(label: 'Date d\'effet', isRequired: true)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _DateField(label: 'Date d\'expiration')),
          ],
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Obligatoire — doit couvrir les dommages causés aux enfants accueillis'),

        // ── Assurance automobile ───────────────────
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(
            label: 'Assurance automobile',
            icon: Icons.directions_car_outlined),
        const SizedBox(height: AppSpacing.sm),
        const _Field(label: 'Compagnie', hint: 'AXA, Allianz, MAIF…'),
        const SizedBox(height: AppSpacing.sm),
        const _Field(label: 'N° de police', hint: '000-000-000'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: const [
            Expanded(child: _DateField(label: 'Date d\'effet')),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _DateField(label: 'Date d\'expiration')),
          ],
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Requise si l\'assmat transporte l\'enfant — vérifier la clause "déplacements professionnels"'),
      ],
    );
  }
}

// Section 2 — Enfant & engagement
class _EnfantBody extends StatefulWidget {
  const _EnfantBody();

  @override
  State<_EnfantBody> createState() => _EnfantBodyState();
}

class _EnfantBodyState extends State<_EnfantBody> {
  String _lieu = 'Domicile du salarié';

  static const _lieuxOptions = [
    'Domicile du salarié',
    'Domicile de l\'employeur',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Identité de l'enfant ───────────────────
        const _Field(
            label: 'Nom de l\'enfant', hint: 'Dupont', isRequired: true),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
            label: 'Prénom de l\'enfant', hint: 'Lucas', isRequired: true),
        const SizedBox(height: AppSpacing.sm),
        const _DateField(label: 'Date de naissance'),
        const SizedBox(height: AppSpacing.sm),
        const _DropdownField(
          label: 'Rang dans la fratrie',
          items: ['1er enfant', '2ème enfant', '3ème enfant et +'],
        ),

        // ── Lieu d'accueil ─────────────────────────
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(
            label: 'Lieu d\'accueil', icon: Icons.home_outlined),
        const SizedBox(height: AppSpacing.sm),
        _DropdownField(
          label: 'Lieu d\'accueil',
          isRequired: true,
          items: _lieuxOptions,
          initialValue: _lieu,
          onChanged: (v) => setState(() => _lieu = v ?? _lieu),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
            label: 'Adresse du lieu d\'accueil',
            hint: '8 allée des Lilas, 69001 Lyon'),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Indiquer l\'adresse complète si différente du domicile de l\'assmat'),

        // ── Dates du contrat ───────────────────────
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(
            label: 'Dates du contrat', icon: Icons.event_outlined),
        const SizedBox(height: AppSpacing.sm),
        const _DateField(label: 'Date d\'embauche (début)', isRequired: true),
        const SizedBox(height: AppSpacing.sm),
        const _DateField(label: 'Fin prévue'),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'La fin prévue est indicative pour un CDI — le contrat se poursuit jusqu\'à rupture formelle'),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
          label: 'Durée de la période d\'essai',
          hint: 'Ex : 3 mois (facultative)',
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'La période d\'essai et le délai de prévenance en cas de rupture sont facultatifs (art. 44-1 CC).'),
        const SizedBox(height: AppSpacing.sm),
        const _Field(
          label: 'Période d\'adaptation (jours calendaires, max 30)',
          hint: '30',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: const [
            Expanded(child: _DateField(label: 'Du')),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _DateField(label: 'Au')),
          ],
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Pendant la période d\'adaptation, le salarié sera rémunéré sur la base du salaire mensuel moins les heures non effectuées (art. 94 CC).'),
      ],
    );
  }
}

// Section 3 — Durée et horaires
class _HorairesBody extends StatefulWidget {
  const _HorairesBody();

  @override
  State<_HorairesBody> createState() => _HorairesBodyState();
}

class _HorairesBodyState extends State<_HorairesBody> {
  String _typeContrat =
      'Cas n°1 — Accueil sur 52 semaines (congés inclus)';

  static const _typeOptions = [
    'Cas n°1 — Accueil sur 52 semaines (congés inclus)',
    'Cas n°2 — Accueil sur 46 semaines ou moins (hors congés)',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownField(
          label: 'Type de contrat',
          isRequired: true,
          items: _typeOptions,
          initialValue: _typeContrat,
          onChanged: (v) => setState(() => _typeContrat = v ?? _typeContrat),
        ),
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(
            label: 'Planning hebdomadaire', icon: Icons.schedule_outlined),
        const SizedBox(height: AppSpacing.sm),
        const _WeeklyScheduleField(),
        const SizedBox(height: AppSpacing.md),
        const _Field(
          label: 'Délai de prévenance pour modification\n(semaines calendaires)',
          hint: '2',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Délai minimum à respecter avant toute modification unilatérale des horaires'),
      ],
    );
  }
}

class _WeeklyScheduleField extends StatefulWidget {
  const _WeeklyScheduleField();

  @override
  State<_WeeklyScheduleField> createState() => _WeeklyScheduleFieldState();
}

class _WeeklyScheduleFieldState extends State<_WeeklyScheduleField> {
  static const _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  final Set<int> _active = {0, 1, 2, 3, 4};
  late final List<TextEditingController> _start;
  late final List<TextEditingController> _end;

  @override
  void initState() {
    super.initState();
    _start = List.generate(
        _days.length,
        (i) =>
            TextEditingController(text: _active.contains(i) ? '08:00' : ''));
    _end = List.generate(
        _days.length,
        (i) =>
            TextEditingController(text: _active.contains(i) ? '18:00' : ''));
    for (final c in [..._start, ..._end]) {
      c.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final c in [..._start, ..._end]) {
      c.removeListener(_rebuild);
      c.dispose();
    }
    super.dispose();
  }

  double _dayHours(int i) {
    if (!_active.contains(i)) return 0;
    final s = _start[i].text.split(':');
    final e = _end[i].text.split(':');
    if (s.length < 2 || e.length < 2) return 0;
    final sm = (int.tryParse(s[0]) ?? 0) * 60 + (int.tryParse(s[1]) ?? 0);
    final em = (int.tryParse(e[0]) ?? 0) * 60 + (int.tryParse(e[1]) ?? 0);
    final diff = em - sm;
    return diff > 0 ? diff / 60.0 : 0;
  }

  double get _totalHours =>
      List.generate(_days.length, _dayHours).fold(0, (a, b) => a + b);

  Future<void> _pickTime(
      BuildContext context, TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '') ?? 8,
      minute: int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0,
    );
    final picked =
        await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalHours;
    final over48 = total > 48;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_days.length, (i) {
        final active = _active.contains(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (active) {
                  _active.remove(i);
                  _start[i].clear();
                  _end[i].clear();
                } else {
                  _active.add(i);
                  _start[i].text = '08:00';
                  _end[i].text = '18:00';
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.secondary
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                    color: active ? AppColors.primary : AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.divider),
                        ),
                        child: active
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: AppColors.onPrimary)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _days[i],
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: active
                              ? AppColors.primaryText
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  if (active) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeInputField(controller: _start[i],
                              onTap: () => _pickTime(context, _start[i])),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm),
                          child: Text('à',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.secondaryText)),
                        ),
                        Expanded(
                          child: _TimeInputField(controller: _end[i],
                              onTap: () => _pickTime(context, _end[i])),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),

        // ── Total heures ───────────────────────────
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 10),
          decoration: BoxDecoration(
            color: over48
                ? AppColors.error.withValues(alpha: 0.06)
                : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
                color: over48
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Total heures/semaine : ',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                  Text(
                    total == total.truncateToDouble()
                        ? '${total.toInt()}h'
                        : '${total.toStringAsFixed(1)}h',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: over48 ? AppColors.error : AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              if (over48) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 13, color: AppColors.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Durée max : 48h/semaine en moyenne sur 4 mois',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeInputField extends StatelessWidget {
  const _TimeInputField(
      {required this.controller, required this.onTap});
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '--:--',
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
        suffixIcon: const Icon(Icons.schedule_outlined,
            size: 16, color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 10),
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
      style: AppTextStyles.bodyMedium
          .copyWith(fontWeight: FontWeight.w600),
    );
  }
}

// Section 4 — Rémunération
class _RemunerationBody extends StatefulWidget {
  const _RemunerationBody();

  @override
  State<_RemunerationBody> createState() => _RemunerationBodyState();
}

class _RemunerationBodyState extends State<_RemunerationBody> {
  bool _alsaceMoselle = false;
  bool _isBrut = true;
  bool _pajemploiPlus = true;
  String _majAdd = '0 %';
  String _majSup = '25 %';
  final _tauxCtrl = TextEditingController(text: '4');

  static const _majAddOptions = ['0 %', '10 %', '25 %'];
  static const _majSupOptions = ['25 %', '50 %'];

  // Ratios net/brut selon le type d'heure (Pajemploi 2026)
  double get _ratioClassique => _alsaceMoselle ? 0.7612 : 0.7812;
  double get _ratioCompl => _alsaceMoselle ? 0.8743 : 0.8943;

  double get _tauxSaisi =>
      double.tryParse(_tauxCtrl.text.replaceAll(',', '.')) ?? 0;

  double _brutFor(double ratio) =>
      _isBrut ? _tauxSaisi : (_tauxSaisi > 0 ? _tauxSaisi / ratio : 0);
  double _netFor(double ratio) =>
      _isBrut ? _tauxSaisi * ratio : _tauxSaisi;

  double _majPct(String s) {
    final n = double.tryParse(s.replaceAll(' %', '').trim()) ?? 0;
    return n / 100;
  }

  // Minimum légal net/h assmat 2026
  static const double _minLegal = 3.18;

  // Mock heures/sem et semaines/an (liés à la section Horaires)
  static const int _mockHeures = 54;
  static const int _mockSemaines = 52;

  double get _salaireBrut =>
      _brutFor(_ratioClassique) * _mockHeures * _mockSemaines / 12;
  double get _salaireNet => _salaireBrut * _ratioClassique;

  @override
  void initState() {
    super.initState();
    _tauxCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tauxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alsace-Moselle toggle
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Résidez-vous en Alsace-Moselle ?',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Text('Non',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText)),
              const SizedBox(width: 4),
              Switch(
                value: _alsaceMoselle,
                onChanged: (v) => setState(() => _alsaceMoselle = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Taux horaire
        Text(
          'Taux horaire',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        // Brut / Net segmented toggle
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: 'Brut',
                  selected: _isBrut,
                  onTap: () => setState(() => _isBrut = true),
                ),
              ),
              Expanded(
                child: _SegmentButton(
                  label: 'Net',
                  selected: !_isBrut,
                  onTap: () => setState(() => _isBrut = false),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _tauxCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: _isBrut ? '5,00' : '3,93',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
            suffixText: '€ / heure (${_isBrut ? 'brut' : 'net'})',
            suffixStyle: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
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
          style: AppTextStyles.bodyMedium
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Plancher SMIC 2026 : 11,88 €/h brut · Plafond CMG : 14,93 €/h net'),
        const SizedBox(height: AppSpacing.md),

        // Majorations
        _DropdownField(
          label: 'Majoration des heures additionnelles',
          items: _majAddOptions,
          initialValue: _majAdd,
          onChanged: (v) => setState(() => _majAdd = v ?? _majAdd),
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Heures au-delà du volume contractuel sans dépasser 10 % (art. 57 CC)'),
        const SizedBox(height: AppSpacing.sm),
        _DropdownField(
          label: 'Majoration des heures supplémentaires',
          items: _majSupOptions,
          initialValue: _majSup,
          onChanged: (v) => setState(() => _majSup = v ?? _majSup),
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Heures dépassant le volume contractuel + 10 % (art. 57 CC)'),
        const SizedBox(height: AppSpacing.md),

        // ── Résultats calculés ────────────────────
        const _SectionDivider(label: 'Résultats'),
        const SizedBox(height: AppSpacing.sm),
        if (_tauxSaisi <= 0)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.calculate_outlined,
                    size: 18, color: AppColors.hint),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Entrez un taux horaire pour voir les résultats',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.hint),
                ),
              ],
            ),
          )
        else ...[
          _ResultCard(
            title: 'Heure classique',
            brut: _brutFor(_ratioClassique),
            net: _netFor(_ratioClassique),
            ratio: _ratioClassique,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ResultCard(
            title: 'Heure complémentaire ($_majAdd de majoration sur le brut)',
            brut: _brutFor(_ratioCompl) * (1 + _majPct(_majAdd)),
            net: _netFor(_ratioCompl) * (1 + _majPct(_majAdd)),
            ratio: _ratioCompl,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ResultCard(
            title: 'Heure supplémentaire incluse dans la mensualisation (non majorée)',
            brut: _brutFor(_ratioCompl),
            net: _netFor(_ratioCompl),
            ratio: _ratioCompl,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ResultCard(
            title: 'Majoration de $_majSup appliquée aux heures sup. du mois',
            brut: _brutFor(_ratioCompl) * _majPct(_majSup),
            net: _brutFor(_ratioCompl) * _majPct(_majSup) * _ratioCompl,
            ratio: _ratioCompl,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Min légal warning
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: _netFor(_ratioClassique) < _minLegal
                    ? AppColors.error
                    : AppColors.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                'Min légal : ${_minLegal.toStringAsFixed(2).replaceAll('.', ',')} € net/h',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _netFor(_ratioClassique) < _minLegal
                      ? AppColors.error
                      : AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Salaire mensuel de base
          Text(
            'Salaire mensuel de base',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
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
                Text(
                  '${_brutFor(_ratioClassique).toStringAsFixed(0)} € × ${_mockHeures}h'
                  ' × $_mockSemaines sem ÷ 12 mois',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ResultRow(
                  label: 'Salaire mensuel brut :',
                  value: '${_salaireBrut.toStringAsFixed(2).replaceAll('.', ',')} €',
                ),
                _ResultRow(
                  label: 'Salaire mensuel net :',
                  value: '${_salaireNet.toStringAsFixed(2).replaceAll('.', ',')} €',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm - 2),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.onPrimary : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _CmgRow extends StatelessWidget {
  const _CmgRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: const Color(0xFF004D40))),
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF00796B),
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

// Section 5 — Indemnités et frais
class _IndemnitesBody extends StatefulWidget {
  const _IndemnitesBody();

  @override
  State<_IndemnitesBody> createState() => _IndemnitesBodyState();
}

class _IndemnitesBodyState extends State<_IndemnitesBody> {
  final _dureeCtrl = TextEditingController(text: '9');
  final _tauxEntretienCtrl = TextEditingController(text: '3,5');
  final _tauxRepasCtrl = TextEditingController(text: '4');
  final _kmCtrl = TextEditingController(text: '0');
  final _jourPaiementCtrl = TextEditingController(text: '5');
  bool _pajemploiPlus = false;

  static const double _minEntretienJour = 2.65;
  static const double _minRepasJour = 3.08;

  @override
  void initState() {
    super.initState();
    _dureeCtrl.addListener(_rebuild);
    _tauxEntretienCtrl.addListener(_rebuild);
    _tauxRepasCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _dureeCtrl.dispose();
    _tauxEntretienCtrl.dispose();
    _tauxRepasCtrl.dispose();
    _kmCtrl.dispose();
    _jourPaiementCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  double get _duree => _parse(_dureeCtrl);
  double get _tauxEntretien => _parse(_tauxEntretienCtrl);
  double get _tauxRepas => _parse(_tauxRepasCtrl);
  double get _montantEntretienJour => _duree * _tauxEntretien;
  double get _montantRepasJour => _duree * _tauxRepas;

  String _fmt(double v) =>
      '${v.toStringAsFixed(2).replaceAll('.', ',')} €';

  @override
  Widget build(BuildContext context) {
    final entretienOk = _montantEntretienJour >= _minEntretienJour;
    final repasOk = _montantRepasJour >= _minRepasJour;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Indemnité d'entretien ──────────────────
        Text('Indemnité d\'entretien',
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          'Le montant journalier minimum est de 2,65 €, quel que soit le '
          'nombre d\'heures. Pour 9h de travail effectif : minimum 90 % du '
          'minimum garanti.',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Field(
          label: 'Durée journée type (heures)',
          hint: '9',
          controller: _dureeCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Field(
          label: 'Montant horaire entretien (€)',
          hint: '3,5',
          controller: _tauxEntretienCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.sm),
        _IndemniteResultRow(
          label: 'Montant journalier entretien',
          value: _fmt(_montantEntretienJour),
          minValue: _fmt(_minEntretienJour),
          isOk: entretienOk,
        ),

        // ── Frais de repas ────────────────────────
        const SizedBox(height: AppSpacing.md),
        Text('Frais de repas',
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        const _DropdownField(
          label: 'Les repas sont fournis par :',
          isRequired: true,
          items: [
            'L\'assistant maternel',
            'La famille',
            'Les deux (à préciser)',
          ],
          initialValue: 'L\'assistant maternel',
        ),
        const SizedBox(height: AppSpacing.sm),
        _Field(
          label: 'Montant par repas (€)',
          hint: '4',
          controller: _tauxRepasCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.sm),
        _IndemniteResultRow(
          label: 'Montant journalier repas',
          value: _fmt(_montantRepasJour),
          minValue: _fmt(_minRepasJour),
          isOk: repasOk,
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Dû dès lors que l\'enfant prend un repas principal chez l\'assmat. Min. 2026 : 3,08 €/repas'),

        // ── Indemnité kilométrique ─────────────────
        const SizedBox(height: AppSpacing.md),
        Text('Indemnité kilométrique',
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          'À prévoir si l\'assistante maternelle transporte l\'enfant '
          '(sorties, école, activités). Barème fiscal 2026 recommandé.',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Field(
          label: 'Indemnité kilométrique (€/km)',
          hint: '0,30',
          controller: _kmCtrl,
          keyboardType: TextInputType.number,
        ),

        // ── Jour de paiement ──────────────────────
        const SizedBox(height: AppSpacing.md),
        _Field(
          label: 'Jour de paiement du salaire',
          hint: '5',
          controller: _jourPaiementCtrl,
          keyboardType: TextInputType.number,
        ),

        // ── Pajemploi+ ────────────────────────────
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => setState(() => _pajemploiPlus = !_pajemploiPlus),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _pajemploiPlus
                              ? AppColors.primary
                              : AppColors.hint,
                          width: 2,
                        ),
                      ),
                      child: _pajemploiPlus
                          ? Center(
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Pajemploi+ (versement par l\'Urssaf)',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Avec Pajemploi+, l\'Urssaf prélève le salaire et le verse directement au salarié.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}

// Section 6 — Repos hebdomadaire & jours fériés
class _ReposBody extends StatefulWidget {
  const _ReposBody();

  @override
  State<_ReposBody> createState() => _ReposBodyState();
}

class _ReposBodyState extends State<_ReposBody> {
  static const _joursFeries = [
    '1er janvier',
    'Vendredi Saint (Alsace-Moselle)',
    'Lundi de Pâques',
    '8 mai',
    'Jeudi de l\'Ascension',
    'Lundi de Pentecôte',
    'Abolition de l\'esclavage (DROM)',
    '14 juillet',
    '15 août',
    '1er novembre',
    '11 novembre',
    '25 décembre',
    '26 décembre (Alsace-Moselle)',
  ];

  final Set<int> _selected = {};
  final _tauxCtrl = TextEditingController(text: '10');

  @override
  void dispose() {
    _tauxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Repos hebdomadaire ────────────────────
        const _SectionDivider(label: 'Repos hebdomadaire'),
        const SizedBox(height: AppSpacing.sm),
        const _DropdownField(
          label: 'Jour de repos',
          isRequired: true,
          items: ['Dimanche', 'Samedi', 'Samedi et dimanche', 'Autre (préciser)'],
          initialValue: 'Dimanche',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _DropdownField(
          label: 'Travail exceptionnel ce jour :',
          items: [
            'Rémunéré (+25%)',
            'Repos compensateur',
            'Rémunéré (+25%) + repos compensateur',
          ],
          initialValue: 'Rémunéré (+25%)',
        ),
        const SizedBox(height: 4),
        const _Hint(text: '+ repos quotidien de 11 heures consécutives.'),

        // ── 1er Mai ───────────────────────────────
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(label: '1er Mai'),
        const SizedBox(height: AppSpacing.sm),
        const _DropdownField(
          label: '1er mai',
          items: [
            'Chômé (inclus dans la mensualisation)',
            'Travaillé — majoration 100 %',
            'Travaillé — repos compensateur',
          ],
          initialValue: 'Chômé (inclus dans la mensualisation)',
        ),
        const SizedBox(height: 4),
        const _Hint(
            text:
                'Le 1er mai est le seul jour férié légalement chômé et payé (art. L3133-4)'),

        // ── Jours fériés ordinaires travaillés ────
        const SizedBox(height: AppSpacing.md),
        const _SectionDivider(label: 'Jours fériés ordinaires travaillés'),
        const SizedBox(height: 6),
        Text(
          'Cochez uniquement les jours fériés qui seront travaillés :',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(_joursFeries.length, (i) {
          final selected = _selected.contains(i);
          return GestureDetector(
            onTap: () => setState(() {
              selected ? _selected.remove(i) : _selected.add(i);
            }),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.hint,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _joursFeries[i],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected
                          ? AppColors.primaryText
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // ── Taux de majoration ────────────────────
        const SizedBox(height: AppSpacing.sm),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.md),
        _Field(
          label: 'Taux de majoration jours fériés (%) — min 10%',
          hint: '10',
          controller: _tauxCtrl,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

// Section 7 — Congés annuels
class _CongesBody extends StatefulWidget {
  const _CongesBody();

  @override
  State<_CongesBody> createState() => _CongesBodyState();
}

class _CongesBodyState extends State<_CongesBody> {
  final _semainesCtrl = TextEditingController(text: '5');
  bool _mensualise = true;

  @override
  void dispose() {
    _semainesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(
          label: 'Semaines de congés payés',
          hint: '5',
          controller: _semainesCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => setState(() => _mensualise = !_mensualise),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mensualise ? AppColors.primary : AppColors.background,
                  border: Border.all(
                    color: _mensualise ? AppColors.primary : AppColors.hint,
                    width: 2,
                  ),
                ),
                child: _mensualise
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: AppColors.onPrimary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Congés inclus dans la mensualisation',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        if (_mensualise) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '→ 4 semaines pendant la période du 1er mai au 31 octobre',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '→ 1 semaine en hiver',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dates à fixer avant le 1er mars de chaque année.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        const _Hint(
            text:
                'L\'indemnité de CP est calculée par la méthode la plus avantageuse : maintien de salaire ou 1/10e de la rémunération brute totale.'),
      ],
    );
  }
}

// Section 8 — Conditions particulières
class _ConditionsBody extends StatelessWidget {
  const _ConditionsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activités conseillées ou à proscrire, cahier de liaison, '
          'présence d\'animaux, etc. (art. 90-4 CC)',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Précisez les conditions particulières d\'accueil…',
            hintStyle:
                AppTextStyles.bodySmall.copyWith(color: AppColors.hint),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(AppSpacing.md),
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
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        const _ClauseCard(
          title: 'Indemnité de fin de contrat',
          body:
              'En cas de retrait d\'enfant après 9 mois d\'accueil : 1/80e du total des salaires bruts perçus pendant la durée du contrat.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _ClauseCard(
          title: 'Confidentialité',
          body:
              'Les parties s\'engagent à conserver confidentielles les informations personnelles transmises (art. 9 CC).',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _ClauseCard(
          title: 'Retraite & Prévoyance',
          body:
              'Ircem AGIRC/ARRCO & Ircem Prévoyance — 261 av. des Nations-Unies, 59060 Roubaix',
        ),
      ],
    );
  }
}

class _ClauseCard extends StatelessWidget {
  const _ClauseCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _IndemniteResultRow extends StatelessWidget {
  const _IndemniteResultRow({
    required this.label,
    required this.value,
    required this.minValue,
    required this.isOk,
  });
  final String label;
  final String value;
  final String minValue;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: isOk
            ? AppColors.secondary
            : AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isOk
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText)),
                Text(
                  isOk ? 'Min. $minValue ✓' : 'Min. requis : $minValue',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isOk ? AppColors.primary : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isOk ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.isRequired = false,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? suffix;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.hint,
            ),
            suffixText: suffix,
            suffixStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.brut,
    required this.net,
    required this.ratio,
  });
  final String title;
  final double brut;
  final double net;
  final double ratio;

  String _fmt(double v) =>
      v.toStringAsFixed(2).replaceAll('.', ',') + ' €';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ResultRow(label: 'Brut', value: _fmt(brut)),
          _ResultRow(label: 'Net arrondi', value: _fmt(net)),
          _ResultRow(
            label: 'Ratio',
            value: ratio.toStringAsFixed(4),
            valueColor: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText)),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.primaryText,
              )),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.secondaryText),
          const SizedBox(width: 4),
        ],
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }
}

class _DateField extends StatefulWidget {
  const _DateField({required this.label, this.isRequired = false});
  final String label;
  final bool isRequired;

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2040),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      _ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
            children: widget.isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _ctrl,
          readOnly: true,
          onTap: _pick,
          decoration: InputDecoration(
            hintText: 'jj/mm/aaaa',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
            suffixIcon: const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.secondaryText),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
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

class _DropdownField extends StatefulWidget {
  const _DropdownField({
    required this.label,
    required this.items,
    this.isRequired = false,
    this.initialValue,
    this.onChanged,
  });

  final String label;
  final List<String> items;
  final bool isRequired;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(_DropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_value != null && !widget.items.contains(_value)) {
      _value = widget.items.contains(widget.initialValue)
          ? widget.initialValue
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
            children: widget.isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
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
          hint: Text(
            'Sélectionner…',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.secondaryText),
          items: widget.items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChanged?.call(v);
          },
        ),
      ],
    );
  }
}

class _PrefixField extends StatelessWidget {
  const _PrefixField({
    required this.label,
    required this.prefix,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
  });

  final String label;
  final String prefix;
  final String hint;
  final TextInputType keyboardType;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.hint),
            prefixText: '$prefix ',
            prefixStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
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

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 13, color: AppColors.hint),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.hint),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.visitedCount,
    required this.total,
    required this.onPressed,
  });
  final int visitedCount;
  final int total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: visitedCount / total,
                    minHeight: 4,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$visitedCount / $total sections',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    foregroundColor: AppColors.secondaryText,
                    textStyle: AppTextStyles.labelLarge
                        .copyWith(fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text('Créer le contrat CDI'),
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
        ],
      ),
    );
  }
}
