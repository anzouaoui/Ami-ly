class ContractFormData {
  ContractFormData({
    // Employeur
    this.civiliteEmployeur = 'M.',
    this.typeEmployeur = 'Père',
    this.nomEmployeur = '',
    this.nomNaissanceEmployeur = '',
    this.nomUsageEmployeur = '',
    this.prenomEmployeur = '',
    this.adresseEmployeur = '',
    this.villeEmployeur = '',
    this.cpEmployeur = '',
    this.telEmployeur = '',
    this.emailEmployeur = '',
    this.pajemploiNo = '',
    this.idccCode = '3239',
    // Salarié
    this.civiliteSalarie = 'Mme',
    this.nomSalarie = '',
    this.nomNaissanceSalarie = '',
    this.nomUsageSalarie = '',
    this.prenomSalarie = '',
    this.adresseSalarie = '',
    this.villeSalarie = '',
    this.cpSalarie = '',
    this.telSalarie = '',
    this.emailSalarie = '',
    this.securiteSocialeNo = '',
    this.agrementRef = '',
    this.agrementDate = '',
    this.assuranceRcPro = '',
    this.assuranceRcProPoliceNo = '',
    this.assuranceAuto = '',
    this.assuranceAutoPoliceNo = '',
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
    this.dureeAdaptation = '',
    this.dateDebutAdaptation = '',
    this.dateFinAdaptation = '',
  });

  final String civiliteEmployeur;
  final String typeEmployeur;
  final String nomEmployeur;
  final String nomNaissanceEmployeur;
  final String nomUsageEmployeur;
  final String prenomEmployeur;
  final String adresseEmployeur;
  final String villeEmployeur;
  final String cpEmployeur;
  final String telEmployeur;
  final String emailEmployeur;
  final String pajemploiNo;
  final String idccCode;

  final String civiliteSalarie;
  final String nomSalarie;
  final String nomNaissanceSalarie;
  final String nomUsageSalarie;
  final String prenomSalarie;
  final String adresseSalarie;
  final String villeSalarie;
  final String cpSalarie;
  final String telSalarie;
  final String emailSalarie;
  final String securiteSocialeNo;
  final String agrementRef;
  final String agrementDate;
  final String assuranceRcPro;
  final String assuranceRcProPoliceNo;
  final String assuranceAuto;
  final String assuranceAutoPoliceNo;

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
  final String dureeAdaptation;
  final String dateDebutAdaptation;
  final String dateFinAdaptation;

  Map<String, dynamic> toJson() => {
        'employeur': {
          'civilite': civiliteEmployeur,
          'type': typeEmployeur,
          'nom': nomEmployeur,
          'nomNaissance': nomNaissanceEmployeur,
          'nomUsage': nomUsageEmployeur,
          'prenom': prenomEmployeur,
          'adresse': adresseEmployeur,
          'ville': villeEmployeur,
          'cp': cpEmployeur,
          'telephone': telEmployeur,
          'email': emailEmployeur,
          'pajemploiNo': pajemploiNo,
          'idccCode': idccCode,
        },
        'salarie': {
          'civilite': civiliteSalarie,
          'nom': nomSalarie,
          'nomNaissance': nomNaissanceSalarie,
          'nomUsage': nomUsageSalarie,
          'prenom': prenomSalarie,
          'adresse': adresseSalarie,
          'ville': villeSalarie,
          'cp': cpSalarie,
          'telephone': telSalarie,
          'email': emailSalarie,
          'securiteSocialeNo': securiteSocialeNo,
          'agrementRef': agrementRef,
          'agrementDate': agrementDate,
          'assuranceRcPro': assuranceRcPro,
          'assuranceRcProPoliceNo': assuranceRcProPoliceNo,
          'assuranceAuto': assuranceAuto,
          'assuranceAutoPoliceNo': assuranceAutoPoliceNo,
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
          'dureeAdaptation': dureeAdaptation,
          'dateDebutAdaptation': dateDebutAdaptation,
          'dateFinAdaptation': dateFinAdaptation,
          'heuresSemaine': heuresSemaine,
          'heuresMois': heuresMois,
          'semainesAn': semainesAn,
          'salaireMensuel': salaireMensuel,
          'salaireHoraire': salaireHoraire,
        },
      };
}
