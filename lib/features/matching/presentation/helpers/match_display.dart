/// Ville d'une adresse complète : dernier segment après une virgule.
/// `'12 rue X, Lyon'` → `'Lyon'`, `''` → `''`.
String cityFromAddress(String address) {
  if (address.isEmpty) return '';
  return address.split(',').last.trim();
}
