class WeatherForecast {
  final double latitude;
  final double longitude;
  final List<DailyForecast> daily;

  WeatherForecast({
    required this.latitude,
    required this.longitude,
    required this.daily,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final dailyJson = json['daily'];
    final List<String> times = List<String>.from(dailyJson['time']);
    final List<double> maxTemps = List<double>.from(dailyJson['temperature_2m_max']);
    final List<double> minTemps = List<double>.from(dailyJson['temperature_2m_min']);
    final List<double> rainProb = List<double>.from(dailyJson['precipitation_probability_max']);
    final List<double> humidity = List<double>.from(dailyJson['relative_humidity_2m_max'] ?? []);
    final List<int> weatherCodes = List<int>.from(dailyJson['weather_code']);

    final List<DailyForecast> dailyList = [];
    for (int i = 0; i < times.length; i++) {
      dailyList.add(DailyForecast(
        date: DateTime.parse(times[i]),
        maxTemp: maxTemps[i],
        minTemp: minTemps[i],
        precipitationProbability: rainProb[i],
        humidity: humidity.isNotEmpty ? humidity[i] : 0.0,
        weatherCode: weatherCodes[i],
      ));
    }

    return WeatherForecast(
      latitude: json['latitude'],
      longitude: json['longitude'],
      daily: dailyList,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double precipitationProbability;
  final double humidity;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbability,
    required this.humidity,
    required this.weatherCode,
  });

  String get weatherIcon {
    // WMO Weather interpretation codes (WW)
    // https://open-meteo.com/en/docs
    if (weatherCode == 0) return '☀️'; // Clear sky
    if (weatherCode <= 3) return '⛅'; // Mainly clear, partly cloudy, and overcast
    if (weatherCode <= 48) return '🌫️'; // Fog
    if (weatherCode <= 55) return '🌦️'; // Drizzle
    if (weatherCode <= 65) return '🌧️'; // Rain
    if (weatherCode <= 77) return '❄️'; // Snow
    if (weatherCode <= 82) return '⛈️'; // Rain showers
    if (weatherCode <= 86) return '🌨️'; // Snow showers
    if (weatherCode <= 99) return '⛈️'; // Thunderstorm
    return '❓';
  }

  String get weatherDescription {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 55) return 'Drizzle';
    if (weatherCode <= 65) return 'Rainy';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}
