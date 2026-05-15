import 'package:cloud_firestore/cloud_firestore.dart';

/// Document `conversations/{convId}/messages/{msgId}`.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.sentAt,
    this.readAt,
  });

  final String id;
  final String senderUid;
  final String text;
  final DateTime sentAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return MessageModel(
      id: doc.id,
      senderUid: d['senderUid'] as String? ?? '',
      text: d['text'] as String? ?? '',
      sentAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (d['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderUid': senderUid,
        'text': text,
        'sentAt': Timestamp.fromDate(sentAt),
        if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      };
}
