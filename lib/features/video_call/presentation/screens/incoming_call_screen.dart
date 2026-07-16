import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:amily/app/theme/app_colors.dart';
import '../providers/video_call_providers.dart';
import 'video_call_screen.dart';

/// Écran d'appel entrant.
///
/// Affiché quand un appel avec status 'ringing' est détecté
/// pour l'utilisateur courant.
class IncomingCallScreen extends ConsumerWidget {
  const IncomingCallScreen({super.key, required this.callId});

  final String callId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(incomingCallsProvider).valueOrNull?.where((c) => c.id == callId).firstOrNull;

    if (call == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Appel terminé', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Avatar de l'appelant
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                call.callerName.isNotEmpty
                    ? call.callerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nom de l'appelant
            Text(
              call.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Statut
            const Text(
              'Appel entrant...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const Spacer(flex: 3),

            // Boutons Accepter / Refuser
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Refuser
                _CallAction(
                  icon: Icons.call_end_rounded,
                  label: 'Refuser',
                  backgroundColor: AppColors.error,
                  onTap: () async {
                    await ref
                        .read(videoCallControllerProvider.notifier)
                        .endCurrentCall();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),

                // Accepter
                _CallAction(
                  icon: Icons.call_rounded,
                  label: 'Accepter',
                  backgroundColor: AppColors.success,
                  onTap: () async {
                    await ref
                        .read(videoCallControllerProvider.notifier)
                        .acceptCall(callId);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => VideoCallScreen(callId: callId),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  const _CallAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
