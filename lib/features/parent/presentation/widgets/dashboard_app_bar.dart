import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../contract/data/models/contract_model.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

/// Header custom du dashboard parent.
///
/// Disposition (spec "Dashboard Parent 2") :
///   - À gauche : icône menu + logo AMiLY (carré vert + texte) côte à côte
///   - À droite : icône notifications avec badge du nombre de contrats en
///     attente de signature de l'assistante maternelle.
///
/// Contrairement à une `AppBar` Material classique, ce widget vit **dans**
/// le scroll du body — il défile avec le contenu.
class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({
    super.key,
    required this.onMenuTap,
    this.parentUid,
  });

  final VoidCallback onMenuTap;
  final String? parentUid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Bloc gauche : menu + logo ---
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  size: 28,
                  color: AppColors.primaryText,
                ),
                onPressed: onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Menu',
              ),
              const SizedBox(width: AppSpacing.md),
              // Logo (carré vert + texte AMiLY)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                // TODO: remplacer par l'asset du logo réel.
                child: const Icon(
                  Icons.child_care_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AMiLY',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          // --- Bloc droite : notifications ---
          _ParentNotificationBell(parentUid: parentUid),
        ],
      ),
    );
  }
}

/// Icône de cloche avec badge du nombre de contrats en attente de signature
/// de l'assistante maternelle.
class _ParentNotificationBell extends StatelessWidget {
  const _ParentNotificationBell({required this.parentUid});

  final String? parentUid;

  @override
  Widget build(BuildContext context) {
    if (parentUid == null) {
      return IconButton(
        icon: const Icon(
          Icons.notifications_none_rounded,
          size: 24,
          color: AppColors.primaryText,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        },
        tooltip: 'Notifications',
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('contracts')
        .where('parentUid', isEqualTo: parentUid)
        .where('status', whereIn: [ContractStatus.pendingAssmat.name])
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    size: 24,
                    color: AppColors.primaryText,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  tooltip: 'Notifications',
                ),
              ),
              if (count > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
