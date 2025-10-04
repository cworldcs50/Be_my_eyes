import 'dart:io';
import 'dart:ui';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import '../core/class/commands_implementer.dart';
import '../core/services/app_services.dart';

class OnboardingController extends GetxController {
  XFile? picture;

  final CameraController cameraController =
      Get.find<AppServices>().cameraService.controller;
  final wakeWord = Get.find<AppServices>().wakeWordService;
  bool showGlow = false;
  final glowColor = const Color(0xFF2196F3);
  final sharedPrefs = Get.find<AppServices>().sharedPrefs;

  final voicePlayer = Get.find<AppServices>().voicePlayerService;

  @override
  Future<void> onInit() async {
    super.onInit();
    await wakeWord.init(_wakeWordCallback);
    voicePlayer.player.onCompletion.listen((_) async => await wakeWord.start());
  }

  Future<void> _wakeWordCallback(int keywordIndex) async {
    log("📢 Wake word detected at index $keywordIndex");

    switch (keywordIndex) {
      case 0:
        await CommandsImplementer.instance.beMyEyesCommandImplementer();
        break;
      case 1:
        await CommandsImplementer.instance.openCameraCommandImplementer(
          cameraController,
        );
        break;
      case 2:
        picture = await CommandsImplementer.instance
            .takePhotoCommandImplementer(cameraController)
            .then((newPicture) async {
              await Vibration.vibrate(duration: 200).then((_) => Get.back());
              return newPicture;
            });
        update();
        break;
      case 3:
        picture != null
            ? await CommandsImplementer.instance.postImage(picture!)
            : Vibration.vibrate(duration: 200);
        log("3");
        update();
        break;
      case 4:
        exit(0);
      default:
        log("Unknown command index");
    }
  }

  Future<void> conversation() async {
    showGlow = true;
    update();

    String lang = Get.deviceLocale?.languageCode == "ar" ? "arabic" : "english";

    await voicePlayer.play("assets/voices/$lang/part1.mp3");
  }
}
