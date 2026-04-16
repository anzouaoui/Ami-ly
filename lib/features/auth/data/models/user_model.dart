import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/models/user_role.dart';
import '../../domain/entities/app_user.dart';

/// Modèle data : sait parler Firestore.
///
/// Garde l'entité [AppUser] du domaine propre et testable.
class UserModel {
  const UserModel({
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
  final bool isProfileComplete;
  final bool isPro;

  /// Construit un [UserModel] depuis un document Firestore `users/{uid}`.
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Document utilisateur ${doc.id} introuvable.');
    }

    final roleStr = data['role'] as String?;
    final role = UserRole.fromString(roleStr);
    if (role == null) {
      throw StateError('Rôle manquant ou invalide pour ${doc.id}.');
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: role,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      isProfileComplete: data['isProfileComplete'] as bool? ?? false,
      isPro: data['isPro'] as bool? ?? false,
    );
  }

  /// Payload pour créer / mettre à jour un document Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isProfileComplete': isProfileComplete,
      'isPro': isPro,
    };
  }

  /// Convertit vers l'entité domaine (utilisée par la couche presentation).
  AppUser toEntity() => AppUser(
        uid: uid,
        email: email,
        role: role,
        createdAt: createdAt,
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        isProfileComplete: isProfileComplete,
        isPro: isPro,
      );
}
