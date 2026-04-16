import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

/// Dashboard de l'Assistante Maternelle : profil, disponibilités, demandes
/// entrantes, abonnement Ami-ly Pro via RevenueCat, émission de factures Stripe.
///
/// TODO(subscription) : paywall RevenueCat si `!user.isPro`.
/// TODO(matching) : visibilité boostée pour les profils Pro.
class AssMatHomePage extends ConsumerWidget {
  const AssMatHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ami-ly — Ass. Mat.'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.child_care, size: 64),
              const SizedBox(height: 16),
              Text(
                'Bienvenue ${user?.displayName ?? ''} !',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.isPro == true
                    ? 'Compte Ami-ly Pro actif'
                    : 'Passez à Ami-ly Pro pour booster votre visibilité',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
