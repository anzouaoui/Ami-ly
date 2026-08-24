import 'dart:io';

import 'package:flutter/services.dart';

/// Configuration de la session audio iOS pour Agora RTC.
///
/// Sur iOS, si un autre plugin (sons de notification, lecture audio...)
/// laisse l'AVAudioSession dans une catégorie incompatible avec la capture
/// micro (ex: `playback`), le SDK Agora ne réactive pas toujours la bonne
/// catégorie et le micro reste muet en visio alors que tout le reste semble
/// fonctionner. On force donc explicitement `playAndRecord` + mode
/// `voiceChat` avant de rejoindre le canal (recommandation Agora pour les
/// appels vidéo sur iOS).
///
/// Android n'est pas concerné (gestion AudioManager interne du SDK), la
/// fonction est un no-op hors iOS.
Future<void> configureAudioSessionForVideoCall() async {
  if (!Platform.isIOS) return;

  const channel = MethodChannel('com.app.amily/audio_session');
  try {
    await channel.invokeMethod<void>('configurePlayAndRecord');
  } on PlatformException catch (_) {
    // Un échec de configuration ne doit jamais empêcher l'appel : le SDK
    // Agora retente sa propre configuration à joinChannel.
  }
}
