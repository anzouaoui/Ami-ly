import 'package:url_launcher/url_launcher.dart';

/// Service centralisé pour lancer une visioconférence via Jitsi Meet.
///
/// Utilise deep link vers l'app Jitsi Meet si installée,
/// sinon ouvre le lien dans le navigateur.
class VisioService {
  VisioService._();

  static const _baseUrl = 'https://meet.jit.si';

  /// Lance une visioconférence Jitsi.
  ///
  /// [conversationId] sert de nom de room (format : `{parentUid}_{assmatUid}`).
  static Future<void> joinVisio({
    required String conversationId,
    required String userName,
  }) async {
    final roomUrl = Uri.parse('$_baseUrl/$conversationId');

    // Tente d'ouvrir l'app Jitsi Meet via deep link
    final appUri = Uri.parse('org.jitsi.meet://$_baseUrl/$conversationId');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback : ouvre dans le navigateur
    if (await canLaunchUrl(roomUrl)) {
      await launchUrl(roomUrl, mode: LaunchMode.externalApplication);
    }
  }
}
