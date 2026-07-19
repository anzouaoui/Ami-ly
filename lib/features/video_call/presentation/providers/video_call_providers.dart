import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/datasources/video_call_remote_datasource.dart';
import '../../domain/entities/call.dart';
import '../../data/repositories/video_call_repository_impl.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../../domain/usecases/start_call.dart';
import '../../domain/usecases/join_call.dart';
import '../../domain/usecases/end_call.dart';
import '../../domain/usecases/listen_incoming_calls.dart';

// ── DI chain ──────────────────────────────────────────────────────────────

final videoCallDatasourceProvider = Provider<VideoCallRemoteDatasource>((ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return VideoCallRemoteDatasource(
    firestore: firebase.firestore,
    functions: FirebaseFunctions.instanceFor(region: 'europe-west1'),
  );
});

final videoCallRepositoryProvider = Provider<VideoCallRepository>((ref) {
  return VideoCallRepositoryImpl(ref.watch(videoCallDatasourceProvider));
});

final startCallUseCaseProvider = Provider<StartCall>((ref) {
  return StartCall(ref.watch(videoCallRepositoryProvider));
});

final joinCallUseCaseProvider = Provider<JoinCall>((ref) {
  return JoinCall(ref.watch(videoCallRepositoryProvider));
});

final endCallUseCaseProvider = Provider<EndCall>((ref) {
  return EndCall(ref.watch(videoCallRepositoryProvider));
});

final listenIncomingCallsUseCaseProvider = Provider<ListenIncomingCalls>((ref) {
  return ListenIncomingCalls(ref.watch(videoCallRepositoryProvider));
});

// ── Incoming calls stream ─────────────────────────────────────────────────

final incomingCallsProvider = StreamProvider.autoDispose<List<Call>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(listenIncomingCallsUseCaseProvider).call(uid);
});

// ── Call state ────────────────────────────────────────────────────────────

enum CallState { idle, ringing, connected, ended }

class VideoCallState {
  const VideoCallState({
    this.call,
    this.state = CallState.idle,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.remoteUid,
    this.error,
  });

  final Call? call;
  final CallState state;
  final bool isMuted;
  final bool isVideoEnabled;
  final int? remoteUid;
  final String? error;

  VideoCallState copyWith({
    Call? call,
    CallState? state,
    bool? isMuted,
    bool? isVideoEnabled,
    int? remoteUid,
    String? error,
    bool clearError = false,
    bool clearRemoteUid = false,
  }) {
    return VideoCallState(
      call: call ?? this.call,
      state: state ?? this.state,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      remoteUid: clearRemoteUid ? null : (remoteUid ?? this.remoteUid),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class VideoCallController extends Notifier<VideoCallState> {
  @override
  VideoCallState build() => const VideoCallState();

  StreamSubscription<Call?>? _callSubscription;

  /// Démarre un nouvel appel.
  Future<void> startCall({
    required String callerId,
    required String calleeId,
    required String callerName,
    required String calleeName,
  }) async {
    final result = await ref.read(startCallUseCaseProvider).call(
          callerId: callerId,
          calleeId: calleeId,
          callerName: callerName,
          calleeName: calleeName,
        );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (call) {
        state = state.copyWith(call: call, state: CallState.ringing);
        _listenToCall(call.id);
      },
    );
  }

  /// Accepte un appel entrant.
  Future<void> acceptCall(String callId, {Call? callData}) async {
    final result = await ref.read(joinCallUseCaseProvider).call(callId);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        if (callData != null) {
          state = state.copyWith(call: callData, state: CallState.ringing);
        }
        _listenToCall(callId);
      },
    );
  }

  /// Termine l'appel en cours.
  Future<void> endCurrentCall() async {
    final callId = state.call?.id;
    if (callId == null) return;
    await ref.read(endCallUseCaseProvider).call(callId);
    state = state.copyWith(state: CallState.ended);
    _callSubscription?.cancel();
  }

  /// Toggle mute audio.
  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  /// Toggle vidéo.
  void toggleVideo() {
    state = state.copyWith(isVideoEnabled: !state.isVideoEnabled);
  }

  /// Met à jour le remote UID (appelé depuis l'écran vidéo).
  void setRemoteUid(int? uid) {
    state = state.copyWith(
      remoteUid: uid,
      clearRemoteUid: uid == null,
    );
  }

  /// Met à jour l'état vers connected.
  void markConnected() {
    state = state.copyWith(state: CallState.connected);
  }

  /// Réinitialise le controller.
  void reset() {
    _callSubscription?.cancel();
    state = const VideoCallState();
  }

  void _listenToCall(String callId) {
    _callSubscription?.cancel();
    _callSubscription =
        ref.read(videoCallRepositoryProvider).watchCall(callId).listen(
      (call) {
        if (call == null) return;
        final newState = call.status == CallStatus.accepted
            ? CallState.connected
            : call.status == CallStatus.ended
                ? CallState.ended
                : CallState.ringing;
        state = state.copyWith(call: call, state: newState);
      },
    );
  }
}

final videoCallControllerProvider =
    NotifierProvider<VideoCallController, VideoCallState>(
  VideoCallController.new,
);
