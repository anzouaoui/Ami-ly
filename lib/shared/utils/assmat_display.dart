/// Nom affiché d'une assmat : son prénom, ou un libellé générique.
String assmatDisplayName(String firstName) =>
    firstName.isNotEmpty ? firstName : 'Assistante maternelle';

/// Initiale du prénom en majuscule, ou `?`.
String firstNameInitial(String firstName) =>
    firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
