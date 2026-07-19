import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/call.dart';

abstract class VideoCallRepository {
  /// Crée un appel et retourne le document créé.
  Future<Either<Failure, Call>> startCall({
    required String callerId,
    required String calleeId,
    required String callerName,
    required String calleeName,
  });

  /// Met à jour le statut de l'appel à 'accepted'.
  Future<Either<Failure, void>> acceptCall(String callId);

  /// Met à jour le statut de l'appel à 'ended'.
  Future<Either<Failure, void>> endCall(String callId);

  /// Écoute les changements d'un document d'appel spécifique.
  Stream<Call?> watchCall(String callId);

  /// Écoute les appels entrants pour un utilisateur donné.
  Stream<List<Call>> watchIncomingCalls(String userId);

  /// Cherche un appel ringing existant entre deux utilisateurs.
  Future<Either<Failure, Call?>> findExistingRingingCall(String userA, String userB);

  /// Récupère un appel par son ID (une seule lecture, pas un stream).
  Future<Either<Failure, Call?>> getCallById(String callId);

  /// Récupère un token Agora signé depuis la Cloud Function.
  Future<Either<Failure, String>> getAgoraToken({
    required String channelName,
    required int uid,
  });
}
