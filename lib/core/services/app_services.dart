import 'camera_service.dart';
import 'package:get/get.dart';
import 'wake_word_service.dart';
import 'voice_player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppServices extends GetxService {
  late final CameraService cameraService;
  late final SharedPreferences sharedPrefs;
  late final WakeWordService wakeWordService;
  late final VoicePlayerService voicePlayerService;

  Future<AppServices> initializeApp() async {
    sharedPrefs = await SharedPreferences.getInstance();
    cameraService = CameraService();
    voicePlayerService = VoicePlayerService();
    wakeWordService = WakeWordService();
    return this;
  }
}

Future<void> initialServices() async {
  await Get.putAsync(() async => await AppServices().initializeApp());
}
