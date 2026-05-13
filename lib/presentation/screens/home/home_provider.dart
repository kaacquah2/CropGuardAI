import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/ghana_seasonal_tip.dart';
import '../../../domain/models/detection_result.dart';
import '../../../domain/usecases/home/get_home_data_usecase.dart';

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
  final SharedPreferences _prefs;

  HomeProvider(this._getHomeDataUseCase, this._prefs) {
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

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final result = await _getHomeDataUseCase();
    
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
  }

  Future<void> refresh() => load();
}

