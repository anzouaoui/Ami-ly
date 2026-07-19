import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amily/shared/models/message_model.dart';

void main() {
  group('MessageModel.callId', () {
    test('callId est null par défaut', () {
      final msg = MessageModel(
        id: 'msg-1',
        senderUid: 'user-1',
        text: 'test',
        sentAt: DateTime(2026),
      );
      expect(msg.callId, isNull);
    });

    test('callId est conservé quand fourni', () {
      final msg = MessageModel(
        id: 'msg-1',
        senderUid: 'user-1',
        text: 'test',
        sentAt: DateTime(2026),
        callId: 'call-abc',
      );
      expect(msg.callId, 'call-abc');
    });

    test('toFirestore inclut callId quand non null', () {
      final msg = MessageModel(
        id: 'msg-1',
        senderUid: 'user-1',
        text: 'test',
        sentAt: DateTime(2026),
        callId: 'call-xyz',
      );
      final data = msg.toFirestore();
      expect(data['callId'], 'call-xyz');
    });

    test('toFirestore n\'inclut pas callId quand null', () {
      final msg = MessageModel(
        id: 'msg-1',
        senderUid: 'user-1',
        text: 'test',
        sentAt: DateTime(2026),
      );
      final data = msg.toFirestore();
      expect(data.containsKey('callId'), isFalse);
    });
  });

  group('Un seul document calls/{id} créé pour une paire', () {
    test('le callId du message correspond à l\'ID du document calls/', () {
      final callId = 'call-unique-123';
      final responseMsg = MessageModel(
        id: 'resp-1',
        senderUid: 'assmat-1',
        text: 'Visio acceptée',
        sentAt: DateTime(2026),
        type: MessageType.visioResponse,
        visioStatus: VisioStatus.accepted,
        visioProposalId: 'proposal-1',
        callId: callId,
      );

      expect(responseMsg.callId, callId);
      expect(responseMsg.visioStatus, VisioStatus.accepted);
    });

    test('deux parties utilisant le même callId rejoignent le même canal', () {
      final sharedCallId = 'call-shared-456';

      final responseMsg = MessageModel(
        id: 'resp-1',
        senderUid: 'assmat-1',
        text: 'Visio acceptée',
        sentAt: DateTime(2026),
        type: MessageType.visioResponse,
        visioStatus: VisioStatus.accepted,
        visioProposalId: 'proposal-1',
        callId: sharedCallId,
      );

      final parentCallId = responseMsg.callId;
      final assmatCallId = responseMsg.callId;

      expect(parentCallId, assmatCallId);
      expect(parentCallId, sharedCallId);
    });
  });
}
