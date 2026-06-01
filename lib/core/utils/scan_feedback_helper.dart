import 'package:vibration/vibration.dart';

class ScanFeedbackHelper {
  static Future<void> playScanComplete({
    required bool isHealthy,
    required bool soundEnabled,
    required bool hapticEnabled,
  }) async {
    if (hapticEnabled) {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 90);
      }
    }
  }
}
