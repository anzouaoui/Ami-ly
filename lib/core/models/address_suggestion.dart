/// Suggestion d'adresse retournée par l'API BAN (Base Adresse Nationale).
class AddressSuggestion {
  const AddressSuggestion({
    required this.label,
    required this.lat,
    required this.lon,
  });

  final String label;
  final double lat;
  final double lon;
}
