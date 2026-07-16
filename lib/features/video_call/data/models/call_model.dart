import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/call.dart';

class CallModel {
  const CallModel({
    required this.id,
    required this.channelName,
    required this.callerId,
    required this.calleeId,
    required this.callerName,
    required this.calleeName,
    required this.status,
    required this.createdAt,
    this.endedAt,
  });

  final String id;
  final String channelName;
  final String callerId;
  final String calleeId;
  final String callerName;
  final String calleeName;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? endedAt;

  factory CallModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return CallModel(
      id: doc.id,
      channelName: d['channelName'] as String? ?? '',
      callerId: d['callerId'] as String? ?? '',
      calleeId: d['calleeId'] as String? ?? '',
      callerName: d['callerName'] as String? ?? '',
      calleeName: d['calleeName'] as String? ?? '',
      status: CallStatus.values.firstWhere(
        (e) => e.name == d['status'],
        orElse: () => CallStatus.ringing,
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endedAt: (d['endedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'channelName': channelName,
        'callerId': callerId,
        'calleeId': calleeId,
        'callerName': callerName,
        'calleeName': calleeName,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        if (endedAt != null) 'endedAt': Timestamp.fromDate(endedAt!),
      };

  Call toEntity() => Call(
        id: id,
        channelName: channelName,
        callerId: callerId,
        calleeId: calleeId,
        callerName: callerName,
        calleeName: calleeName,
        status: status,
        createdAt: createdAt,
        endedAt: endedAt,
      );
}
