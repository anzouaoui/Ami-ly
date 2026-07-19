import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/call.dart';
import '../providers/video_call_providers.dart';
import '../screens/video_call_screen.dart';

/// Logique partagée pour rejoindre une visio depuis le chat.
///
/// Règle :
///   1. Si [callId] (issu du message Firestore) existe déjà en tant que
///      document `calls/{callId}`, on le rejoint :
///        - Si status == pending → on l'active (pending → ringing) puis on
///          navigue vers l'écran vidéo. L'autre partie verra le popup d'appel
///          entrant et pourra accepter.
///        - Si status == ringing → on l'accepte directement.
///   2. Sinon, on cherche un appel ringing existant entre les deux parties.
///   3. Sinon, on crée un nouvel appel via `startCall` (ringing direct).
///
/// Utilisé par les deux pages chat (parent / assmat) pour éviter la duplication
/// et garantir qu'un seul canal Agora est utilisé pour une même proposition.
Future<void> joinVisioCall({
  required BuildContext context,
  required WidgetRef ref,
  required String convId,
  required String messageId,
  String? callId,
  required String currentUserUid,
  required String currentUserDisplayName,
  required String otherUid,
  required String otherName,
}) async {
  final repository = ref.read(videoCallRepositoryProvider);
  final controller = ref.read(videoCallControllerProvider.notifier);

  try {
    // Cas 1 : un callId est déjà stocké sur le message.
    if (callId != null && callId.isNotEmpty) {
      // Cherche d'abord un appel ringing existant (l'autre partie l'a peut-être déjà activé).
      final existingResult = await repository.findExistingRingingCall(
        currentUserUid,
        otherUid,
      );
      final existingCall = existingResult.fold((_) => null, (c) => c);

      if (existingCall != null && existingCall.id == callId) {
        // L'appel est déjà ringing → on l'accepte.
        await controller.acceptCall(callId, callData: existingCall);
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VideoCallScreen(
                callId: callId,
                convId: convId,
                visioMessageId: messageId,
              ),
            ),
          );
        }
        return;
      }

      // L'appel existe mais est encore pending → on l'active (pending → ringing).
      final callResult = await repository.getCallById(callId);
      final callData = callResult.fold((_) => null, (c) => c);

      if (callData != null && callData.status == CallStatus.pending) {
        await controller.joinPendingCall(callId, callData);
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VideoCallScreen(
                callId: callId,
                convId: convId,
                visioMessageId: messageId,
              ),
            ),
          );
        }
        return;
      }

      // L'appel existe dans un autre état (accepted, ended) → on tente de le rejoindre.
      if (callData != null) {
        await controller.acceptCall(callId, callData: callData);
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VideoCallScreen(
                callId: callId,
                convId: convId,
                visioMessageId: messageId,
              ),
            ),
          );
        }
      }
      return;
    }

    // Cas 2 : pas de callId → cherche un appel ringing existant.
    final existingResult = await repository.findExistingRingingCall(
      currentUserUid,
      otherUid,
    );
    final existingCall = existingResult.fold((_) => null, (c) => c);

    if (existingCall != null) {
      await controller.acceptCall(existingCall.id, callData: existingCall);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoCallScreen(
              callId: existingCall.id,
              convId: convId,
              visioMessageId: messageId,
            ),
          ),
        );
      }
      return;
    }

    // Cas 3 : rien trouvé → crée un nouvel appel (ringing direct).
    await controller.startCall(
      callerId: currentUserUid,
      calleeId: otherUid,
      callerName: currentUserDisplayName,
      calleeName: otherName,
    );
    final newCallId = ref.read(videoCallControllerProvider).call?.id;
    if (newCallId != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            callId: newCallId,
            convId: convId,
            visioMessageId: messageId,
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer la visio : $e')),
      );
    }
  }
}
