import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newMessage,
  contractSignatureRequest,
  contractSigned,
  contractStatusChanged,
  visioProposalReceived,
  visioProposalResponse,
  childAdded,
  availabilityUpdated,
}

enum NotificationPriority { low, medium, high }

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.recipientUid,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.senderUid,
    this.contractId,
    this.conversationId,
    this.visioProposalId,
    this.metadata,
  });

  final String id;
  final String recipientUid;
  final NotificationType type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final String? senderUid;
  final String? contractId;
  final String? conversationId;
  final String? visioProposalId;
  final Map<String, dynamic>? metadata;

  /// Priorité dérivée du type — controls push vs in-app only.
  static NotificationPriority priorityOf(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
      case NotificationType.contractSignatureRequest:
      case NotificationType.contractSigned:
      case NotificationType.visioProposalReceived:
      case NotificationType.visioProposalResponse:
        return NotificationPriority.high;
      case NotificationType.contractStatusChanged:
        return NotificationPriority.medium;
      case NotificationType.childAdded:
      case NotificationType.availabilityUpdated:
        return NotificationPriority.low;
    }
  }

  /// Label humain pour le type (utile pour le filtrage UI).
  static String labelOf(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
        return 'Message';
      case NotificationType.contractSignatureRequest:
        return 'Signature';
      case NotificationType.contractSigned:
        return 'Contrat';
      case NotificationType.contractStatusChanged:
        return 'Contrat';
      case NotificationType.visioProposalReceived:
        return 'Visio';
      case NotificationType.visioProposalResponse:
        return 'Visio';
      case NotificationType.childAdded:
        return 'Enfant';
      case NotificationType.availabilityUpdated:
        return 'Disponibilité';
    }
  }

  /// Icône Material pour le type.
  static String iconOf(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
        return 'mail_outline';
      case NotificationType.contractSignatureRequest:
      case NotificationType.contractSigned:
      case NotificationType.contractStatusChanged:
        return 'assignment_outlined';
      case NotificationType.visioProposalReceived:
      case NotificationType.visioProposalResponse:
        return 'videocam_outlined';
      case NotificationType.childAdded:
        return 'child_care_outlined';
      case NotificationType.availabilityUpdated:
        return 'schedule_outlined';
    }
  }

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      recipientUid: d['recipientUid'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => NotificationType.newMessage,
      ),
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      read: d['read'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      senderUid: d['senderUid'] as String?,
      contractId: d['contractId'] as String?,
      conversationId: d['conversationId'] as String?,
      visioProposalId: d['visioProposalId'] as String?,
      metadata: d['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'recipientUid': recipientUid,
        'type': type.name,
        'title': title,
        'body': body,
        'read': read,
        'createdAt': Timestamp.fromDate(createdAt),
        if (senderUid != null) 'senderUid': senderUid,
        if (contractId != null) 'contractId': contractId,
        if (conversationId != null) 'conversationId': conversationId,
        if (visioProposalId != null) 'visioProposalId': visioProposalId,
        if (metadata != null) 'metadata': metadata,
      };

  NotificationModel copyWith({
    String? id,
    String? recipientUid,
    NotificationType? type,
    String? title,
    String? body,
    bool? read,
    DateTime? createdAt,
    String? senderUid,
    String? contractId,
    String? conversationId,
    String? visioProposalId,
    Map<String, dynamic>? metadata,
    bool clearSenderUid = false,
    bool clearContractId = false,
    bool clearConversationId = false,
    bool clearVisioProposalId = false,
    bool clearMetadata = false,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientUid: recipientUid ?? this.recipientUid,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      senderUid: clearSenderUid ? null : (senderUid ?? this.senderUid),
      contractId: clearContractId ? null : (contractId ?? this.contractId),
      conversationId:
          clearConversationId ? null : (conversationId ?? this.conversationId),
      visioProposalId: clearVisioProposalId
          ? null
          : (visioProposalId ?? this.visioProposalId),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
    );
  }
}
