import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../../core/services/app_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    SharedPreferences sharedPrefs = Get.find<AppServices>().sharedPrefs;

    if (sharedPrefs.getBool("isOnboardingPlayed") ?? false) {
      return RouteSettings(name: "/home");
    }

    return null;
  }
}
