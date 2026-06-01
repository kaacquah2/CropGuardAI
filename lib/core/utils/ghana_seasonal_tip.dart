import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Equivalent of GhanaSeasonalTip.kt
class GhanaSeasonalTip {
  static bool isHighRisk() {
    final config = FirebaseRemoteConfig.instance;
    final majorStart = config.getInt('rainy_major_start');
    final majorEnd = config.getInt('rainy_major_end');
    final minorStart = config.getInt('rainy_minor_start');
    final minorEnd = config.getInt('rainy_minor_end');

    final month = DateTime.now().month;

    // Default to hardcoded values if config is not set (0)
    if (majorStart == 0) {
      return (month >= 3 && month <= 6) || (month >= 9 && month <= 11);
    }

    return (month >= majorStart && month <= majorEnd) ||
        (month >= minorStart && month <= minorEnd);
  }

  static String getAlertMessage() {
    final config = FirebaseRemoteConfig.instance;
    final majorMsg = config.getString('rainy_major_msg');
    final minorMsg = config.getString('rainy_minor_msg');

    final month = DateTime.now().month;
    
    // Major season (usually March-June)
    if (month >= 3 && month <= 6) {
      return majorMsg.isNotEmpty ? majorMsg : '⚠️ Major rainy season: high risk of fungal diseases. Inspect crops frequently.';
    }
    // Minor season (usually Sept-Nov)
    if (month >= 9 && month <= 11) {
      return minorMsg.isNotEmpty ? minorMsg : '⚠️ Minor rainy season: watch for blight and mildew. Ensure good field drainage.';
    }
    return '';
  }

  static int getDailyTipIndex(int total) {
    final dayOfYear = DateTime.now().difference(
          DateTime(DateTime.now().year, 1, 1),
        ).inDays;
    return dayOfYear % total;
  }
}

const List<String> dailyTips = [
  'Inspect your crops early in the morning for signs of disease.',
  'Ensure proper spacing between plants for good air circulation.',
  'Rotate crops each season to reduce disease buildup in soil.',
  'Remove and dispose of infected plant material immediately.',
  'Apply fungicides preventively during rainy seasons.',
  'Keep field tools clean to avoid spreading pathogens.',
  'Monitor weather forecasts — humidity accelerates disease spread.',
  'Use certified disease-resistant seed varieties where possible.',
];
