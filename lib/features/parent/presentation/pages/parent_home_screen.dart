import 'package:flutter/material.dart';

import '../widgets/assmat_card.dart';

/// Écran d'accueil du Parent : header de bienvenue, barre de recherche,
/// liste des "Nouveaux profils" d'assistantes maternelles et bottom nav.
///
/// Pour l'instant tout est **mocké** (données statiques + `print` pour
/// les interactions). Branchement Firestore + providers Riverpod dans
/// une prochaine itération.
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  // --- Brand ---------------------------------------------------------------
  static const _primary = Color(0xFF2AB5A6);      // bleu canard / turquoise
  static const _primaryDark = Color(0xFF1F9B8E);  // pour dégradé léger
  static const _bgSoft = Color(0xFFF7F8FA);       // fond très doux

  // --- Mock data -----------------------------------------------------------
  static const String _mockUserName = 'Sophie';
  static const String _mockUserPhoto =
      'https://i.pravatar.cc/150?img=47';

  static const List<_MockAssMat> _mockAssMats = [
    _MockAssMat(
      name: 'Marie Dubois',
      photoUrl: 'https://i.pravatar.cc/150?img=32',
      rating: 4.9,
      city: 'Paris 15e',
      distanceKm: 1.2,
      hourlyRate: 12,
      yearsExperience: 8,
      hasFirstAidTraining: true,
    ),
    _MockAssMat(
      name: 'Fatima Benali',
      photoUrl: 'https://i.pravatar.cc/150?img=45',
      rating: 4.8,
      city: 'Boulogne-Billancourt',
      distanceKm: 2.5,
      hourlyRate: 11,
      yearsExperience: 5,
      hasFirstAidTraining: true,
    ),
    _MockAssMat(
      name: 'Sylvie Martin',
      photoUrl: 'https://i.pravatar.cc/150?img=23',
      rating: 4.7,
      city: 'Paris 14e',
      distanceKm: 0.8,
      hourlyRate: 13,
      yearsExperience: 12,
      hasFirstAidTraining: true,
    ),
    _MockAssMat(
      name: 'Céline Moreau',
      photoUrl: 'https://i.pravatar.cc/150?img=5',
      rating: 4.6,
      city: 'Issy-les-Moulineaux',
      distanceKm: 3.1,
      hourlyRate: 10,
      yearsExperience: 3,
      hasFirstAidTraining: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSoft,
      // CustomScrollView pour un header qui scroll naturellement avec la liste.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HomeHeader(
              userName: _mockUserName,
              userPhoto: _mockUserPhoto,
              primary: _primary,
              primaryDark: _primaryDark,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const _SearchField(primary: _primary),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Nouveaux profils'),
                  const SizedBox(height: 12),
                  ..._mockAssMats.map(
                    (m) => AssMatCard(
                      name: m.name,
                      photoUrl: m.photoUrl,
                      rating: m.rating,
                      city: m.city,
                      distanceKm: m.distanceKm,
                      hourlyRate: m.hourlyRate,
                      yearsExperience: m.yearsExperience,
                      hasFirstAidTraining: m.hasFirstAidTraining,
                      primaryColor: _primary,
                      onViewProfile: () =>
                          // ignore: avoid_print
                          print('Voir le profil de ${m.name}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(
        activeIndex: 0,
        primary: _primary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Composants internes
// ═══════════════════════════════════════════════════════════════════════════

/// En-tête turquoise arrondi : photo profil + salutation.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.userPhoto,
    required this.primary,
    required this.primaryDark,
  });

  final String userName;
  final String userPhoto;
  final Color primary;
  final Color primaryDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // Photo de profil circulaire avec halo blanc
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(userPhoto),
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $userName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Trouvez la nounou parfaite pour votre enfant',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.white),
            onPressed: () =>
                // ignore: avoid_print
                print('Notifications'),
          ),
        ],
      ),
    );
  }
}

/// Champ de recherche avec icône loupe.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        textInputAction: TextInputAction.search,
        onChanged: (v) =>
            // ignore: avoid_print
            print('Recherche : $v'),
        onSubmitted: (v) =>
            // ignore: avoid_print
            print('Recherche validée : $v'),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, ville...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
      ),
    );
  }
}

/// Titre de section avec lien "Voir tout".
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () =>
              // ignore: avoid_print
              print('Voir tout'),
          child: const Text('Voir tout'),
        ),
      ],
    );
  }
}

/// Barre de navigation du bas — 4 onglets, Accueil actif.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.activeIndex,
    required this.primary,
  });

  final int activeIndex;
  final Color primary;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Accueil'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    (icon: Icons.favorite_border_rounded, label: 'Favoris'),
    (icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = i == activeIndex;
              final color = active ? primary : Colors.grey.shade500;
              return InkWell(
                onTap: () =>
                    // ignore: avoid_print
                    print('Nav tap: ${_items[i].label}'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_items[i].icon, color: color, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Mock data model (privé au fichier)
// ═══════════════════════════════════════════════════════════════════════════

class _MockAssMat {
  const _MockAssMat({
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.city,
    required this.distanceKm,
    required this.hourlyRate,
    required this.yearsExperience,
    required this.hasFirstAidTraining,
  });

  final String name;
  final String photoUrl;
  final double rating;
  final String city;
  final double distanceKm;
  final double hourlyRate;
  final int yearsExperience;
  final bool hasFirstAidTraining;
}
