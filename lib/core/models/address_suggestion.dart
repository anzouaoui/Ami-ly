/// Suggestion d'adresse retournée par l'API BAN (Base Adresse Nationale).
class AddressSuggestion {
  const AddressSuggestion({
    required this.label,
    required this.lat,
    required this.lon,
    this.city,
  });

  final String label;
  final double lat;
  final double lon;

  /// Ville extraite du champ `city` de l'API BAN (ex: "Paris").
  final String? city;
}
