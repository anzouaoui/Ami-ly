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
