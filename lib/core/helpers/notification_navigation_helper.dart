import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../features/assmat/presentation/pages/assmat_chat_page.dart';
import '../../features/assmat/presentation/pages/assmat_sign_contract_page.dart';
import '../../features/parent/presentation/pages/engagement_contract_page.dart';
import '../../features/parent/presentation/pages/parent_chat_page.dart';

class NotificationNavigationHelper {
  static Future<void> navigateToConversation(
    BuildContext context,
    String convId,
    String currentUserId,
  ) async {
    final convDoc = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(convId)
        .get();

    if (!convDoc.exists || !context.mounted) return;

    final data = convDoc.data()!;
    final isParent = data['parentUid'] == currentUserId;

    if (isParent) {
      final assmatUid = data['assmatUid'] as String? ?? '';
      final assmatName = data['assmatName'] as String? ?? 'Assistante maternelle';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ParentChatPage(
            assmatUid: assmatUid,
            assmatName: assmatName,
          ),
        ),
      );
    } else {
      final parentName = data['parentName'] as String? ?? 'Parent';
      final initials = parentName
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssMatChatPage(
            contact: ChatContact(name: parentName, initials: initials),
            conversationId: convId,
          ),
        ),
      );
    }
  }

  static Future<void> navigateToContract(
    BuildContext context,
    String contractId,
    String currentUserId,
  ) async {
    final contractDoc = await FirebaseFirestore.instance
        .collection('contracts')
        .doc(contractId)
        .get();

    if (!contractDoc.exists || !context.mounted) return;

    final data = contractDoc.data()!;
    final isParent = data['parentUid'] == currentUserId;

    if (isParent) {
      final assmatUid = data['assmatUid'] as String? ?? '';
      final assmatName = data['assmatName'] as String? ?? 'Assistante maternelle';

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EngagementContractPage(
            assmatUid: assmatUid,
            assmatName: assmatName,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AssmatSignContractPage(),
        ),
      );
    }
  }
}
