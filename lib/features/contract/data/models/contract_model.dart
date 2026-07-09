import 'package:cloud_firestore/cloud_firestore.dart';
import 'contract_form_data.dart';

enum ContractStatus { draft, pendingParent, pendingAssmat, signed, active, terminated }

class ContractModel {
  ContractModel({
    required this.id,
    required this.parentUid,
    required this.assmatUid,
    this.status = ContractStatus.draft,
    this.pdfUrl,
    this.pdfHash,
    this.parentSignedAt,
    this.assmatSignedAt,
    this.parentSignatureIp,
    this.assmatSignatureIp,
    this.parentSignedName,
    this.assmatSignedName,
    this.contractData,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String parentUid;
  final String assmatUid;
  final ContractStatus status;
  final String? pdfUrl;
  final String? pdfHash;
  final DateTime? parentSignedAt;
  final DateTime? assmatSignedAt;
  final String? parentSignatureIp;
  final String? assmatSignatureIp;
  final String? parentSignedName;
  final String? assmatSignedName;
  final ContractFormData? contractData;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContractModel copyWith({
    String? id,
    String? parentUid,
    String? assmatUid,
    ContractStatus? status,
    String? pdfUrl,
    String? pdfHash,
    DateTime? parentSignedAt,
    DateTime? assmatSignedAt,
    String? parentSignatureIp,
    String? assmatSignatureIp,
    String? parentSignedName,
    String? assmatSignedName,
    ContractFormData? contractData,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearPdfUrl = false,
    bool clearPdfHash = false,
    bool clearParentSignedAt = false,
    bool clearAssmatSignedAt = false,
    bool clearParentSignatureIp = false,
    bool clearAssmatSignatureIp = false,
    bool clearParentSignedName = false,
    bool clearAssmatSignedName = false,
  }) {
    return ContractModel(
      id: id ?? this.id,
      parentUid: parentUid ?? this.parentUid,
      assmatUid: assmatUid ?? this.assmatUid,
      status: status ?? this.status,
      pdfUrl: clearPdfUrl ? null : (pdfUrl ?? this.pdfUrl),
      pdfHash: clearPdfHash ? null : (pdfHash ?? this.pdfHash),
      parentSignedAt: clearParentSignedAt ? null : (parentSignedAt ?? this.parentSignedAt),
      assmatSignedAt: clearAssmatSignedAt ? null : (assmatSignedAt ?? this.assmatSignedAt),
      parentSignatureIp: clearParentSignatureIp ? null : (parentSignatureIp ?? this.parentSignatureIp),
      assmatSignatureIp: clearAssmatSignatureIp ? null : (assmatSignatureIp ?? this.assmatSignatureIp),
      parentSignedName: clearParentSignedName ? null : (parentSignedName ?? this.parentSignedName),
      assmatSignedName: clearAssmatSignedName ? null : (assmatSignedName ?? this.assmatSignedName),
      contractData: contractData ?? this.contractData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'parentUid': parentUid,
        'assmatUid': assmatUid,
        'status': status.name,
        'pdfUrl': pdfUrl,
        'pdfHash': pdfHash,
        'parentSignedAt': parentSignedAt?.toIso8601String(),
        'assmatSignedAt': assmatSignedAt?.toIso8601String(),
        'parentSignatureIp': parentSignatureIp,
        'assmatSignatureIp': assmatSignatureIp,
        'parentSignedName': parentSignedName,
        'assmatSignedName': assmatSignedName,
        'contractData': contractData?.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ContractModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContractModel(
      id: doc.id,
      parentUid: data['parentUid'] as String,
      assmatUid: data['assmatUid'] as String,
      status: ContractStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ContractStatus.draft,
      ),
      pdfUrl: data['pdfUrl'] as String?,
      pdfHash: data['pdfHash'] as String?,
      parentSignedAt: data['parentSignedAt'] != null
          ? DateTime.parse(data['parentSignedAt'] as String)
          : null,
      assmatSignedAt: data['assmatSignedAt'] != null
          ? DateTime.parse(data['assmatSignedAt'] as String)
          : null,
      parentSignatureIp: data['parentSignatureIp'] as String?,
      assmatSignatureIp: data['assmatSignatureIp'] as String?,
      parentSignedName: data['parentSignedName'] as String?,
      assmatSignedName: data['assmatSignedName'] as String?,
      contractData: data['contractData'] != null
          ? _contractFormDataFromJson(data['contractData'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  static ContractFormData _contractFormDataFromJson(Map<String, dynamic> json) {
    final emp = json['employeur'] as Map<String, dynamic>?;
    final sal = json['salarie'] as Map<String, dynamic>?;
    final enf = json['enfant'] as Map<String, dynamic>?;
    final ctr = json['contrat'] as Map<String, dynamic>?;
    return ContractFormData(
      civiliteEmployeur: emp?['civilite'] as String? ?? '',
      typeEmployeur: emp?['type'] as String? ?? '',
      nomEmployeur: emp?['nom'] as String? ?? '',
      nomNaissanceEmployeur: emp?['nomNaissance'] as String? ?? '',
      nomUsageEmployeur: emp?['nomUsage'] as String? ?? '',
      prenomEmployeur: emp?['prenom'] as String? ?? '',
      adresseEmployeur: emp?['adresse'] as String? ?? '',
      villeEmployeur: emp?['ville'] as String? ?? '',
      cpEmployeur: emp?['cp'] as String? ?? '',
      telEmployeur: emp?['telephone'] as String? ?? '',
      emailEmployeur: emp?['email'] as String? ?? '',
      pajemploiNo: emp?['pajemploiNo'] as String? ?? '',
      idccCode: emp?['idccCode'] as String? ?? '3239',
      civiliteSalarie: sal?['civilite'] as String? ?? '',
      nomSalarie: sal?['nom'] as String? ?? '',
      nomNaissanceSalarie: sal?['nomNaissance'] as String? ?? '',
      nomUsageSalarie: sal?['nomUsage'] as String? ?? '',
      prenomSalarie: sal?['prenom'] as String? ?? '',
      adresseSalarie: sal?['adresse'] as String? ?? '',
      villeSalarie: sal?['ville'] as String? ?? '',
      cpSalarie: sal?['cp'] as String? ?? '',
      telSalarie: sal?['telephone'] as String? ?? '',
      emailSalarie: sal?['email'] as String? ?? '',
      securiteSocialeNo: sal?['securiteSocialeNo'] as String? ?? '',
      agrementRef: sal?['agrementRef'] as String? ?? '',
      agrementDate: sal?['agrementDate'] as String? ?? '',
      assuranceRcPro: sal?['assuranceRcPro'] as String? ?? '',
      assuranceRcProPoliceNo: sal?['assuranceRcProPoliceNo'] as String? ?? '',
      assuranceAuto: sal?['assuranceAuto'] as String? ?? '',
      assuranceAutoPoliceNo: sal?['assuranceAutoPoliceNo'] as String? ?? '',
      childId: enf?['childId'] as String?,
      childFirstName: enf?['prenom'] as String? ?? '',
      nomEnfant: enf?['nom'] as String? ?? '',
      prenomEnfant: enf?['prenomComplet'] as String? ?? '',
      dateNaissanceEnfant: enf?['dateNaissance'] as String? ?? '',
      dateDebut: ctr?['dateDebut'] as String? ?? '',
      dateEmbauche: ctr?['dateEmbauche'] as String? ?? '',
      finContrat: ctr?['finContrat'] as String? ?? '',
      periodeEssai: ctr?['periodeEssai'] as String? ?? '',
      dureeAdaptation: ctr?['dureeAdaptation'] as String? ?? '',
      dateDebutAdaptation: ctr?['dateDebutAdaptation'] as String? ?? '',
      dateFinAdaptation: ctr?['dateFinAdaptation'] as String? ?? '',
      heuresSemaine: ctr?['heuresSemaine'] as String? ?? '',
      heuresMois: ctr?['heuresMois'] as String? ?? '',
      semainesAn: ctr?['semainesAn'] as String? ?? '',
      salaireMensuel: ctr?['salaireMensuel'] as String? ?? '',
      salaireHoraire: ctr?['salaireHoraire'] as String? ?? '',
    );
  }
}
