import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/call.dart';
import '../providers/video_call_providers.dart';
import '../screens/video_call_screen.dart';

/// Widget à placer dans les shells (ParentShell / AssMatShell) pour écouter
/// les appels entrants en permanence et afficher un overlay quand un appel
/// avec status 'ringing' est détecté pour l'utilisateur courant.
///
/// Le flow : l'appelant clique "Rejoindre la visio" → startCall → document
/// Firestore 'calls' créé avec status 'ringing'. Ce listener détecte le
/// document → affiche l'overlay → l'utilisateur accepte → acceptCall →
/// les deux parties rejoignent le même canal Agora.
class IncomingCallListener extends ConsumerWidget {
  const IncomingCallListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingCalls = ref.watch(incomingCallsProvider);
    final videoState = ref.watch(videoCallControllerProvider);

    if (videoState.call != null) return child;

    return Stack(
      children: [
        child,
        incomingCalls.when(
          data: (calls) {
            if (calls.isEmpty) return const SizedBox.shrink();
            final call = calls.first;
            return _IncomingCallOverlay(callId: call.id, call: call);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _IncomingCallOverlay extends ConsumerWidget {
  const _IncomingCallOverlay({required this.callId, required this.call});

  final String callId;
  final Call call;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  call.callerName.isNotEmpty
                      ? call.callerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                call.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Appel vidéo entrant...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallButton(
                    icon: Icons.call_end_rounded,
                    label: 'Refuser',
                    color: AppColors.error,
                    onTap: () async {
                      await ref
                          .read(videoCallControllerProvider.notifier)
                          .endCurrentCall();
                    },
                  ),
                  _CallButton(
                    icon: Icons.call_rounded,
                    label: 'Accepter',
                    color: AppColors.success,
                    onTap: () async {
                      await ref
                          .read(videoCallControllerProvider.notifier)
                          .acceptCall(callId, callData: call);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoCallScreen(callId: callId),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
