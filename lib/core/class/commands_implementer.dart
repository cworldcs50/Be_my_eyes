import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../services/app_services.dart';
import "package:http/http.dart" as http;
import 'package:vibration/vibration.dart';
import '../../view/screen/camera_view.dart';
import '../../controller/home_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class CommandsImplementer {
  CommandsImplementer._();
  AudioPlayer get player => _player;
  final AudioPlayer _player = AudioPlayer();
  factory CommandsImplementer() => instance;
  static final instance = CommandsImplementer._();

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
    final homeCtrl = Get.find<HomeController>();
    homeCtrl.caption.value = "loading...";
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
        final homeCtrl = Get.find<HomeController>();
        await file.writeAsBytes(audioResponse.bodyBytes);

        log("🎵 Saved audio to $filePath");

        final captionText = response["caption"] ?? "";
        homeCtrl.caption.value = captionText;

        _player.onPositionChanged.listen((position) async {
          final words = homeCtrl.caption.value.split(' ');
          final duration = await _player.getDuration();
          if (duration == null || words.isEmpty) return;

          final progress = position.inMilliseconds / duration.inMilliseconds;
          final currentIndex = (progress * words.length).floor();

          homeCtrl.currentWordIndex.value = currentIndex;
          homeCtrl.scrollToWord(currentIndex);
        });

        await _player.play(DeviceFileSource(filePath));

        return captionText;
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
