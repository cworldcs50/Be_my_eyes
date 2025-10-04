import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../widget/custom_audio_file_waveforms.dart';
import '../../controller/on_boarding_controller.dart';

class VoiceWaveScreen extends StatelessWidget {
  const VoiceWaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF121C4D),
      body: GetBuilder<OnboardingController>(
        builder: (controller) {
          controller.conversation();
          return Center(
            child: CustomAudioFileWaveforms(
              showGlow: controller.showGlow,
              glowColor: controller.glowColor,
              playerController: controller.voicePlayer.player,
            ),
          );
        },
      ),
    );
  }
}
