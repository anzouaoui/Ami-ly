import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/call.dart';
import '../repositories/video_call_repository.dart';

class StartCall {
  StartCall(this._repository);
  final VideoCallRepository _repository;

  Future<Either<Failure, Call>> call({
    required String callerId,
    required String calleeId,
    required String callerName,
    required String calleeName,
    CallStatus initialStatus = CallStatus.ringing,
    DateTime? scheduledFor,
  }) {
    return _repository.startCall(
      callerId: callerId,
      calleeId: calleeId,
      callerName: callerName,
      calleeName: calleeName,
      initialStatus: initialStatus,
      scheduledFor: scheduledFor,
    );
  }
}
