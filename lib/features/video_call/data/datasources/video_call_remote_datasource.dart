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
  Future<CallModel> createCall({
    required String callerId,
    required String calleeId,
    required String callerName,
    required String calleeName,
  }) async {
    try {
      final channelName = '${callerId}_$calleeId}_${DateTime.now().millisecondsSinceEpoch}';
      final docRef = _calls.doc();
      final call = CallModel(
        id: docRef.id,
        channelName: channelName,
        callerId: callerId,
        calleeId: calleeId,
        callerName: callerName,
        calleeName: calleeName,
        status: CallStatus.ringing,
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

  /// Écoute les appels entrants (calleeId == userId, status == ringing).
  Stream<List<CallModel>> watchIncomingCalls(String userId) {
    return _calls
        .where('calleeId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CallModel.fromFirestore).toList());
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
      throw VideoCallException(e.message ?? 'Erreur génération token Agora');
    }
  }
}
