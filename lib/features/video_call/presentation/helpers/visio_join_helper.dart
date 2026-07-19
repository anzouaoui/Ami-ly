import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/video_call_providers.dart';
import '../screens/video_call_screen.dart';

/// Logique partagée pour rejoindre une visio depuis le chat.
///
/// Règle :
///   1. Si [callId] (issu du message Firestore) existe déjà, on rejoint cet
///      appel via `acceptCall`.
///   2. Sinon, on cherche un appel ringing existant entre les deux parties.
///   3. Sinon, on crée un nouvel appel via `startCall`.
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
    // Cas 1 : un callId est déjà stocké sur le message → on le rejoint directement.
    if (callId != null && callId.isNotEmpty) {
      final existingResult = await repository.findExistingRingingCall(
        currentUserUid,
        otherUid,
      );
      final existingCall = existingResult.fold((_) => null, (c) => c);

      if (existingCall != null && existingCall.id == callId) {
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

      // Le callId existe sur le message mais l'appel n'est plus ringing :
      // on le récupère par son ID pour passer les données à acceptCall.
      final callResult = await repository.getCallById(callId);
      final callData = callResult.fold((_) => null, (c) => c);
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

    // Cas 3 : rien trouvé → crée un nouvel appel.
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
