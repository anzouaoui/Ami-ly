import 'package:cloud_firestore/cloud_firestore.dart';

/// Type de message.
enum MessageType { text, visioProposal, visioResponse }

/// Statut d'une proposition de visio.
enum VisioStatus { pending, accepted, refused, completed, match, reflection, rejected }

/// Document `conversations/{convId}/messages/{msgId}`.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.sentAt,
    this.readAt,
    this.type = MessageType.text,
    this.visioDate,
    this.visioStatus,
    this.visioProposalId,
    this.reflectionDeadline,
    this.callId,
  });

  final String id;
  final String senderUid;
  final String text;
  final DateTime sentAt;
  final DateTime? readAt;
  final MessageType type;
  final DateTime? visioDate;
  final VisioStatus? visioStatus;
  final String? visioProposalId;
  final DateTime? reflectionDeadline;
  final String? callId;

  bool get isRead => readAt != null;

  bool get isVisioProposal => type == MessageType.visioProposal;

  bool get isVisioAccepted => visioStatus == VisioStatus.accepted;
  bool get isVisioRefused => visioStatus == VisioStatus.refused;
  bool get isVisioPending => visioStatus == VisioStatus.pending;

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    final typeStr = d['type'] as String? ?? 'text';
    final MessageType type;
    switch (typeStr) {
      case 'visio_proposal':
        type = MessageType.visioProposal;
      case 'visio_response':
        type = MessageType.visioResponse;
      default:
        type = MessageType.text;
    }
    return MessageModel(
      id: doc.id,
      senderUid: d['senderUid'] as String? ?? '',
      text: d['text'] as String? ?? '',
      sentAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (d['readAt'] as Timestamp?)?.toDate(),
      type: type,
      visioDate: (d['visioDate'] as Timestamp?)?.toDate(),
      visioStatus: _parseVisioStatus(d['visioStatus'] as String?),
      visioProposalId: d['visioProposalId'] as String?,
      reflectionDeadline: (d['reflectionDeadline'] as Timestamp?)?.toDate(),
      callId: d['callId'] as String?,
    );
  }

  static VisioStatus? _parseVisioStatus(String? s) {
    switch (s) {
      case 'pending':
        return VisioStatus.pending;
      case 'accepted':
        return VisioStatus.accepted;
      case 'refused':
        return VisioStatus.refused;
      case 'completed':
        return VisioStatus.completed;
      case 'match':
        return VisioStatus.match;
      case 'reflection':
        return VisioStatus.reflection;
      case 'rejected':
        return VisioStatus.rejected;
      default:
        return null;
    }
  }

  Map<String, dynamic> toFirestore() => {
        'senderUid': senderUid,
        'text': text,
        'sentAt': Timestamp.fromDate(sentAt),
        if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
        'type': _typeToFirestore(),
        if (visioDate != null) 'visioDate': Timestamp.fromDate(visioDate!),
        if (visioStatus != null) 'visioStatus': visioStatus!.name,
        if (visioProposalId != null) 'visioProposalId': visioProposalId,
        if (reflectionDeadline != null)
          'reflectionDeadline': Timestamp.fromDate(reflectionDeadline!),
        if (callId != null) 'callId': callId,
      };

  String _typeToFirestore() {
    switch (type) {
      case MessageType.visioProposal:
        return 'visio_proposal';
      case MessageType.visioResponse:
        return 'visio_response';
      case MessageType.text:
        return 'text';
    }
  }
}
