import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/video_call_repository.dart';

class JoinCall {
  JoinCall(this._repository);
  final VideoCallRepository _repository;

  Future<Either<Failure, void>> call(String callId) {
    return _repository.acceptCall(callId);
  }
}
