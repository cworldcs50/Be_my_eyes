import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:vibration/vibration.dart';
import '../core/services/app_services.dart';
import '../core/class/commands_implementer.dart';

class HomeController extends GetxController {
  RxString caption = "".obs;
  RxInt currentWordIndex = 0.obs;
  Rx<XFile?> picture = Rx<XFile?>(null);
  final CameraController cameraController =
      Get.find<AppServices>().cameraService.controller;
  ScrollController scrollController = ScrollController();
  final wakeWord = Get.find<AppServices>().wakeWordService;

  @override
  Future<void> onInit() async {
    super.onInit();
    await wakeWord.dispose();
    await wakeWord.init(_wakeWordCallback);
    await wakeWord.start();
  }

  void startHighlight(int totalDurationMs) {
    final words = caption.value.split(' ');
    if (words.isEmpty) return;

    final durationPerWord = (totalDurationMs / words.length).round();

    for (int i = 0; i < words.length; i++) {
      Future.delayed(Duration(milliseconds: i * durationPerWord), () {
        currentWordIndex.value = i;
        _autoScroll(i);
      });
    }
  }

  void _autoScroll(int index) {
    scrollController.animateTo(
      index * 40.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollToWord(int index) {
    final offset = (index * 40.0);
    final maxScroll = scrollController.position.maxScrollExtent;

    scrollController.animateTo(
      offset.clamp(0, maxScroll),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
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
        await CommandsImplementer.instance
            .takePhotoCommandImplementer(cameraController)
            .then((picture) async {
              this.picture.value = picture;
              await Vibration.vibrate(duration: 200).then((_) => Get.back());
              caption.value = "";
            });
        break;
      case 3:
        if (picture.value != null) {
          await CommandsImplementer.instance
              .postImage(picture.value!)
              .then((resultCaption) => caption.value = resultCaption ?? "");
        }
        break;
      case 4:
        exit(0);
      default:
        log("Unknown command index");
    }
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    await cameraController.dispose();
  }
}
