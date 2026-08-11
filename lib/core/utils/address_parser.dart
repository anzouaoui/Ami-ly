/// Adresse découpée en composants structurés.
///
/// - [street] : la voie seule (numéro + nom de rue), sans ville ni CP.
/// - [postalCode] : code postal (5 chiffres), vide s'il n'est pas trouvé.
/// - [city] : la ville, vide si non trouvée.
typedef ParsedAddress = ({String street, String postalCode, String city});

/// Découpe une adresse complète au format BAN standard en ses composants.
///
/// Deux formats sont gérés, le code postal (5 chiffres) précédant toujours
/// la ville :
/// - label BAN : `"25 Avenue Franklin D. Roosevelt 75008 Paris"` ;
/// - avec virgule : `"25 Avenue Franklin D. Roosevelt, 75008 Paris"`.
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

  // On cherche la dernière occurrence d'un code postal à 5 chiffres suivie
  // d'un espace et de la ville (fin de chaîne). La voie = tout ce qui précède.
  final codes = RegExp(r'\b(\d{5})\b').allMatches(trimmed).toList();
  for (final code in codes.reversed) {
    final separator = code.end < trimmed.length ? trimmed[code.end] : '';
    if (separator != ' ' && separator != '\t') continue;
    final city = trimmed.substring(code.end).trim();
    if (city.isEmpty) continue;
    final street = trimmed
        .substring(0, code.start)
        .replaceFirst(RegExp(r'[,;\s]+$'), '')
        .trim();
    return (
      street: street,
      postalCode: code.group(1)!,
      city: city,
    );
  }

  return (street: trimmed, postalCode: '', city: '');
}
