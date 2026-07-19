import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/call.dart';
import '../models/call_model.dart';

class VideoCallRemoteDatasource {
  VideoCallRemoteDatasource({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _firestore = firestore,
        _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection('calls');

  /// Crée un document d'appel dans Firestore.
  /// [initialStatus] permet de créer un appel en attente (pending) sans
  /// déclencher le popup d'appel entrant — le statut passe à ringing
  /// uniquement quand un participant clique sur "Rejoindre la visio".
  Future<CallModel> createCall({
    required String callerId,
    required String calleeId,
    required String callerName,
    required String calleeName,
    CallStatus initialStatus = CallStatus.ringing,
  }) async {
    try {
      final docRef = _calls.doc();
      final channelName = docRef.id;
      final call = CallModel(
        id: docRef.id,
        channelName: channelName,
        callerId: callerId,
        calleeId: calleeId,
        callerName: callerName,
        calleeName: calleeName,
        status: initialStatus,
        createdAt: DateTime.now(),
      );
      await docRef.set(call.toFirestore());
      return call;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur création appel');
    }
  }

  /// Met à jour le statut d'un appel.
  Future<void> updateCallStatus(String callId, CallStatus status) async {
    try {
      final update = <String, dynamic>{'status': status.name};
      if (status == CallStatus.ended) {
        update['endedAt'] = Timestamp.now();
      }
      await _calls.doc(callId).update(update);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur mise à jour appel');
    }
  }

  /// Écoute un document d'appel en temps réel.
  Stream<CallModel?> watchCall(String callId) {
    return _calls.doc(callId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return CallModel.fromFirestore(snap);
    });
  }

  /// Récupère un document d'appel (une seule lecture).
  Future<CallModel?> getCallById(String callId) async {
    try {
      final snap = await _calls.doc(callId).get();
      if (!snap.exists) return null;
      return CallModel.fromFirestore(snap);
    } on FirebaseException catch (_) {
      return null;
    }
  }

  /// Écoute les appels entrants (calleeId == userId, status == ringing).
  Stream<List<CallModel>> watchIncomingCalls(String userId) {
    return _calls
        .where('calleeId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CallModel.fromFirestore).toList());
  }

  /// Cherche un appel ringing existant entre deux utilisateurs.
  /// Retourne le premier appel ringing trouvé où (callerId == a && calleeId == b)
  /// ou (callerId == b && calleeId == a), ou null sinon.
  Future<CallModel?> findExistingRingingCall(String userA, String userB) async {
    try {
      final snapA = await _calls
          .where('callerId', isEqualTo: userA)
          .where('calleeId', isEqualTo: userB)
          .where('status', isEqualTo: 'ringing')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (snapA.docs.isNotEmpty) {
        return CallModel.fromFirestore(snapA.docs.first);
      }

      final snapB = await _calls
          .where('callerId', isEqualTo: userB)
          .where('calleeId', isEqualTo: userA)
          .where('status', isEqualTo: 'ringing')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (snapB.docs.isNotEmpty) {
        return CallModel.fromFirestore(snapB.docs.first);
      }

      return null;
    } on FirebaseException catch (_) {
      return null;
    }
  }

  /// Appelle la Cloud Function pour obtenir un token Agora signé.
  Future<String> getAgoraToken({
    required String channelName,
    required int uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateAgoraToken');
      final result = await callable.call<Map<String, dynamic>>({
        'channelName': channelName,
        'uid': uid,
      });
      return result.data['token'] as String;
    } on FirebaseFunctionsException catch (e) {
      final msg = e.code == 'not-found'
          ? 'Cloud Function generateAgoraToken non déployée. Lancez: firebase deploy --only functions'
          : e.message ?? 'Erreur génération token Agora';
      throw VideoCallException(msg);
    }
  }
}
