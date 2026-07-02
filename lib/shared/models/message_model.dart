import 'package:cloud_firestore/cloud_firestore.dart';

/// Type de message.
enum MessageType { text, visioProposal }

/// Statut d'une proposition de visio.
enum VisioStatus { pending, accepted, refused }

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
  });

  final String id;
  final String senderUid;
  final String text;
  final DateTime sentAt;
  final DateTime? readAt;
  final MessageType type;
  final DateTime? visioDate;
  final VisioStatus? visioStatus;

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
    return MessageModel(
      id: doc.id,
      senderUid: d['senderUid'] as String? ?? '',
      text: d['text'] as String? ?? '',
      sentAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (d['readAt'] as Timestamp?)?.toDate(),
      type: typeStr == 'visio_proposal' ? MessageType.visioProposal : MessageType.text,
      visioDate: (d['visioDate'] as Timestamp?)?.toDate(),
      visioStatus: _parseVisioStatus(d['visioStatus'] as String?),
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
      default:
        return null;
    }
  }

  Map<String, dynamic> toFirestore() => {
        'senderUid': senderUid,
        'text': text,
        'sentAt': Timestamp.fromDate(sentAt),
        if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
        if (type == MessageType.visioProposal) 'type': 'visio_proposal',
        if (visioDate != null) 'visioDate': Timestamp.fromDate(visioDate!),
        if (visioStatus != null) 'visioStatus': visioStatus!.name,
      };
}
