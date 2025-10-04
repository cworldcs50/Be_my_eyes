import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class CustomAudioFileWaveforms extends StatelessWidget {
  const CustomAudioFileWaveforms({
    super.key,
    required this.showGlow,
    required this.glowColor,
    required this.playerController,
  });

  final bool showGlow;
  final Color glowColor;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      animate: showGlow,
      glowColor: glowColor,
      glowRadiusFactor: 0.5,
      glowShape: BoxShape.circle,
      child: AudioFileWaveforms(
        enableSeekGesture: false,
        padding: EdgeInsets.all(5),
        waveformType: WaveformType.long,
        playerController: playerController,
        size: Size(Get.width, Get.height / 2.2),
        playerWaveStyle: PlayerWaveStyle(
          spacing: 50,
          waveThickness: 3,
          showSeekLine: false,
          waveCap: StrokeCap.square,

          liveWaveGradient: const LinearGradient(
            colors: [Colors.pink, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, Get.width, Get.height / 2.2)),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: const Color(0xFF4D2B62)),
          ),
        ),
      ),
    );
  }
}
