import '../../domain/models/weather_forecast.dart';

class AgriWeatherUtils {
  /// Conditions favor fungal disease (like late blight):
  /// Humidity > 80% and Temperature between 20-30°C
  static bool isFungalRisk(DailyForecast forecast) {
    return forecast.humidity > 80 && 
           forecast.maxTemp >= 20 && 
           forecast.maxTemp <= 30;
  }

  /// Returns advice on whether it's safe to spray.
  /// Ideally, no rain for at least 6 hours after spraying.
  /// For simplicity with daily forecast, we check precipitation probability.
  static String getSprayAdvisory(DailyForecast forecast) {
    if (forecast.precipitationProbability > 50) {
      return "Rain likely (${forecast.precipitationProbability.toInt()}%). Avoid spraying today as it may wash off.";
    } else if (forecast.precipitationProbability > 20) {
      return "Low rain risk (${forecast.precipitationProbability.toInt()}%). Spray with caution in the early morning.";
    } else {
      return "Excellent spray window! No rain forecast (0-20%).";
    }
  }

  /// Ghana Planting Calendar Logic
  /// Regions: 'North' (1 rainy season: May-Oct), 'South' (2 rainy seasons: Mar-Jun, Sep-Nov)
  static Map<String, String> getPlantingAdvice(String region) {
    final now = DateTime.now();
    final month = now.month;

    if (region == 'North') {
      if (month >= 5 && month <= 6) return {"status": "Planting Season", "action": "Ideal for Maize, Millet, and Yam."};
      if (month >= 7 && month <= 9) return {"status": "Growing Season", "action": "Monitor for Fall Armyworm."};
      if (month >= 10 && month <= 11) return {"status": "Harvesting", "action": "Dry grains properly to avoid Aflatoxins."};
      return {"status": "Dry Season", "action": "Prepare land for May planting."};
    } else {
      // South
      if (month >= 3 && month <= 4) return {"status": "Major Season Planting", "action": "Plant Maize and Cassava now."};
      if (month >= 5 && month <= 6) return {"status": "Major Growing Season", "action": "High humidity risk for Fungal diseases."};
      if (month >= 9 && month <= 10) return {"status": "Minor Season Planting", "action": "Short-duration crops recommended."};
      if (month == 11 || month == 12) return {"status": "Minor Harvesting", "action": "Prepare for Harmattan dry spells."};
      return {"status": "Off-season", "action": "Ideal for irrigation farming / vegetables."};
    }
  }
}
