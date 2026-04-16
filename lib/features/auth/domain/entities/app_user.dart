import 'package:equatable/equatable.dart';

import '../../../../shared/models/user_role.dart';

/// Entité pure du domaine : un utilisateur Ami-ly.
///
/// Aucune dépendance à Firebase ici (c'est l'objectif de la Clean Architecture) :
/// les conversions Firestore <-> AppUser se font dans la couche `data`.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.isProfileComplete = false,
    this.isPro = false,
  });

  final String uid;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;

  /// Onboarding terminé ? (profil rempli, documents uploadés, etc.)
  final bool isProfileComplete;

  /// Abonnement "Ami-ly Pro" actif (géré par RevenueCat, miroir dans Firestore).
  /// Uniquement pertinent pour [UserRole.assmat].
  final bool isPro;

  bool get isParent => role == UserRole.parent;
  bool get isAssMat => role == UserRole.assmat;

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? isProfileComplete,
    bool? isPro,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      role: role,
      createdAt: createdAt,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isPro: isPro ?? this.isPro,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        role,
        createdAt,
        displayName,
        photoUrl,
        phoneNumber,
        isProfileComplete,
        isPro,
      ];
}
