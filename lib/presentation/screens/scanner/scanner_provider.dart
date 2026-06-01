import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../domain/models/detection_result.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/usecases/scanner/scan_crop_usecase.dart';
import '../../../core/utils/image_quality_analyzer.dart';

enum ScanMode { camera, gallery }

class ImageQuality {
  final double focusScore;
  final double brightnessScore;
  final bool acceptable;

  const ImageQuality({
    this.focusScore = 1,
    this.brightnessScore = 1,
    this.acceptable = true,
  });
}

class ScannerProvider extends ChangeNotifier {
  final ScanCropUseCase _scanCropUseCase;
  final IAuthRepository _authRepository;

  ScannerProvider(this._scanCropUseCase, this._authRepository);

  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  bool cameraInitialized = false;
  bool torchOn = false;
  bool isAnalysing = false;
  String? capturedImagePath;
  ScanMode mode = ScanMode.camera;
  ImageQuality quality = const ImageQuality();
  ScanPreviewQuality? previewQuality;
  String? errorMessage;
  List<String> batchImagePaths = [];
  bool batchMode = false;

  Timer? _analysisTimer;
  CameraImage? _latestFrame;

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup:
            defaultTargetPlatform == TargetPlatform.iOS
                ? ImageFormatGroup.bgra8888
                : ImageFormatGroup.yuv420,
      );
      await cameraController!.initialize();
      cameraInitialized = true;
      notifyListeners();
      await _startFrameAnalysis();
    } catch (e) {
      errorMessage = 'Camera unavailable: $e';
      notifyListeners();
    }
  }

  Future<void> _startFrameAnalysis() async {
    if (cameraController == null || !cameraInitialized) return;
    if (_analysisTimer != null) return;

    try {
      await cameraController!.startImageStream((image) {
        _latestFrame = image;
      });
    } catch (_) {
      return;
    }

    _analysisTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final frame = _latestFrame;
      if (frame == null) return;
      previewQuality = ImageQualityAnalyzer.previewFromCameraImage(frame);
      notifyListeners();
    });
  }

  Future<void> _stopFrameAnalysis() async {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _latestFrame = null;

    final controller = cameraController;
    if (controller == null || !controller.value.isStreamingImages) return;

    try {
      await controller.stopImageStream();
    } catch (_) {
      // If the driver already stopped the stream, continue.
    }
  }

  Future<void> toggleTorch() async {
    if (cameraController == null || !cameraInitialized) return;
    torchOn = !torchOn;
    await cameraController!.setFlashMode(
      torchOn ? FlashMode.torch : FlashMode.off,
    );
    notifyListeners();
  }

  Future<String?> captureImage() async {
    if (cameraController == null || !cameraInitialized) return null;

    final controller = cameraController!;
    await _stopFrameAnalysis();

    try {
      final file = await controller.takePicture();
      capturedImagePath = file.path;
      notifyListeners();
      return file.path;
    } catch (e) {
      errorMessage = 'Failed to capture image.';
      notifyListeners();
      return null;
    } finally {
      await _startFrameAnalysis();
    }
  }

  Future<String?> pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return null;

    capturedImagePath = file.path;
    notifyListeners();
    return file.path;
  }

  Future<void> addToBatch() async {
    final path = await pickFromGallery();
    if (path != null) {
      addCapturedToBatch(path);
    }
  }

  void addCapturedToBatch(String path) {
    batchImagePaths.add(path);
    notifyListeners();
  }

  void setBatchMode(bool v) {
    batchMode = v;
    batchImagePaths.clear();
    notifyListeners();

    if (v) {
      unawaited(_startFrameAnalysis());
    }
  }

  Future<List<DetectionResult>> analyseBatch() async {
    if (batchImagePaths.isEmpty) return [];

    isAnalysing = true;
    errorMessage = null;
    notifyListeners();

    final userId = _authRepository.currentUser?.id ?? 'guest';
    final results = <DetectionResult>[];
    var failures = 0;

    for (final path in List<String>.from(batchImagePaths)) {
      final result = await _scanCropUseCase(path, userId);
      if (result.isSuccess && result.data != null) {
        results.add(result.data!);
      } else {
        failures++;
      }
    }

    isAnalysing = false;
    if (results.isEmpty) {
      errorMessage = failures > 0
          ? 'Batch analysis failed for all images.'
          : 'No images to analyse.';
    } else if (failures > 0) {
      errorMessage =
          'Analysed ${results.length} of ${batchImagePaths.length} images.';
    }
    batchImagePaths.clear();
    batchMode = false;
    notifyListeners();
    return results;
  }

  Future<void> releaseCamera() async {
    await _stopFrameAnalysis();
    await cameraController?.dispose();
    cameraController = null;
    cameraInitialized = false;
    torchOn = false;
    notifyListeners();
  }

  Future<DetectionResult?> analyseAndSave(String imagePath) async {
    isAnalysing = true;
    errorMessage = null;
    notifyListeners();

    try {
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        final qualityCheck = ImageQualityAnalyzer.analyze(image);
        if (!qualityCheck.isAcceptable) {
          errorMessage = _getQualityErrorMessage(qualityCheck.issue);
          isAnalysing = false;
          notifyListeners();
          return null;
        }
      }

      final userId = _authRepository.currentUser?.id ?? 'guest';
      final result = await _scanCropUseCase(imagePath, userId);

      if (result.isError) {
        errorMessage = result.failure!.message;
        isAnalysing = false;
        notifyListeners();
        return null;
      }

      isAnalysing = false;
      notifyListeners();
      return result.data;
    } catch (e) {
      errorMessage = 'Analysis failed: $e';
      isAnalysing = false;
      notifyListeners();
      return null;
    }
  }

  String _getQualityErrorMessage(ImageQualityIssue? issue) {
    switch (issue) {
      case ImageQualityIssue.blurry:
        return 'Image is too blurry. Please hold the camera steady.';
      case ImageQualityIssue.tooDark:
        return 'Image is too dark. Please use more light or the torch.';
      case ImageQualityIssue.tooBright:
        return 'Image is too bright. Please avoid direct glare.';
      case ImageQualityIssue.tooSmall:
        return 'Image resolution is too low.';
      default:
        return 'Poor image quality detected.';
    }
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    cameraController?.dispose();
    super.dispose();
  }
}
