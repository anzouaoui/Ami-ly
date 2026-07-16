import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/video_call_repository.dart';

class EndCall {
  EndCall(this._repository);
  final VideoCallRepository _repository;

  Future<Either<Failure, void>> call(String callId) {
    return _repository.endCall(callId);
  }
}
