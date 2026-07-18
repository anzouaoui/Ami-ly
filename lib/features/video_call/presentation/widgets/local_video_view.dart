import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class LocalVideoView extends StatelessWidget {
  const LocalVideoView({
    super.key,
    required this.engine,
    required this.enabled,
  });

  final RtcEngine engine;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.videocam_off_rounded, size: 48, color: AppColors.primary),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine,
          canvas: const VideoCanvas(uid: 0),
          useFlutterTexture: true,
        ),
      ),
    );
  }
}
