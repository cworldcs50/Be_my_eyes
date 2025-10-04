import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../controller/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0XFF121C4D),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Be My Eyes",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      body: Obx(() {
        final captionText = controller.caption.value;
        final words = captionText.split(' ');
        final highlightedIndex = controller.currentWordIndex.value;

        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            child: RichText(
              text: TextSpan(
                children: List.generate(words.length, (index) {
                  final isActive = index == highlightedIndex;
                  return TextSpan(
                    text: '${words[index]} ',
                    style: TextStyle(
                      color: isActive ? Colors.greenAccent : Colors.white,
                      fontSize: isActive ? 34 : 26,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      }),
    );
  }
}
