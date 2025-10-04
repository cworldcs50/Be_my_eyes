import 'package:camera/camera.dart';

import '../../main.dart';

class CameraService {
  final CameraController controller = CameraController(
    cameras.first,
    ResolutionPreset.high,
  );

  Future<void> init() async {
    await controller.initialize();
  }

  Future<XFile?> takePhoto() async {
    return await controller.takePicture();
  }

  Future<void> dispose() async {
    await controller.dispose();
  }
}
