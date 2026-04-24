import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/childminder_card.dart';

// ─── Extended mock data ───────────────────────────────────────────────────────

class _PracticalItem {
  const _PracticalItem(this.icon, this.label, {this.color});
  final IconData icon;
  final String label;
  final Color? color;
}

class _Review {
  _Review({
    required this.parentName,
    required this.date,
    required this.childAge,
    required this.duration,
    required this.text,
  });
  final String parentName;
  final String date;
  final String childAge;
  final String duration;
  final String text;
}

class _AssmatProfile {
  _AssmatProfile({
    required this.fullName,
    required this.address,
    required this.isPro,
    required this.isVerified,
    required this.experience,
    required this.placesAvailable,
    required this.placesTotal,
    required this.languages,
    required this.practicalInfo,
    required this.about,
    required this.diplomas,
    required this.careerText,
    required this.schedule,
    required this.agrement,
    required this.specialties,
    required this.reviewsList,
    required this.rating,
    required this.reviews,
    required this.credits,
  });
  final String fullName;
  final String address;
  final bool isPro;
  final bool isVerified;
  final String experience;
  final int placesAvailable;
  final int placesTotal;
  final List<String> languages;
  final List<_PracticalItem> practicalInfo;
  final String about;
  final List<String> diplomas;
  final String careerText;
  final String schedule;
  final String agrement;
  final List<String> specialties;
  final List<_Review> reviewsList;
  final double rating;
  final int reviews;
  final int credits;
}

_AssmatProfile? _profileFor(String key) => _buildProfiles()[key];

Map<String, _AssmatProfile> _buildProfiles() => {
  'ML': _AssmatProfile(
    fullName: 'Marie Lambert',
    address: '12 Rue des Lilas, 75015 Paris',
    isPro: true,
    isVerified: true,
    experience: '12 ans',
    placesAvailable: 1,
    placesTotal: 4,
    languages: ['Français', 'Anglais'],
    practicalInfo: [
      _PracticalItem(Icons.smoke_free_rounded, 'Non fumeur'),
      _PracticalItem(Icons.cruelty_free_rounded, 'Pas d\'animal'),
      _PracticalItem(Icons.health_and_safety_outlined, 'PSC1 validé',
          color: AppColors.primary),
    ],
    about:
        'Assistante maternelle passionnée avec plus de 12 ans d\'expérience. '
        'J\'accueille les enfants dans un environnement bienveillant et '
        'stimulant, inspiré de la pédagogie Montessori. Mon domicile dispose '
        'd\'un grand jardin sécurisé et d\'une salle de jeux dédiée.',
    diplomas: [
      'PSC1 (Premiers Secours)',
      'CAP Petite Enfance',
    ],
    careerText:
        '12 ans d\'expérience auprès d\'enfants de 0 à 6 ans. Ancienne '
        'auxiliaire de puériculture en crèche pendant 3 ans avant de devenir '
        'assistante maternelle.',
    schedule: 'Lundi - Vendredi, 7h30 - 18h30',
    agrement: 'AG-2018-7501234',
    specialties: ['Montessori', 'Éveil musical', 'Jeux extérieurs'],
    reviewsList: [
      _Review(
        parentName: 'Sophie D.',
        date: 'Janvier 2024',
        childAge: 'Enfant de 2 ans',
        duration: 'Gardé 2 ans',
        text: 'Marie est formidable ! Notre fils Lucas a été accueilli pendant '
            '2 ans et il a adoré chaque jour. Elle est très attentive, créative '
            'et vraiment professionnelle.',
      ),
      _Review(
        parentName: 'Thomas R.',
        date: 'Mars 2023',
        childAge: 'Enfant de 18 mois',
        duration: 'Gardé 1 an',
        text: 'Très à l\'écoute, Marie a su s\'adapter aux besoins de notre '
            'petite Chloé. Nous recommandons chaleureusement.',
      ),
      _Review(
        parentName: 'Amina K.',
        date: 'Septembre 2022',
        childAge: 'Enfant de 3 ans',
        duration: 'Gardé 6 mois',
        text: 'Professionnelle et bienveillante. Notre fille a fait de grands '
            'progrès grâce aux activités proposées.',
      ),
      _Review(
        parentName: 'Camille M.',
        date: 'Décembre 2023',
        childAge: 'Enfant de 6 mois',
        duration: 'Gardé 1 an',
        text: 'Excellente assistante maternelle, très à l\'écoute et '
            'patiente. Je recommande vivement à toutes les familles.',
      ),
    ],
    rating: 4.9,
    reviews: 24,
    credits: 3,
  ),
  'JD': _AssmatProfile(
    fullName: 'Julie Dubois',
    address: '5 Avenue Voltaire, 75015 Paris',
    isPro: false,
    isVerified: true,
    experience: '5 ans',
    placesAvailable: 2,
    placesTotal: 4,
    languages: ['Français', 'Espagnol'],
    practicalInfo: [
      _PracticalItem(Icons.smoke_free_rounded, 'Non fumeur'),
      _PracticalItem(Icons.home_rounded, 'Domicile sécurisé'),
      _PracticalItem(Icons.medical_services_rounded, 'Premiers secours PSC1'),
    ],
    about:
        'Jeune assistante maternelle dynamique, diplômée CAP AEPE. J\'accueille '
        'jusqu\'à 2 enfants dans mon domicile sécurisé avec espace de jeux dédié. '
        'Disponibilité immédiate.',
    diplomas: [
      'CAP AEPE',
      'PSC1 (Premiers Secours)',
    ],
    careerText:
        '5 ans d\'expérience auprès d\'enfants de 0 à 3 ans. Diplômée CAP AEPE, '
        'disponible immédiatement avec un espace de jeux dédié.',
    schedule: 'Lundi - Vendredi, 8h00 - 18h00',
    agrement: 'AG-2020-7501189',
    specialties: ['Éveil artistique', 'Lecture', 'Activités sensorielles'],
    reviewsList: [
      _Review(
        parentName: 'Claire M.',
        date: 'Février 2024',
        childAge: 'Enfant de 1 an',
        duration: 'Gardé 8 mois',
        text: 'Julie est douce et très investie. Notre bébé s\'est adapté très '
            'rapidement. Espace de jeux magnifique.',
      ),
      _Review(
        parentName: 'David L.',
        date: 'Octobre 2023',
        childAge: 'Enfant de 2 ans',
        duration: 'Gardé 1 an',
        text: 'Très satisfaits de la garde de notre fils. Julie communique '
            'bien et envoie des photos régulièrement.',
      ),
    ],
    rating: 4.7,
    reviews: 11,
    credits: 3,
  ),
  'SC': _AssmatProfile(
    fullName: 'Sophie Cordier',
    address: '8 Rue du Commerce, 75015 Paris',
    isPro: false,
    isVerified: true,
    experience: '8 ans',
    placesAvailable: 1,
    placesTotal: 4,
    languages: ['Français'],
    practicalInfo: [
      _PracticalItem(Icons.smoke_free_rounded, 'Non fumeur'),
      _PracticalItem(Icons.groups_rounded, 'Maison d\'assistants maternels'),
      _PracticalItem(Icons.directions_car_rounded, 'Peut véhiculer les enfants'),
      _PracticalItem(Icons.restaurant_rounded, 'Repas fournis'),
    ],
    about:
        'Titulaire du BEP Carrières Sanitaires et Sociales et du PSC1, j\'exerce '
        'avec passion depuis 8 ans. Suivi personnalisé et journal quotidien détaillé.',
    diplomas: [
      'BEP Carrières Sanitaires et Sociales',
      'PSC1 (Premiers Secours)',
    ],
    careerText:
        '8 ans d\'expérience en garde d\'enfants. Ancienne aide-soignante '
        'reconvertie, elle apporte une attention particulière au bien-être '
        'et à la santé des enfants accueillis.',
    schedule: 'Lundi - Vendredi, 7h00 - 19h00',
    agrement: 'AG-2017-7501305',
    specialties: ['Maison d\'assistants', 'Premiers secours', 'Cuisine'],
    reviewsList: [
      _Review(
        parentName: 'Léa P.',
        date: 'Avril 2024',
        childAge: 'Enfant de 2 ans',
        duration: 'Gardé 18 mois',
        text: 'Sophie est une personne remarquable. Très attentionnée et '
            'toujours disponible. Nos enfants adorent aller chez elle.',
      ),
      _Review(
        parentName: 'Marc B.',
        date: 'Janvier 2024',
        childAge: 'Enfant de 3 ans',
        duration: 'Gardé 2 ans',
        text: 'Suivi quotidien impeccable, journal très détaillé. On se sent '
            'rassurés de confier notre fils à Sophie.',
      ),
    ],
    rating: 4.8,
    reviews: 18,
    credits: 3,
  ),
};

// ─── Page ─────────────────────────────────────────────────────────────────────

class ChildminderProfilePage extends StatefulWidget {
  const ChildminderProfilePage({super.key, required this.data});
  final ChildminderSummary data;

  @override
  State<ChildminderProfilePage> createState() =>
      _ChildminderProfilePageState();
}

class _ChildminderProfilePageState extends State<ChildminderProfilePage> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final profile = _profileFor(widget.data.initials);
    final credits = profile?.credits ?? 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    color: AppColors.primaryText,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Expanded(
                    child: Text(
                      'Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  // Credits badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.generating_tokens_rounded,
                            size: 14, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('$credits',
                            style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Favorite
                  IconButton(
                    onPressed: () =>
                        setState(() => _isFavorite = !_isFavorite),
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 22,
                      color: _isFavorite
                          ? Colors.redAccent
                          : AppColors.secondaryText,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // ── Body ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Identity card
                          _IdentityCard(
                              data: widget.data, profile: profile),
                          const SizedBox(height: AppSpacing.md),

                          // Stats row
                          if (profile != null) ...[
                            _StatsRow(profile: profile),
                            const SizedBox(height: AppSpacing.md),

                            // Practical info
                            _PracticalInfoCard(profile: profile),
                            const SizedBox(height: AppSpacing.md),

                            // Présentation
                            _SectionCard(
                              icon: Icons.menu_book_rounded,
                              title: 'Présentation',
                              child: Text(
                                profile.about,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.secondaryText,
                                    height: 1.6),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Diplômes & Formation
                            _DiplomasCard(diplomas: profile.diplomas),
                            const SizedBox(height: AppSpacing.md),

                            // Parcours professionnel
                            _CareerCard(text: profile.careerText),
                            const SizedBox(height: AppSpacing.md),

                            // Disponibilités
                            _AvailabilityCard(
                              schedule: profile.schedule,
                              agrement: profile.agrement,
                              placesAvailable: profile.placesAvailable,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Spécialités
                            _SpecialtiesCard(
                                specialties: profile.specialties),
                            const SizedBox(height: AppSpacing.md),

                            // Recommandations
                            _ReviewsCard(
                                reviewsList: profile.reviewsList),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom CTA ──────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          color: AppColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profil débloqué indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Profil débloqué',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message — à venir'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18),
                  label: const Text('Envoyer un message'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    textStyle: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Le tarif horaire sera discuté lors de votre échange',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Identity card ────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.data, required this.profile});
  final ChildminderSummary data;
  final _AssmatProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + PRO badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  data.initials,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (profile?.isPro == true)
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.fullName ?? data.name,
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                // Vérifié badge
                if (profile?.isVerified == true) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Vérifié',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.place_outlined,
                          size: 14, color: AppColors.secondaryText),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        profile?.address ?? data.location,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    'à ${data.distance} de chez vous',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.hint, fontSize: 11),
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

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final _AssmatProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCell(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.primary,
            label: 'Expérience',
            value: profile.experience,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCell(
            icon: Icons.face_rounded,
            iconColor: AppColors.accent,
            label: 'Places',
            value: '${profile.placesAvailable}/${profile.placesTotal}',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCell(
            icon: Icons.people_outline_rounded,
            iconColor: AppColors.primary,
            label: 'Langues',
            value: profile.languages.join(', '),
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText, fontSize: 11),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Practical info card ──────────────────────────────────────────────────────

class _PracticalInfoCard extends StatelessWidget {
  const _PracticalInfoCard({required this.profile});
  final _AssmatProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Text(
              'Informations pratiques',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...profile.practicalInfo.map((item) {
            final fg = item.color ?? AppColors.secondaryText;
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Icon(item.icon, size: 16, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    item.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: fg,
                      fontWeight: item.color != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),
          // "Profil débloqué" indicator
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.divider)),
            ),
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_open_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Profil débloqué',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diplômes & Formation card ────────────────────────────────────────────────

class _DiplomasCard extends StatelessWidget {
  const _DiplomasCard({required this.diplomas});
  final List<String> diplomas;

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
              const Icon(Icons.school_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Diplômes & Formation',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: diplomas
                .map((d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(d,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Parcours professionnel card ──────────────────────────────────────────────

class _CareerCard extends StatelessWidget {
  const _CareerCard({required this.text});
  final String text;

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
              const Icon(Icons.work_outline_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Parcours professionnel',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Spécialités card ────────────────────────────────────────────────────────

class _SpecialtiesCard extends StatelessWidget {
  const _SpecialtiesCard({required this.specialties});
  final List<String> specialties;

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
          Text('Spécialités',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: specialties
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35)),
                      ),
                      child: Text(s,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Recommandations card ────────────────────────────────────────────────────

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.reviewsList});
  final List<_Review> reviewsList;

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
          // Header
          Row(
            children: [
              const Icon(Icons.forum_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Recommandations parents',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${reviewsList.length} recommandations de parents',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),

          // Review list
          ...List.generate(reviewsList.length, (i) {
            final r = reviewsList[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i > 0) ...[
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Name + date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.parentName,
                        style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText)),
                    Text(r.date,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText)),
                  ],
                ),
                const SizedBox(height: 6),
                // Tags
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [r.childAge, r.duration]
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.full),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Text(tag,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.secondaryText,
                                    fontSize: 11)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Quote
                Text(
                  '"${r.text}"',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                      height: 1.5),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          }),

        ],
      ),
    );
  }
}

// ─── Disponibilités card ──────────────────────────────────────────────────────

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.schedule,
    required this.agrement,
    required this.placesAvailable,
  });
  final String schedule;
  final String agrement;
  final int placesAvailable;

  @override
  Widget build(BuildContext context) {
    final placeLabel = placesAvailable == 1
        ? '1 place disponible'
        : '$placesAvailable places disponibles';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header + rows ──
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Disponibilités',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _AvailRow(label: 'Horaires', value: schedule),
                const SizedBox(height: AppSpacing.sm),
                _AvailRow(label: 'Agrément', value: agrement),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // ── Photo de l'agrément ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Photo de l\'agrément vérifiée',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Photo placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Container(
                height: 160,
                color: const Color(0xFFD6CFC8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Simulated document scene
                    Container(color: const Color(0xFFE8E0D8)),
                    const Center(
                      child: Icon(Icons.article_outlined,
                          size: 56, color: Color(0xFFB0A89E)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Badges ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _GreenBadge(label: 'Document vérifié par la PMI'),
                _GreenBadge(label: placeLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenBadge extends StatelessWidget {
  const _GreenBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AvailRow extends StatelessWidget {
  const _AvailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
        ),
        Expanded(
          child: Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ─── Generic section card ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.icon});
  final String title;
  final Widget child;
  final IconData? icon;

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
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
