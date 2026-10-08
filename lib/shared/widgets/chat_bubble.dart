import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../models/message_model.dart';
import '../utils/chat_time_format.dart';

/// Bulle d'un message texte dans un fil de discussion.
///
/// Les messages de l'utilisateur courant ([isMe]) sont alignés à droite sur
/// fond primaire. Avec [showReadReceipt], une coche (lu / non lu) suit
/// l'heure des messages envoyés.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.msg,
    required this.isMe,
    this.showReadReceipt = false,
  });

  final MessageModel msg;
  final bool isMe;
  final bool showReadReceipt;

  @override
  Widget build(BuildContext context) {
    final timeText = Text(
      chatMessageTimeLabel(msg.sentAt),
      style: AppTextStyles.bodySmall
          .copyWith(color: AppColors.hint, fontSize: 10),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : const Color(0xFFF0F0EE),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isMe ? Colors.white : AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (showReadReceipt)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      timeText,
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          msg.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 13,
                          color: msg.isRead
                              ? AppColors.primary
                              : AppColors.secondaryText,
                        ),
                      ],
                    ],
                  )
                else
                  timeText,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
