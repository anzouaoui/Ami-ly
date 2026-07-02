import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Models ─────────────────────────────────────────────────────────────────────

enum _NotifType { message, journal, payment, contract, info }

class _Notif {
  const _Notif({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });
  final _NotifType type;
  final String title;
  final String body;
  final String time;
  final bool read;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _unreadOnly = false;
  final List<_Notif> _items = [];

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _Notif(
          type: _items[i].type,
          title: _items[i].title,
          body: _items[i].body,
          time: _items[i].time,
          read: true,
        );
      }
    });
  }

  int get _unreadCount => _items.where((n) => !n.read).length;

  List<_Notif> get _filtered =>
      _unreadOnly ? _items.where((n) => !n.read).toList() : _items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Tout marquer lu'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifications',
                          style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w800, fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        _unreadCount > 0
                            ? '$_unreadCount non ${_unreadCount > 1 ? 'lues' : 'lue'}'
                            : 'Tout est à jour',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                FilterChip(
                  label: Text('Non lues',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600)),
                  selected: _unreadOnly,
                  onSelected: (v) => setState(() => _unreadOnly = v),
                  visualDensity: VisualDensity.compact,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  side: BorderSide(
                    color: _unreadOnly ? AppColors.primary : AppColors.divider,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 48, color: AppColors.secondaryText.withValues(alpha: 0.4)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _unreadOnly ? 'Aucune notification non lue' : 'Aucune notification',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _NotifTile(notif: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif});
  final _Notif notif;

  static const _iconData = {
    _NotifType.message: Icons.mail_outline_rounded,
    _NotifType.journal: Icons.book_outlined,
    _NotifType.payment: Icons.euro_rounded,
    _NotifType.contract: Icons.assignment_outlined,
    _NotifType.info: Icons.info_outline_rounded,
  };

  static const _iconColors = {
    _NotifType.message: Color(0xFF4A90D9),
    _NotifType.journal: Color(0xFF6BBF59),
    _NotifType.payment: Color(0xFFD4A02E),
    _NotifType.contract: Color(0xFF8B5CF6),
    _NotifType.info: Color(0xFF6B7280),
  };

  static const _iconBgs = {
    _NotifType.message: Color(0xFFE3F2FD),
    _NotifType.journal: Color(0xFFE8F5E9),
    _NotifType.payment: Color(0xFFFFF8E1),
    _NotifType.contract: Color(0xFFEDE7F6),
    _NotifType.info: Color(0xFFF3F4F6),
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconData[notif.type]!;
    final iconColor = _iconColors[notif.type]!;
    final iconBg = _iconBgs[notif.type]!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: notif.read ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: notif.read ? AppColors.divider : AppColors.primary.withValues(alpha: 0.3),
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
                        notif.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: notif.read ? FontWeight.w600 : FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(notif.time,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif.body,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
