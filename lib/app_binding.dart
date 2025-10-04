import 'package:get/get.dart';
import 'controller/home_controller.dart';
import 'controller/on_boarding_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.put<OnboardingController>(OnboardingController());
  }
}
