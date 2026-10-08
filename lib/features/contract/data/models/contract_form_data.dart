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
    this.salaireHoraireNet = '',
    this.salaireBrutBaseMajore = '',
    this.salaireNetBaseMajore = '',
    this.tauxHoraireBrutMajore = '',
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
    // Section 4 - Horaires
    this.heuresParSemaine = '',
    this.nombreSemainesAn = '',
    this.delaiPrevenance = '',
    this.planningRemis = false,
    // Section 5 - Rémunération suite
    this.salaireMensuelNet = '',
    this.indemniteEntretienMontant = '',
    this.indemniteEntretienJourHeures = '',
    this.repasFournisParEmployeur = false,
    this.repasMontant = '',
    this.fraisDeplacementKm = '',
    this.paiementJour = '',
    this.pajemploiPlus = false,
    // Section 6 - Repos
    this.reposHebdoJour = '',
    this.reposTravailRemunere = false,
    this.reposTravailRecupere = false,
    // Section 7 - Jours fériés
    this.premierMaiChome = false,
    this.premierMaiTravaille = false,
    this.jfTravaille1erJanvier = false,
    this.jfTravailleVendrediSaint = false,
    this.jfTravailleLundiPaques = false,
    this.jfTravaille8Mai = false,
    this.jfTravailleAscension = false,
    this.jfTravailleLundiPentecote = false,
    this.jfTravailleAbolition = false,
    this.jfTravaille14Juillet = false,
    this.jfTravaille15Aout = false,
    this.jfTravaille1erNovembre = false,
    this.jfTravaille11Novembre = false,
    this.jfTravaille25Decembre = false,
    this.jfTravaille26Decembre = false,
    this.jfMajoration = '',
    // Section 8 - Congés
    this.congesVersement = '',
    // Section 10 - Conditions
    this.conditionsParticulieres = '',
    // Signature
    this.faitA = '',
    this.faitLe = '',
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
  final String salaireHoraireNet;
  final String salaireBrutBaseMajore;
  final String salaireNetBaseMajore;
  final String tauxHoraireBrutMajore;

  final String nomEnfant;
  final String prenomEnfant;
  final String dateNaissanceEnfant;
  final String dateEmbauche;
  final String finContrat;
  final String periodeEssai;
  final String dureeAdaptation;
  final String dateDebutAdaptation;
  final String dateFinAdaptation;

  // Section 4
  final String heuresParSemaine;
  final String nombreSemainesAn;
  final String delaiPrevenance;
  final bool planningRemis;

  // Section 5
  final String salaireMensuelNet;
  final String indemniteEntretienMontant;
  final String indemniteEntretienJourHeures;
  final bool repasFournisParEmployeur;
  final String repasMontant;
  final String fraisDeplacementKm;
  final String paiementJour;
  final bool pajemploiPlus;

  // Section 6
  final String reposHebdoJour;
  final bool reposTravailRemunere;
  final bool reposTravailRecupere;

  // Section 7
  final bool premierMaiChome;
  final bool premierMaiTravaille;
  final bool jfTravaille1erJanvier;
  final bool jfTravailleVendrediSaint;
  final bool jfTravailleLundiPaques;
  final bool jfTravaille8Mai;
  final bool jfTravailleAscension;
  final bool jfTravailleLundiPentecote;
  final bool jfTravailleAbolition;
  final bool jfTravaille14Juillet;
  final bool jfTravaille15Aout;
  final bool jfTravaille1erNovembre;
  final bool jfTravaille11Novembre;
  final bool jfTravaille25Decembre;
  final bool jfTravaille26Decembre;
  final String jfMajoration;

  // Section 8
  final String congesVersement;

  // Section 10
  final String conditionsParticulieres;

  // Signature
  final String faitA;
  final String faitLe;

  /// Inverse de [toJson]. Les champs absents prennent une valeur vide
  /// (`''` / `false`), sauf [idccCode] qui vaut `'3239'` par défaut.
  factory ContractFormData.fromJson(Map<String, dynamic> json) {
    final employeur = json['employeur'] as Map<String, dynamic>?;
    final salarie = json['salarie'] as Map<String, dynamic>?;
    final enfant = json['enfant'] as Map<String, dynamic>?;
    final contrat = json['contrat'] as Map<String, dynamic>?;
    return ContractFormData(
      civiliteEmployeur: employeur?['civilite'] as String? ?? '',
      typeEmployeur: employeur?['type'] as String? ?? '',
      nomEmployeur: employeur?['nom'] as String? ?? '',
      nomNaissanceEmployeur: employeur?['nomNaissance'] as String? ?? '',
      nomUsageEmployeur: employeur?['nomUsage'] as String? ?? '',
      prenomEmployeur: employeur?['prenom'] as String? ?? '',
      adresseEmployeur: employeur?['adresse'] as String? ?? '',
      villeEmployeur: employeur?['ville'] as String? ?? '',
      cpEmployeur: employeur?['cp'] as String? ?? '',
      telEmployeur: employeur?['telephone'] as String? ?? '',
      emailEmployeur: employeur?['email'] as String? ?? '',
      pajemploiNo: employeur?['pajemploiNo'] as String? ?? '',
      idccCode: employeur?['idccCode'] as String? ?? '3239',
      civiliteSalarie: salarie?['civilite'] as String? ?? '',
      nomSalarie: salarie?['nom'] as String? ?? '',
      nomNaissanceSalarie: salarie?['nomNaissance'] as String? ?? '',
      nomUsageSalarie: salarie?['nomUsage'] as String? ?? '',
      prenomSalarie: salarie?['prenom'] as String? ?? '',
      adresseSalarie: salarie?['adresse'] as String? ?? '',
      villeSalarie: salarie?['ville'] as String? ?? '',
      cpSalarie: salarie?['cp'] as String? ?? '',
      telSalarie: salarie?['telephone'] as String? ?? '',
      emailSalarie: salarie?['email'] as String? ?? '',
      securiteSocialeNo: salarie?['securiteSocialeNo'] as String? ?? '',
      agrementRef: salarie?['agrementRef'] as String? ?? '',
      agrementDate: salarie?['agrementDate'] as String? ?? '',
      assuranceRcPro: salarie?['assuranceRcPro'] as String? ?? '',
      assuranceRcProPoliceNo: salarie?['assuranceRcProPoliceNo'] as String? ?? '',
      assuranceAuto: salarie?['assuranceAuto'] as String? ?? '',
      assuranceAutoPoliceNo: salarie?['assuranceAutoPoliceNo'] as String? ?? '',
      childId: enfant?['childId'] as String?,
      childFirstName: enfant?['prenom'] as String? ?? '',
      nomEnfant: enfant?['nom'] as String? ?? '',
      prenomEnfant: enfant?['prenomComplet'] as String? ?? '',
      dateNaissanceEnfant: enfant?['dateNaissance'] as String? ?? '',
      dateDebut: contrat?['dateDebut'] as String? ?? '',
      dateEmbauche: contrat?['dateEmbauche'] as String? ?? '',
      finContrat: contrat?['finContrat'] as String? ?? '',
      periodeEssai: contrat?['periodeEssai'] as String? ?? '',
      dureeAdaptation: contrat?['dureeAdaptation'] as String? ?? '',
      dateDebutAdaptation: contrat?['dateDebutAdaptation'] as String? ?? '',
      dateFinAdaptation: contrat?['dateFinAdaptation'] as String? ?? '',
      heuresSemaine: contrat?['heuresSemaine'] as String? ?? '',
      heuresMois: contrat?['heuresMois'] as String? ?? '',
      semainesAn: contrat?['semainesAn'] as String? ?? '',
      salaireMensuel: contrat?['salaireMensuel'] as String? ?? '',
      salaireHoraire: contrat?['salaireHoraire'] as String? ?? '',
      salaireHoraireNet: contrat?['salaireHoraireNet'] as String? ?? '',
      salaireBrutBaseMajore: contrat?['salaireBrutBaseMajore'] as String? ?? '',
      salaireNetBaseMajore: contrat?['salaireNetBaseMajore'] as String? ?? '',
      tauxHoraireBrutMajore: contrat?['tauxHoraireBrutMajore'] as String? ?? '',
      heuresParSemaine: contrat?['heuresParSemaine'] as String? ?? '',
      nombreSemainesAn: contrat?['nombreSemainesAn'] as String? ?? '',
      delaiPrevenance: contrat?['delaiPrevenance'] as String? ?? '',
      planningRemis: contrat?['planningRemis'] as bool? ?? false,
      salaireMensuelNet: contrat?['salaireMensuelNet'] as String? ?? '',
      indemniteEntretienMontant: contrat?['indemniteEntretienMontant'] as String? ?? '',
      indemniteEntretienJourHeures: contrat?['indemniteEntretienJourHeures'] as String? ?? '',
      repasFournisParEmployeur: contrat?['repasFournisParEmployeur'] as bool? ?? false,
      repasMontant: contrat?['repasMontant'] as String? ?? '',
      fraisDeplacementKm: contrat?['fraisDeplacementKm'] as String? ?? '',
      paiementJour: contrat?['paiementJour'] as String? ?? '',
      pajemploiPlus: contrat?['pajemploiPlus'] as bool? ?? false,
      reposHebdoJour: contrat?['reposHebdoJour'] as String? ?? '',
      reposTravailRemunere: contrat?['reposTravailRemunere'] as bool? ?? false,
      reposTravailRecupere: contrat?['reposTravailRecupere'] as bool? ?? false,
      premierMaiChome: contrat?['premierMaiChome'] as bool? ?? false,
      premierMaiTravaille: contrat?['premierMaiTravaille'] as bool? ?? false,
      jfTravaille1erJanvier: contrat?['jfTravaille1erJanvier'] as bool? ?? false,
      jfTravailleVendrediSaint: contrat?['jfTravailleVendrediSaint'] as bool? ?? false,
      jfTravailleLundiPaques: contrat?['jfTravailleLundiPaques'] as bool? ?? false,
      jfTravaille8Mai: contrat?['jfTravaille8Mai'] as bool? ?? false,
      jfTravailleAscension: contrat?['jfTravailleAscension'] as bool? ?? false,
      jfTravailleLundiPentecote: contrat?['jfTravailleLundiPentecote'] as bool? ?? false,
      jfTravailleAbolition: contrat?['jfTravailleAbolition'] as bool? ?? false,
      jfTravaille14Juillet: contrat?['jfTravaille14Juillet'] as bool? ?? false,
      jfTravaille15Aout: contrat?['jfTravaille15Aout'] as bool? ?? false,
      jfTravaille1erNovembre: contrat?['jfTravaille1erNovembre'] as bool? ?? false,
      jfTravaille11Novembre: contrat?['jfTravaille11Novembre'] as bool? ?? false,
      jfTravaille25Decembre: contrat?['jfTravaille25Decembre'] as bool? ?? false,
      jfTravaille26Decembre: contrat?['jfTravaille26Decembre'] as bool? ?? false,
      jfMajoration: contrat?['jfMajoration'] as String? ?? '',
      congesVersement: contrat?['congesVersement'] as String? ?? '',
      conditionsParticulieres: contrat?['conditionsParticulieres'] as String? ?? '',
      faitA: contrat?['faitA'] as String? ?? '',
      faitLe: contrat?['faitLe'] as String? ?? '',
    );
  }

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
          'salaireHoraireNet': salaireHoraireNet,
          'salaireBrutBaseMajore': salaireBrutBaseMajore,
          'salaireNetBaseMajore': salaireNetBaseMajore,
          'tauxHoraireBrutMajore': tauxHoraireBrutMajore,
          'heuresParSemaine': heuresParSemaine,
          'nombreSemainesAn': nombreSemainesAn,
          'delaiPrevenance': delaiPrevenance,
          'planningRemis': planningRemis,
          'salaireMensuelNet': salaireMensuelNet,
          'indemniteEntretienMontant': indemniteEntretienMontant,
          'indemniteEntretienJourHeures': indemniteEntretienJourHeures,
          'repasFournisParEmployeur': repasFournisParEmployeur,
          'repasMontant': repasMontant,
          'fraisDeplacementKm': fraisDeplacementKm,
          'paiementJour': paiementJour,
          'pajemploiPlus': pajemploiPlus,
          'reposHebdoJour': reposHebdoJour,
          'reposTravailRemunere': reposTravailRemunere,
          'reposTravailRecupere': reposTravailRecupere,
          'premierMaiChome': premierMaiChome,
          'premierMaiTravaille': premierMaiTravaille,
          'jfTravaille1erJanvier': jfTravaille1erJanvier,
          'jfTravailleVendrediSaint': jfTravailleVendrediSaint,
          'jfTravailleLundiPaques': jfTravailleLundiPaques,
          'jfTravaille8Mai': jfTravaille8Mai,
          'jfTravailleAscension': jfTravailleAscension,
          'jfTravailleLundiPentecote': jfTravailleLundiPentecote,
          'jfTravailleAbolition': jfTravailleAbolition,
          'jfTravaille14Juillet': jfTravaille14Juillet,
          'jfTravaille15Aout': jfTravaille15Aout,
          'jfTravaille1erNovembre': jfTravaille1erNovembre,
          'jfTravaille11Novembre': jfTravaille11Novembre,
          'jfTravaille25Decembre': jfTravaille25Decembre,
          'jfTravaille26Decembre': jfTravaille26Decembre,
          'jfMajoration': jfMajoration,
          'congesVersement': congesVersement,
          'conditionsParticulieres': conditionsParticulieres,
          'faitA': faitA,
          'faitLe': faitLe,
        },
      };
}
