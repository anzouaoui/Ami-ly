import 'package:cloud_firestore/cloud_firestore.dart';

/// Document `conversations/{convId}` — convId = "${parentUid}_${assmatUid}".
///
/// Stocke le résumé de la conversation (dernier message, compteurs de non-lus).
/// La liste complète des messages est dans la sous-collection `messages/`.
class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.parentUid,
    required this.assmatUid,
    required this.parentName,
    required this.assmatName,
    required this.createdAt,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadParent = 0,
    this.unreadAssmat = 0,
  });

  final String id;
  final String parentUid;
  final String assmatUid;
  final String parentName;
  final String assmatName;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadParent;
  final int unreadAssmat;
  final DateTime createdAt;

  /// ID déterministe : évite les doublons, permet un lookup direct.
  static String buildId(String parentUid, String assmatUid) =>
      '${parentUid}_$assmatUid';

  factory ConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return ConversationModel(
      id: doc.id,
      parentUid: d['parentUid'] as String? ?? '',
      assmatUid: d['assmatUid'] as String? ?? '',
      parentName: d['parentName'] as String? ?? '',
      assmatName: d['assmatName'] as String? ?? '',
      lastMessage: d['lastMessage'] as String? ?? '',
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadParent: d['unreadParent'] as int? ?? 0,
      unreadAssmat: d['unreadAssmat'] as int? ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'parentUid': parentUid,
        'assmatUid': assmatUid,
        'parentName': parentName,
        'assmatName': assmatName,
        'lastMessage': lastMessage,
        if (lastMessageAt != null)
          'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
        'unreadParent': unreadParent,
        'unreadAssmat': unreadAssmat,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
