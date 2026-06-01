import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/ghana_seasonal_tip.dart';
import '../../../domain/models/detection_result.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/usecases/home/get_home_data_usecase.dart';
import '../../../domain/usecases/weather/get_weather_usecase.dart';
import '../../../domain/models/weather_forecast.dart';
import '../../../core/utils/agri_weather_utils.dart';

class FarmStats {
  final int totalScans;
  final int healthyScans;
  final int diseasedScans;

  const FarmStats({
    this.totalScans = 0,
    this.healthyScans = 0,
    this.diseasedScans = 0,
  });

  double get healthScore =>
      totalScans > 0 ? healthyScans / totalScans : 0.0;
}

/// Refactored HomeProvider using Clean Architecture
class HomeProvider extends ChangeNotifier {
  final GetHomeDataUseCase _getHomeDataUseCase;
  final GetWeatherUseCase _getWeatherUseCase;
  final IAuthRepository _authRepository;

  HomeProvider(this._getHomeDataUseCase, this._getWeatherUseCase, this._authRepository, SharedPreferences prefs) {
    load();
  }

  FarmStats stats = const FarmStats();
  List<DetectionResult> recentScans = [];
  bool isLoading = true;
  bool isOffline = false;
  bool isHighRisk = false;
  String seasonalAlert = '';
  String dailyTip = '';
  List<Map<String, dynamic>> trend = [];

  // Weather data
  WeatherForecast? weather;
  bool isWeatherLoading = false;
  String? weatherError;
  bool hasDiseaseRisk = false;
  String diseaseRiskMessage = '';
  String plantingStatus = '';
  String plantingAction = '';

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final userId = _authRepository.currentUser?.id;
    final result = await _getHomeDataUseCase(userId: userId);
    
    if (result.isSuccess) {
      final data = result.data!;
      stats = FarmStats(
        totalScans: data.stats['total'] ?? 0,
        healthyScans: data.stats['healthy'] ?? 0,
        diseasedScans: data.stats['diseased'] ?? 0,
      );
      recentScans = data.recentScans;
      trend = data.trend;
      isOffline = false;
    } else {
      isOffline = true;
    }

    isHighRisk = GhanaSeasonalTip.isHighRisk();
    seasonalAlert = GhanaSeasonalTip.getAlertMessage();

    final tipIdx = GhanaSeasonalTip.getDailyTipIndex(dailyTips.length);
    dailyTip = dailyTips[tipIdx];

    isLoading = false;
    notifyListeners();

    // Fetch weather (Kumasi defaults)
    _fetchWeather(6.6666, -1.6163);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    isWeatherLoading = true;
    weatherError = null;
    notifyListeners();

    try {
      weather = await _getWeatherUseCase.execute(latitude: lat, longitude: lon);
      
      // Calculate risks
      if (weather != null && weather!.daily.isNotEmpty) {
        final today = weather!.daily.first;
        hasDiseaseRisk = AgriWeatherUtils.isFungalRisk(today);
        if (hasDiseaseRisk) {
          diseaseRiskMessage = "Conditions favor late blight. Check your crops!";
        }
      }

      // Ghana planting guide (assume South for Kumasi)
      final advice = AgriWeatherUtils.getPlantingAdvice('South');
      plantingStatus = advice['status'] ?? '';
      plantingAction = advice['action'] ?? '';

    } catch (e) {
      weatherError = e.toString();
    } finally {
      isWeatherLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load();
  }
}
