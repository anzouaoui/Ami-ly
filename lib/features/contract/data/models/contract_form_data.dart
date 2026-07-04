class ContractFormData {
  ContractFormData({
    // Employeur
    this.civiliteEmployeur = 'M.',
    this.typeEmployeur = 'Père',
    this.nomEmployeur = '',
    this.prenomEmployeur = '',
    this.adresseEmployeur = '',
    this.villeEmployeur = '',
    this.cpEmployeur = '',
    this.telEmployeur = '',
    this.emailEmployeur = '',
    // Salarié
    this.civiliteSalarie = 'Mme',
    this.nomSalarie = '',
    this.prenomSalarie = '',
    this.adresseSalarie = '',
    this.villeSalarie = '',
    this.cpSalarie = '',
    this.telSalarie = '',
    this.emailSalarie = '',
    // Enfant
    this.childId,
    this.childFirstName = '',
    // Condition d'accueil
    this.dateDebut = '',
    this.heuresSemaine = '',
    this.heuresMois = '',
    this.semainesAn = '',
    this.salaireMensuel = '',
    this.salaireHoraire = '',
    // Contrat (Step 4)
    this.nomEnfant = '',
    this.prenomEnfant = '',
    this.dateNaissanceEnfant = '',
    this.dateEmbauche = '',
    this.finContrat = '',
    this.periodeEssai = '',
  });

  final String civiliteEmployeur;
  final String typeEmployeur;
  final String nomEmployeur;
  final String prenomEmployeur;
  final String adresseEmployeur;
  final String villeEmployeur;
  final String cpEmployeur;
  final String telEmployeur;
  final String emailEmployeur;

  final String civiliteSalarie;
  final String nomSalarie;
  final String prenomSalarie;
  final String adresseSalarie;
  final String villeSalarie;
  final String cpSalarie;
  final String telSalarie;
  final String emailSalarie;

  final String? childId;
  final String childFirstName;

  final String dateDebut;
  final String heuresSemaine;
  final String heuresMois;
  final String semainesAn;
  final String salaireMensuel;
  final String salaireHoraire;

  final String nomEnfant;
  final String prenomEnfant;
  final String dateNaissanceEnfant;
  final String dateEmbauche;
  final String finContrat;
  final String periodeEssai;

  Map<String, dynamic> toJson() => {
        'employeur': {
          'civilite': civiliteEmployeur,
          'type': typeEmployeur,
          'nom': nomEmployeur,
          'prenom': prenomEmployeur,
          'adresse': adresseEmployeur,
          'ville': villeEmployeur,
          'cp': cpEmployeur,
          'telephone': telEmployeur,
          'email': emailEmployeur,
        },
        'salarie': {
          'civilite': civiliteSalarie,
          'nom': nomSalarie,
          'prenom': prenomSalarie,
          'adresse': adresseSalarie,
          'ville': villeSalarie,
          'cp': cpSalarie,
          'telephone': telSalarie,
          'email': emailSalarie,
        },
        'enfant': {
          'childId': childId,
          'prenom': childFirstName,
          'nom': nomEnfant,
          'prenomComplet': prenomEnfant,
          'dateNaissance': dateNaissanceEnfant,
        },
        'contrat': {
          'dateDebut': dateDebut,
          'dateEmbauche': dateEmbauche,
          'finContrat': finContrat,
          'periodeEssai': periodeEssai,
          'heuresSemaine': heuresSemaine,
          'heuresMois': heuresMois,
          'semainesAn': semainesAn,
          'salaireMensuel': salaireMensuel,
          'salaireHoraire': salaireHoraire,
        },
      };
}
