import 'dart:async';
import 'package:intl/intl.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:amily/features/auth/presentation/providers/auth_providers.dart';
import '../../../messaging/providers/messaging_providers.dart';
import '../../../notifications/presentation/providers/notification_triggers.dart';
import '../providers/video_call_providers.dart';
import '../widgets/local_video_view.dart';
import '../widgets/remote_video_view.dart';
import '../widgets/call_controls_bar.dart';
import '../../../../shared/models/message_model.dart';

/// Écran principal de visioconférence Agora.
///
/// Reçoit [callId] pour identifier l'appel et rejoindre le bon canal.
/// Optionnellement [convId] et [visioMessageId] pour marquer la visio
/// comme terminée automatiquement quand l'appel se termine.
class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.callId,
    this.convId,
    this.visioMessageId,
  });

  final String callId;
  final String? convId;
  final String? visioMessageId;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  RtcEngine? _engine;
  bool _isLoading = true;
  bool _isDisposing = false;
  String? _error;
  final List<String> _debugLogs = [];

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    final controller = ref.read(videoCallControllerProvider.notifier);
    final call = ref.read(videoCallControllerProvider).call;

    if (call == null) {
      setState(() {
        _error = 'Aucun appel actif.';
        _isLoading = false;
      });
      return;
    }

    // Demande des permissions
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (!camera.isGranted || !mic.isGranted) {
      setState(() {
        _error = 'Permissions caméra/microphone refusées.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Vérifie que l'App ID Agora est configuré
      final appId = const String.fromEnvironment('AGORA_APP_ID', defaultValue: '')
          .replaceAll('"', '')
          .replaceAll("'", '')
          .trim();
      if (appId.isEmpty) {
        setState(() {
          _error = 'AGORA_APP_ID manquant. Lancez avec:\nflutter run --dart-define=AGORA_APP_ID=votre_id';
          _isLoading = false;
        });
        return;
      }

      // Récupère le token Agora
      final uid = ref.read(currentUserProvider).valueOrNull?.uid.hashCode ?? 0;
      final tokenResult = await ref
          .read(videoCallRepositoryProvider)
          .getAgoraToken(channelName: call.channelName, uid: uid);

      String? token;
      tokenResult.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
          return;
        },
        (t) => token = t,
      );
      _addDebugLog(
          'Token recu: ${token != null ? "OK (${token!.length} caracteres)" : "NULL"}');

      if (token == null) return;

      // Initialise le moteur Agora
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      _addDebugLog('Engine initialise');

      // Gestion des événements
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onConnectionStateChanged: (connection, state, reason) {
          _addDebugLog('ConnectionState: $state (reason: $reason)');
        },
        onJoinChannelSuccess: (connection, elapsed) {
          controller.markConnected();
          _addDebugLog(
              'JoinChannelSuccess: elapsed=${elapsed}ms, localUid=${connection.localUid}');
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          controller.setRemoteUid(remoteUid);
          _addDebugLog('UserJoined: remoteUid=$remoteUid');
        },
        onUserOffline: (connection, remoteUid, reason) {
          controller.setRemoteUid(null);
          controller.endCurrentCall();
          _markVisioCompleted();
          if (mounted) Navigator.of(context).pop();
        },
        onError: (errorType, message) {
          setState(() => _error = 'Erreur Agora: $message');
          _addDebugLog('ERROR: $errorType - $message');
        },
        onLeaveChannel: (connection, stats) {
          _addDebugLog('LeaveChannel');
        },
        onTokenPrivilegeWillExpire: (connection, token) {
          _addDebugLog('TokenWillExpire');
        },
      ));
      _addDebugLog('EventHandler enregistre');

      // Active la vidéo et l'audio
      await _engine!.enableVideo();
      _addDebugLog('enableVideo OK');
      await _engine!.enableAudio();
      _addDebugLog('enableAudio OK');
      await _engine!.startPreview();
      _addDebugLog('startPreview OK');

      // Rejoint le canal
      _addDebugLog('Appel joinChannel...');
      _addDebugLog(
          'Tentative join: channel=${call.channelName}, uid=$uid, appId=${appId.substring(0, 8)}...');
      await _engine!.joinChannel(
        token: token!,
        channelId: call.channelName,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
        uid: uid,
      );
      _addDebugLog('joinChannel() resolu (Future terminee)');

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Erreur initialisation: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _disposeAgoraEngine();
    super.dispose();
  }

  Future<void> _disposeAgoraEngine() async {
    if (_isDisposing || _engine == null) return;
    _isDisposing = true;
    final engine = _engine;
    _engine = null;
    try {
      await engine!.leaveChannel();
      await engine.release();
    } catch (_) {}
  }

  Future<void> _toggleMute() async {
    final controller = ref.read(videoCallControllerProvider.notifier);
    controller.toggleMute();
    final isMuted = ref.read(videoCallControllerProvider).isMuted;
    await _engine?.muteLocalAudioStream(isMuted);
  }

  Future<void> _toggleVideo() async {
    final controller = ref.read(videoCallControllerProvider.notifier);
    controller.toggleVideo();
    final isEnabled = ref.read(videoCallControllerProvider).isVideoEnabled;
    await _engine?.muteLocalVideoStream(!isEnabled);
  }

  Future<void> _endCall() async {
    await ref.read(videoCallControllerProvider.notifier).endCurrentCall();
    await _markVisioCompleted();
    await _disposeAgoraEngine();
    if (mounted) Navigator.of(context).pop();
  }

  /// Marque la proposition de visio comme terminée dans la conversation.
  Future<void> _markVisioCompleted() async {
    final convId = widget.convId;
    final visioMessageId = widget.visioMessageId;
    if (convId == null || visioMessageId == null) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final isParent = convId.startsWith(currentUser.uid);
    try {
      await ref.read(messagingDatasourceProvider).respondToVisio(
            convId: convId,
            msgId: visioMessageId,
            status: VisioStatus.completed,
            responderIsParent: isParent,
            responderUid: currentUser.uid,
          );

      final otherUid = isParent ? convId.split('_').last : convId.split('_').first;
      try {
        ref.read(notificationTriggersProvider).onVisioResponse(
              recipientUid: otherUid,
              senderUid: currentUser.uid,
              senderName: currentUser.displayName ?? 'Un participant',
              conversationId: convId,
              status: VisioStatus.completed,
            );
      } catch (_) {}
    } catch (_) {}
  }

  void _addDebugLog(String message) {
    final time = DateFormat('HH:mm:ss').format(DateTime.now());
    setState(() {
      _debugLogs.add('$time - $message');
      if (_debugLogs.length > 15) _debugLogs.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoCallControllerProvider);
    final callerName = videoState.call?.callerName ?? '';
    final calleeName = videoState.call?.calleeName ?? '';
    final calleeId = videoState.call?.calleeId ?? '';
    final currentUid = ref.read(currentUserProvider).valueOrNull?.uid ?? '';
    final remoteName = currentUid == calleeId ? callerName : calleeName;

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                videoState.state == CallState.connected
                    ? remoteName
                    : 'Appel en cours...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Vues vidéo
            Expanded(
              child: Stack(
                children: [
                  // Vidéo distante (plein écran)
                  Positioned.fill(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : RemoteVideoView(
                            engine: _engine!,
                            remoteUid: videoState.remoteUid,
                            channelId: videoState.call?.channelName ?? '',
                          ),
                  ),

                  // Vidéo locale (petite fenêtre)
                  if (!_isLoading && _engine != null)
                    Positioned(
                      right: 16,
                      top: 16,
                      width: 120,
                      height: 160,
                      child: LocalVideoView(
                        engine: _engine!,
                        enabled: videoState.isVideoEnabled,
                      ),
                    ),

                  // Panneau de diagnostic
                  Positioned(
                    left: 8,
                    bottom: 8,
                    width: 280,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: _debugLogs.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final log = _debugLogs[
                              _debugLogs.length - 1 - index];
                          return Text(
                            log,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contrôles
            CallControlsBar(
              state: videoState,
              onToggleMute: _toggleMute,
              onToggleVideo: _toggleVideo,
              onEndCall: _endCall,
            ),
          ],
        ),
      ),
    );
  }
}
