import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/models/message_model.dart';

/// Helper pour déclencher les notifications in-app lors d'événements métier.
class NotificationTriggers {
  NotificationTriggers(this._notificationService);

  final NotificationService _notificationService;

  /// Appelé quand un message texte est envoyé dans une conversation.
  Future<void> onMessageSent({
    required String recipientUid,
    required String senderUid,
    required String senderName,
    required String conversationId,
    required String messageText,
  }) async {
    final preview = messageText.length > 80
        ? '${messageText.substring(0, 80)}...'
        : messageText;

    await _notificationService.createNotification(
      recipientUid: recipientUid,
      senderUid: senderUid,
      type: NotificationType.newMessage,
      conversationId: conversationId,
      title: 'Nouveau message de $senderName',
      body: preview,
    );
  }

  /// Appelé quand une proposition de visio est envoyée.
  Future<void> onVisioProposalSent({
    required String recipientUid,
    required String senderUid,
    required String senderName,
    required String conversationId,
    required DateTime visioDate,
    required String visioProposalId,
  }) async {
    final day =
        '${visioDate.day} ${_monthName(visioDate.month)} ${visioDate.year}';
    final hour =
        '${visioDate.hour.toString().padLeft(2, '0')}:${visioDate.minute.toString().padLeft(2, '0')}';

    await _notificationService.createNotification(
      recipientUid: recipientUid,
      senderUid: senderUid,
      type: NotificationType.visioProposalReceived,
      conversationId: conversationId,
      visioProposalId: visioProposalId,
      title: 'Proposition de visio de $senderName',
      body: 'Visio proposée le $day à $hour',
    );
  }

  /// Appelé quand une proposition de visio reçoit une réponse.
  Future<void> onVisioResponse({
    required String recipientUid,
    required String senderUid,
    required String senderName,
    required String conversationId,
    required VisioStatus status,
  }) async {
    final String statusLabel;
    switch (status) {
      case VisioStatus.accepted:
        statusLabel = 'acceptée';
      case VisioStatus.refused:
        statusLabel = 'refusée';
      case VisioStatus.match:
        statusLabel = 'match validé';
      case VisioStatus.rejected:
        statusLabel = 'match refusé';
      case VisioStatus.reflection:
        statusLabel = 'en réflexion';
      case VisioStatus.completed:
        statusLabel = 'terminée';
      default:
        statusLabel = status.name;
    }

    await _notificationService.createNotification(
      recipientUid: recipientUid,
      senderUid: senderUid,
      type: NotificationType.visioProposalResponse,
      conversationId: conversationId,
      title: 'Visio $statusLabel',
      body: "$senderName a $statusLabel la proposition de visio.",
    );
  }

  /// Appelé quand un contrat est signé par une partie.
  Future<void> onContractSigned({
    required String recipientUid,
    required String senderUid,
    required String contractId,
    required bool senderIsParent,
    required String childName,
  }) async {
    final senderLabel =
        senderIsParent ? 'Le parent' : "L'assistante maternelle";

    await _notificationService.createNotification(
      recipientUid: recipientUid,
      senderUid: senderUid,
      type: NotificationType.contractSigned,
      contractId: contractId,
      title: '$senderLabel a signé le contrat',
      body: 'Le contrat pour l\'accueil de $childName a été signé.',
    );
  }

  /// Appelé quand le statut d'un contrat change.
  Future<void> onContractStatusChanged({
    required String recipientUid,
    required String senderUid,
    required String contractId,
    required String newStatus,
    required String childName,
  }) async {
    final String statusLabel;
    switch (newStatus) {
      case 'active':
        statusLabel = 'activé';
      case 'terminated':
        statusLabel = 'résilié';
      case 'pendingParent':
        statusLabel = 'en attente de signature parent';
      case 'pendingAssmat':
        statusLabel = 'en attente de signature assmat';
      default:
        statusLabel = newStatus;
    }

    await _notificationService.createNotification(
      recipientUid: recipientUid,
      senderUid: senderUid,
      type: NotificationType.contractStatusChanged,
      contractId: contractId,
      title: 'Contrat $statusLabel',
      body: 'Le contrat pour l\'accueil de $childName est $statusLabel.',
    );
  }

  String _monthName(int m) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[m - 1];
  }
}

final notificationTriggersProvider = Provider<NotificationTriggers>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationTriggers(notificationService);
});
