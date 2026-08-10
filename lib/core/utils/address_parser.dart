/// Adresse découpée en composants structurés.
///
/// - [street] : la voie seule (numéro + nom de rue), sans ville ni CP.
/// - [postalCode] : code postal (5 chiffres), vide s'il n'est pas trouvé.
/// - [city] : la ville, vide si non trouvée.
typedef ParsedAddress = ({String street, String postalCode, String city});

/// Découpe une adresse complète au format BAN standard
/// (`"numéro + voie, code_postal ville"`) en ses composants.
///
/// Exemple : `"25 Avenue Franklin D. Roosevelt, 75008 Paris"` →
/// `(street: "25 Avenue Franklin D. Roosevelt", postalCode: "75008",
/// city: "Paris")`.
///
/// Ne lève jamais d'exception : si le découpage échoue (adresse sans code
/// postal, mal formée...), retourne `street` = adresse complète avec des
/// `postalCode` / `city` vides.
ParsedAddress parseBANAddress(String fullAddress) {
  final trimmed = fullAddress.trim();
  if (trimmed.isEmpty) {
    return (street: '', postalCode: '', city: '');
  }

  final segments = trimmed
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (segments.length < 2) {
    return (street: trimmed, postalCode: '', city: '');
  }

  // Le dernier segment doit suivre le format « code_postal ville »
  // (ex : "75008 Paris"). Sinon, l'adresse n'est pas au format BAN.
  final lastSegment = segments.last;
  final match = RegExp(r'^(\d{5})\s+(.+)$').firstMatch(lastSegment);
  if (match == null) {
    return (street: trimmed, postalCode: '', city: '');
  }

  return (
    street: segments.sublist(0, segments.length - 1).join(', '),
    postalCode: match.group(1)!,
    city: match.group(2)!.trim(),
  );
}
