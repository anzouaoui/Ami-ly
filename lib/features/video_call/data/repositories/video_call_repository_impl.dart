import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/video_call_remote_datasource.dart';
import '../../domain/entities/call.dart';
import '../../domain/repositories/video_call_repository.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  VideoCallRepositoryImpl(this._remote);
  final VideoCallRemoteDatasource _remote;

  @override
  Future<Either<Failure, Call>> startCall({
    required String callerId,
    required String calleeId,
    required String callerName,
    required String calleeName,
    CallStatus initialStatus = CallStatus.ringing,
    DateTime? scheduledFor,
  }) async {
    try {
      final model = await _remote.createCall(
        callerId: callerId,
        calleeId: calleeId,
        callerName: callerName,
        calleeName: calleeName,
        initialStatus: initialStatus,
        scheduledFor: scheduledFor,
      );
      return Right(model.toEntity());
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } on VideoCallException catch (e) {
      return Left(VideoCallFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> acceptCall(String callId) async {
    try {
      await _remote.updateCallStatus(callId, CallStatus.accepted);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> activateCall(String callId) async {
    try {
      await _remote.updateCallStatus(callId, CallStatus.ringing);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> endCall(String callId) async {
    try {
      await _remote.updateCallStatus(callId, CallStatus.ended);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Stream<Call?> watchCall(String callId) {
    return _remote.watchCall(callId).map((model) => model?.toEntity());
  }

  @override
  Stream<List<Call>> watchIncomingCalls(String userId) {
    return _remote
        .watchIncomingCalls(userId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Call?>> findExistingRingingCall(
      String userA, String userB) async {
    try {
      final model = await _remote.findExistingRingingCall(userA, userB);
      return Right(model?.toEntity());
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, Call?>> getCallById(String callId) async {
    try {
      final model = await _remote.getCallById(callId);
      return Right(model?.toEntity());
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, String>> getAgoraToken({
    required String channelName,
    required int uid,
  }) async {
    try {
      final token = await _remote.getAgoraToken(
        channelName: channelName,
        uid: uid,
      );
      return Right(token);
    } on VideoCallException catch (e) {
      return Left(VideoCallFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
