import 'package:equatable/equatable.dart';

enum CallStatus { pending, ringing, accepted, ended }

class Call extends Equatable {
  const Call({
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

  Call copyWith({
    CallStatus? status,
    DateTime? endedAt,
  }) {
    return Call(
      id: id,
      channelName: channelName,
      callerId: callerId,
      calleeId: calleeId,
      callerName: callerName,
      calleeName: calleeName,
      status: status ?? this.status,
      createdAt: createdAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        channelName,
        callerId,
        calleeId,
        callerName,
        calleeName,
        status,
        createdAt,
        endedAt,
      ];
}
