import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:vibration/vibration.dart';
import '../../controller/home_controller.dart';
import '../../view/screen/camera_view.dart';
import "package:http/http.dart" as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/app_services.dart';

class CommandsImplementer {
  CommandsImplementer._();
  factory CommandsImplementer() => instance;

  static final instance = CommandsImplementer._();
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> beMyEyesCommandImplementer() async {
    await Vibration.vibrate(duration: 1000).then((_) async {
      await Get.find<AppServices>().sharedPrefs.setBool(
        "isOnboardingPlayed",
        true,
      );
      await Get.offNamed("/home");
    });
  }

  Future<void> _vibrate(int duartion) async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: duartion);
    }
  }

  Future<void> openCameraCommandImplementer(
    CameraController controller,
  ) async => await _vibrate(300).then(
    (value) async => await Get.to(() => CameraView(controller: controller)),
  );

  Future<XFile> takePhotoCommandImplementer(CameraController controller) async {
    return await controller.takePicture().then((file) async {
      log("📸 Photo taken: ${file.path}");

      return file;
    });
  }

  Future<String?> postImage(XFile image) async {
    try {
      var uri = Uri.parse(
        "https://unpragmatic-unabsorbingly-kamryn.ngrok-free.dev/api/detect",
      );

      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          filename: image.name,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        log("✅ Image analyzed successfully");

        final resBody = await response.stream.bytesToString();
        log("📢 Detect API Response: $resBody");

        final data = jsonDecode(resBody);

        if (data["speech"] != null) {
          return await _downloadAndPlayAudio(data);
        } else {
          log("⚠ No speech file returned from API");
        }
      } else {
        log("❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      log("❌ Error sending image: $e");
    }

    return null;
  }

  Future<String?> _downloadAndPlayAudio(dynamic response) async {
    try {
      String fileName =
          (response["speech"]["file_path"] as String)
              .split('/')
              .last
              .split('\\')
              .last;

      var url = Uri.parse(
        "https://unpragmatic-unabsorbingly-kamryn.ngrok-free.dev/api/speech/$fileName",
      );
      var audioResponse = await http.get(url);

      if (audioResponse.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = "${dir.path}/$fileName";

        File file = File(filePath);
        await file.writeAsBytes(audioResponse.bodyBytes);

        log("🎵 Saved audio to $filePath");
        log("Audio file exists: ${await File(filePath).exists()}");
        log("Audio file size: ${(await File(filePath).length())} bytes");

        await _player.play(DeviceFileSource(filePath));

        _player.onPositionChanged.listen((position) async {
          final caption = Get.find<HomeController>().caption.value;
          final words = caption.split(' ');
          final duration = await _player.getDuration();
          if (duration == null || words.isEmpty) return;

          final progress = position.inMilliseconds / duration.inMilliseconds;
          final currentIndex = (progress * words.length).floor();

          Get.find<HomeController>().currentWordIndex.value = currentIndex;
          Get.find<HomeController>().scrollToWord(currentIndex);
        });

        return response["caption"];
      } else {
        log("❌ Failed to download audio: ${audioResponse.statusCode}");
        log(audioResponse.body);
      }
    } catch (e) {
      log("❌ Error downloading audio: $e");
    }

    return null;
  }
}
