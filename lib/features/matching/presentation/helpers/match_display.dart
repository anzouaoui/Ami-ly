/// Ville d'une adresse complète : dernier segment après une virgule.
/// `'12 rue X, Lyon'` → `'Lyon'`, `''` → `''`.
String cityFromAddress(String address) {
  if (address.isEmpty) return '';
  return address.split(',').last.trim();
}

/// Nom affiché d'une assmat : son prénom, ou un libellé générique.
String assmatDisplayName(String firstName) =>
    firstName.isNotEmpty ? firstName : 'Assistante maternelle';

/// Initiale du prénom en majuscule, ou `?`.
String firstNameInitial(String firstName) =>
    firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
