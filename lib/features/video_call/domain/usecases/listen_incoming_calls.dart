import '../entities/call.dart';
import '../repositories/video_call_repository.dart';

class ListenIncomingCalls {
  ListenIncomingCalls(this._repository);
  final VideoCallRepository _repository;

  Stream<List<Call>> call(String userId) {
    return _repository.watchIncomingCalls(userId);
  }
}
