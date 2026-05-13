import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class ScanFeedbackHelper {
  static final _audioPlayer = AudioPlayer();

  static Future<void> playScanComplete({
    required bool isHealthy,
    required bool soundEnabled,
    required bool hapticEnabled,
  }) async {
    if (hapticEnabled) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 90);
      }
    }

    if (soundEnabled) {
      // In a real app, we'd bundle short beep sounds in assets
      // For now, we'll try to play a system sound if possible or a placeholder asset
      // await _audioPlayer.play(AssetSource(isHealthy ? 'sounds/success.mp3' : 'sounds/alert.mp3'));
    }
  }
}
