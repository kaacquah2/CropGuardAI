import 'package:flutter/material.dart';
import '../../../data/local/database_helper.dart';
import '../../../data/remote/firestore_service.dart';
import '../../../domain/models/detection_result.dart';

/// Equivalent of ResultViewModel.kt
class ResultProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  final FirestoreService _firestore;

  ResultProvider(this._db, this._firestore);

  DetectionResult? result;
  bool isLoading = false;
  String? errorMessage;
  bool feedbackSent = false;
  bool expertRequestSent = false;
  bool isRequestingExpert = false;

  Future<void> load(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    result = await _db.getDetectionById(id);
    if (result == null) errorMessage = 'Result not found.';

    isLoading = false;
    notifyListeners();
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
