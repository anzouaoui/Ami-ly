import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class RemoteVideoView extends StatelessWidget {
  const RemoteVideoView({
    super.key,
    required this.engine,
    required this.remoteUid,
    required this.channelId,
  });

  final RtcEngine engine;
  final int? remoteUid;
  final String channelId;

  @override
  Widget build(BuildContext context) {
    if (remoteUid == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'En attente de l\'autre participant...',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteUid!),
          connection: RtcConnection(channelId: channelId),
        ),
      ),
    );
  }
}
