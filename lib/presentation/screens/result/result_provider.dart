import 'package:flutter/material.dart';
import '../../../data/local/database_helper.dart';
import '../../../data/remote/firestore_service.dart';
import '../../../domain/models/detection_result.dart';
import '../../../domain/usecases/weather/get_weather_usecase.dart';
import '../../../core/utils/agri_weather_utils.dart';

/// Equivalent of ResultViewModel.kt
class ResultProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  final FirestoreService _firestore;
  final GetWeatherUseCase _getWeatherUseCase;

  ResultProvider(this._db, this._firestore, this._getWeatherUseCase);

  DetectionResult? result;
  String sprayAdvisory = '';
  bool isWeatherLoading = false;
  bool isLoading = false;
  String? errorMessage;
  bool feedbackSent = false;
  bool cropNotFoundSent = false;
  bool expertRequestSent = false;
  bool isRequestingExpert = false;

  Future<void> load(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    result = await _db.getDetectionById(id);
    if (result == null) {
      errorMessage = 'Result not found.';
    } else {
      // If it's a disease, fetch spray advisory
      if (!result!.isHealthy) {
        await _fetchSprayAdvisory();
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchSprayAdvisory() async {
    isWeatherLoading = true;
    notifyListeners();
    try {
      // Use Kumasi defaults for demo
      final weather = await _getWeatherUseCase.execute(latitude: 6.6666, longitude: -1.6163);
      if (weather.daily.isNotEmpty) {
        sprayAdvisory = AgriWeatherUtils.getSprayAdvisory(weather.daily.first);
      }
    } catch (e) {
      sprayAdvisory = "Weather data unavailable for spray advisory.";
    } finally {
      isWeatherLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitFeedback({
    required String userId,
    required String correctedLabel,
  }) async {
    if (result == null) return;
    await _firestore.submitFeedback(
      userId: userId,
      detectionId: result!.id,
      originalLabel: result!.diseaseLabel,
      correctedLabel: correctedLabel,
    );
    feedbackSent = true;
    notifyListeners();
  }

  Future<void> submitCropNotFound({
    required String userId,
    required String suggestedCrop,
    required String observedSymptoms,
  }) async {
    if (result == null) return;
    await _firestore.submitCropNotFound(
      userId: userId,
      suggestedCrop: suggestedCrop,
      observedSymptoms: observedSymptoms,
      imagePath: result!.imagePath,
    );
    cropNotFoundSent = true;
    notifyListeners();
  }

  Future<void> requestExpertHelp({
    required String userId,
    required String message,
  }) async {
    if (result == null) return;
    isRequestingExpert = true;
    notifyListeners();
    await _firestore.requestExpertHelp(
      userId: userId,
      detectionId: result!.id.toString(),
      message: message,
      diseaseName: result!.displayName,
    );
    isRequestingExpert = false;
    expertRequestSent = true;
    notifyListeners();
  }
}
