import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/video_call_providers.dart';

class CallControlsBar extends StatelessWidget {
  const CallControlsBar({
    super.key,
    required this.state,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onEndCall,
  });

  final VideoCallState state;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleVideo;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: state.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: state.isMuted ? 'Démuet' : 'Muet',
            onTap: onToggleMute,
          ),
          _ControlButton(
            icon: state.isVideoEnabled
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            label: state.isVideoEnabled ? 'Caméra' : 'Caméra off',
            onTap: onToggleVideo,
          ),
          _ControlButton(
            icon: Icons.call_end_rounded,
            label: 'Raccrocher',
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            onTap: onEndCall,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: foregroundColor ?? Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor ?? Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
