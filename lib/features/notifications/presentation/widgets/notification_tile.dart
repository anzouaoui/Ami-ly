import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  static const _iconData = {
    NotificationType.newMessage: Icons.mail_outline_rounded,
    NotificationType.contractSignatureRequest: Icons.edit_note_rounded,
    NotificationType.contractSigned: Icons.check_circle_outline_rounded,
    NotificationType.contractStatusChanged: Icons.assignment_outlined,
    NotificationType.visioProposalReceived: Icons.videocam_outlined,
    NotificationType.visioProposalResponse: Icons.videocam_outlined,
    NotificationType.childAdded: Icons.child_care_outlined,
    NotificationType.availabilityUpdated: Icons.schedule_outlined,
  };

  static const _iconColors = {
    NotificationType.newMessage: Color(0xFF4A90D9),
    NotificationType.contractSignatureRequest: Color(0xFF8B5CF6),
    NotificationType.contractSigned: Color(0xFF10B981),
    NotificationType.contractStatusChanged: Color(0xFFF59E0B),
    NotificationType.visioProposalReceived: Color(0xFF06B6D4),
    NotificationType.visioProposalResponse: Color(0xFF06B6D4),
    NotificationType.childAdded: Color(0xFF6BBF59),
    NotificationType.availabilityUpdated: Color(0xFFD4A02E),
  };

  static const _iconBgs = {
    NotificationType.newMessage: Color(0xFFE3F2FD),
    NotificationType.contractSignatureRequest: Color(0xFFEDE7F6),
    NotificationType.contractSigned: Color(0xFFE8F5E9),
    NotificationType.contractStatusChanged: Color(0xFFFFF8E1),
    NotificationType.visioProposalReceived: Color(0xFFE0F7FA),
    NotificationType.visioProposalResponse: Color(0xFFE0F7FA),
    NotificationType.childAdded: Color(0xFFE8F5E9),
    NotificationType.availabilityUpdated: Color(0xFFFFF8E1),
  };

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconData[notification.type] ?? Icons.info_outline_rounded;
    final iconColor =
        _iconColors[notification.type] ?? AppColors.secondaryText;
    final iconBg = _iconBgs[notification.type] ??
        AppColors.secondaryText.withValues(alpha: 0.1);

    return Material(
      color: notification.read ? AppColors.surface : AppColors.background,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: notification.read
                  ? AppColors.divider
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: notification.read
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondaryText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
