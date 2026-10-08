/// Initiales (au plus 2) d'un nom : première lettre en majuscule des deux
/// premiers mots non vides. `initialsOf('marie  dupont')` → `MD`,
/// `initialsOf('')` → `''`.
String initialsOf(String name) => name
    .split(' ')
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();
