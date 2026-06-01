import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/scan_severity.dart';
import '../../../core/utils/streak_manager.dart';
import '../../models/detection_result.dart';
import '../../repositories/i_classifier_repository.dart';
import '../../repositories/i_detection_repository.dart';

class ScanCropUseCase {
  final IClassifierRepository _classifierRepository;
  final IDetectionRepository _detectionRepository;
  final StreakManager _streakManager;

  ScanCropUseCase(
    this._classifierRepository,
    this._detectionRepository,
    this._streakManager,
  );

  Future<Result<DetectionResult>> call(String imagePath, String userId) async {
    final classificationResult = await _classifierRepository.classifyFromPath(imagePath);

    if (classificationResult.isError) {
      return Result.error(classificationResult.failure!);
    }

    final classification = classificationResult.data;
    if (classification == null) {
      return Result.error(MLFailure('Classification failed to return a result'));
    }

    // Map severity based on confidence and health status
    String severity;
    if (classification.isHealthy) {
      severity = ScanSeverity.healthy;
    } else if (classification.confidence >= 0.85) {
      severity = ScanSeverity.severe;
    } else if (classification.confidence >= 0.70) {
      severity = ScanSeverity.moderate;
    } else {
      severity = ScanSeverity.early;
    }

    final detection = DetectionResult(
      userId: userId,
      imagePath: imagePath,
      diseaseLabel: classification.label,
      displayName: classification.diseaseInfo.displayName,
      confidence: classification.confidence,
      severity: severity,
      isHealthy: classification.isHealthy,
      cropType: classification.diseaseInfo.cropType,
      cause: classification.diseaseInfo.cause,
      treatments: classification.diseaseInfo.treatments,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final saveResult = await _detectionRepository.saveDetection(detection);
    
    if (saveResult.isError) {
      return Result.error(saveResult.failure!);
    }

    _streakManager.recordScan();

    return Result.success(detection.copyWith(id: saveResult.data));
  }
}
