import 'dart:developer';
import '../constants/constants.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

class WakeWordService {
  bool _isInitialized = false;
  PorcupineManager? _porcupineManager;

  Future<void> init(Function(int) callback) async {
    if (_isInitialized) {
      log("⚠️ WakeWordService already initialized");
      return;
    }

    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        Constants.kApiKey,
        Constants.kAndroidCommands,
        callback,
      );

      _isInitialized = true;
      log("✅ WakeWordService initialized with keywords");
    } catch (e, st) {
      log("❌ Error initializing WakeWordService: $e\n$st");
    }
  }

  Future<void> start() async {
    if (_porcupineManager != null) {
      await _porcupineManager!.start();
      log("🎤 WakeWord listening...");
    }
  }

  Future<void> stop() async {
    if (_porcupineManager != null) {
      await _porcupineManager!.stop();
      log("🛑 WakeWord stopped");
    }
  }

  Future<void> dispose() async {
    if (_porcupineManager != null) {
      // await _porcupineManager!.stop();
      // await _porcupineManager!.delete();
      // _porcupineManager = null;
      // _isInitialized = false;
      log("🗑️ WakeWord disposed");
    }
  }
}
