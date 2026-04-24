import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

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

final _kNotifications = [
  const _Notif(
    type: _NotifType.message,
    title: 'Nouveau message de Sophie',
    body: 'Sophie M. vous a envoyé un message',
    time: 'Il y a 5 min',
  ),
  const _Notif(
    type: _NotifType.journal,
    title: 'Journal mis à jour',
    body: 'Le journal de Lucas a été mis à jour pour aujourd\'hui',
    time: 'Il y a 2h',
  ),
  const _Notif(
    type: _NotifType.payment,
    title: 'Paiement de mars traité',
    body: 'Votre paiement de 850,00 € a été validé avec succès',
    time: 'Hier',
    read: true,
  ),
  const _Notif(
    type: _NotifType.contract,
    title: 'Contrat renouvelé',
    body: 'Votre contrat avec Sophie M. a été renouvelé pour 2025–2026',
    time: 'Il y a 3 jours',
    read: true,
  ),
  const _Notif(
    type: _NotifType.info,
    title: 'Rappel : RDV PMI',
    body: 'Vous avez un rendez-vous PMI prévu le 15 mai 2025',
    time: 'Il y a 5 jours',
    read: true,
  ),
  const _Notif(
    type: _NotifType.journal,
    title: 'Compte-rendu disponible',
    body: 'Le compte-rendu de la semaine du 7 avril est disponible',
    time: 'Il y a 1 semaine',
    read: true,
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _unreadOnly = false;
  late final List<_Notif> _items = List.of(_kNotifications);

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.md, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                    color: AppColors.secondaryText,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w600),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Tout lire'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Filter chips ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Toutes',
                    active: !_unreadOnly,
                    onTap: () => setState(() => _unreadOnly = false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'Non lues',
                    active: _unreadOnly,
                    badge: _unreadCount > 0 ? '$_unreadCount' : null,
                    onTap: () => setState(() => _unreadOnly = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── List ─────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState(unreadOnly: _unreadOnly)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) => _NotifTile(
                        notif: _filtered[i],
                        onTap: () {
                          final idx = _items.indexWhere(
                              (n) => n.title == _filtered[i].title);
                          if (idx != -1 && !_items[idx].read) {
                            setState(() {
                              _items[idx] = _Notif(
                                type: _items[idx].type,
                                title: _items[idx].title,
                                body: _items[idx].body,
                                time: _items[idx].time,
                                read: true,
                              );
                            });
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.divider,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: active
                    ? AppColors.primary
                    : AppColors.secondaryText,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});
  final _Notif notif;
  final VoidCallback onTap;

  static const _iconData = {
    _NotifType.message: Icons.chat_bubble_outline_rounded,
    _NotifType.journal: Icons.assignment_outlined,
    _NotifType.payment: Icons.credit_card_rounded,
    _NotifType.contract: Icons.description_outlined,
    _NotifType.info: Icons.info_outline_rounded,
  };

  static const _iconColors = {
    _NotifType.message: AppColors.primary,
    _NotifType.journal: Color(0xFF4A8ED9),
    _NotifType.payment: AppColors.accent,
    _NotifType.contract: AppColors.primary,
    _NotifType.info: Color(0xFFE07A2F),
  };

  static const _iconBgs = {
    _NotifType.message: AppColors.secondary,
    _NotifType.journal: Color(0xFFE8F1FB),
    _NotifType.payment: AppColors.statYellowBg,
    _NotifType.contract: AppColors.secondary,
    _NotifType.info: Color(0xFFFEF0E6),
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconData[notif.type]!;
    final iconColor = _iconColors[notif.type]!;
    final iconBg = _iconBgs[notif.type]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notif.read
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: notif.read
                ? AppColors.divider
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: notif.read
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      if (!notif.read) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText, height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.time,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.hint, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.unreadOnly});
  final bool unreadOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 64, color: AppColors.hint),
          const SizedBox(height: AppSpacing.md),
          Text(
            unreadOnly
                ? 'Aucune notification non lue'
                : 'Aucune notification pour le moment',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
