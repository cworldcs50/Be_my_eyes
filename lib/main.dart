import 'app_binding.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'view/screen/home_view.dart';
import 'view/screen/on_boarding.dart';
import 'package:flutter/material.dart';
import 'core/services/app_services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'view/middlewares/on_boarding_middleware.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WakelockPlus.enable();
  cameras = await availableCameras();
  await initialServices();
  runApp(const BeMyEyes());
}

class BeMyEyes extends StatelessWidget {
  const BeMyEyes({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetMaterialApp(
        title: "Be My Eyes",
        getPages: [
          GetPage<HomeView>(name: "/home", page: () => HomeView()),
          GetPage<VoiceWaveScreen>(
            name: "/",
            page: () => VoiceWaveScreen(),
            middlewares: [OnBoardingMiddleware()],
          ),
        ],
        initialBinding: AppBinding(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
