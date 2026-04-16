/// Rôles des utilisateurs d'Ami-ly.
///
/// - [parent] : parent cherchant une assistante maternelle.
/// - [assmat] : assistante maternelle (agréée) proposant ses services.
///
/// Stocké dans Firestore sous `users/{uid}.role` avec la valeur [name]
/// (`"parent"` ou `"assmat"`).
enum UserRole {
  parent,
  assmat;

  /// Parse une valeur Firestore en [UserRole], ou `null` si invalide.
  static UserRole? fromString(String? value) {
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => throw ArgumentError('Rôle inconnu : $value'),
    );
  }

  String get label {
    switch (this) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.assmat:
        return 'Assistante Maternelle';
    }
  }
}
