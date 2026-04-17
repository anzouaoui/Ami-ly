import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Carte réutilisable d'une assistante maternelle.
///
/// Affiche photo + nom + note + ville + distance + tarif + badges
/// + bouton CTA "Voir le profil".
///
/// Stateless et pilotée uniquement par ses paramètres → facile à brancher
/// plus tard sur un `AssMatProfile` issu de Firestore.
class AssMatCard extends StatelessWidget {
  const AssMatCard({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.city,
    required this.distanceKm,
    required this.hourlyRate,
    required this.yearsExperience,
    required this.hasFirstAidTraining,
    required this.onViewProfile,
    this.primaryColor = const Color(0xFF2AB5A6),
  });

  final String name;
  final String photoUrl;
  final double rating;          // 0.0 - 5.0
  final String city;            // "Paris 15e"
  final double distanceKm;      // 1.2
  final double hourlyRate;      // 12.0 en €/h
  final int yearsExperience;    // 8
  final bool hasFirstAidTraining;
  final VoidCallback onViewProfile;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- En-tête : photo + infos principales ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(photoUrl: photoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne 1 : nom + note
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.star_rounded,
                            size: 18, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Ligne 2 : ville + distance
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$city • ${distanceKm.toStringAsFixed(1)} km',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Ligne 3 : tarif
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${hourlyRate.toStringAsFixed(0)}€',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' /heure',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // --- Badges ---
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                icon: Icons.workspace_premium_outlined,
                label: '$yearsExperience ans d\'exp.',
                color: primaryColor,
              ),
              if (hasFirstAidTraining)
                _Badge(
                  icon: Icons.medical_services_outlined,
                  label: 'Premiers Secours',
                  color: primaryColor,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // --- CTA ---
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onViewProfile,
              child: const Text(
                'Voir le profil',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar circulaire avec cache réseau + fallback en cas d'échec.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade200,
        ),
        errorWidget: (_, __, ___) => Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade200,
          child: Icon(Icons.person, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

/// Petit badge pill-shape pour les spécialités / certifications.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
