import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class VoicePlayerService {
  final player = PlayerController();

  Future<String> _loadAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    final tempDir = await getTemporaryDirectory();
    final file = File("${tempDir.path}/${assetPath.split('/').last}");
    await file.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    return file.path;
  }

  Future<void> play(String assetPath) async {
    final filePath = await _loadAssetToFile(assetPath);
    if (player.playerState == PlayerState.playing ||
        player.playerState == PlayerState.paused) {
      await player.stopPlayer();
    }
    await player.preparePlayer(path: filePath);
    await player.startPlayer();
  }

  Future<void> dispose() async {
    await player.stopPlayer();
    player.dispose();
  }
}
