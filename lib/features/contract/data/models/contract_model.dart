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
    this.docusignEnvelopeId,
    this.docusignStatus,
    this.finalPdfUrl,
    this.finalPdfPath,
    this.finalizedAt,
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
  final String? docusignEnvelopeId;
  final String? docusignStatus;
  final String? finalPdfUrl;
  final String? finalPdfPath;
  final DateTime? finalizedAt;
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
    String? docusignEnvelopeId,
    String? docusignStatus,
    String? finalPdfUrl,
    String? finalPdfPath,
    DateTime? finalizedAt,
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
    bool clearDocusignEnvelopeId = false,
    bool clearDocusignStatus = false,
    bool clearFinalPdfUrl = false,
    bool clearFinalPdfPath = false,
    bool clearFinalizedAt = false,
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
      docusignEnvelopeId: clearDocusignEnvelopeId ? null : (docusignEnvelopeId ?? this.docusignEnvelopeId),
      docusignStatus: clearDocusignStatus ? null : (docusignStatus ?? this.docusignStatus),
      finalPdfUrl: clearFinalPdfUrl ? null : (finalPdfUrl ?? this.finalPdfUrl),
      finalPdfPath: clearFinalPdfPath ? null : (finalPdfPath ?? this.finalPdfPath),
      finalizedAt: clearFinalizedAt ? null : (finalizedAt ?? this.finalizedAt),
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
        'docusignEnvelopeId': docusignEnvelopeId,
        'docusignStatus': docusignStatus,
        'finalPdfUrl': finalPdfUrl,
        'finalPdfPath': finalPdfPath,
        'finalizedAt': finalizedAt?.toIso8601String(),
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
      parentSignedAt: parseContractDate(data['parentSignedAt']),
      assmatSignedAt: parseContractDate(data['assmatSignedAt']),
      parentSignatureIp: data['parentSignatureIp'] as String?,
      assmatSignatureIp: data['assmatSignatureIp'] as String?,
      parentSignedName: data['parentSignedName'] as String?,
      assmatSignedName: data['assmatSignedName'] as String?,
      docusignEnvelopeId: data['docusignEnvelopeId'] as String?,
      docusignStatus: data['docusignStatus'] as String?,
      finalPdfUrl: data['finalPdfUrl'] as String?,
      finalPdfPath: data['finalPdfPath'] as String?,
      finalizedAt: parseContractDate(data['finalizedAt']),
      contractData: data['contractData'] != null
          ? ContractFormData.fromJson(
              data['contractData'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  /// Parse une date Firestore qui peut être un Timestamp, une String ISO ou
  /// un DateTime.
  static DateTime? parseContractDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
