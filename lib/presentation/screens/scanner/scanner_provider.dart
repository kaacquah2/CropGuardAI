import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

import '../../../domain/usecases/scanner/scan_crop_usecase.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../core/utils/image_quality_analyzer.dart';
import 'package:image/image.dart' as img;

enum ScanMode { camera, gallery }

class ImageQuality {
  final double focusScore; // 0–1
  final double brightnessScore; // 0–1
  final bool acceptable;

  const ImageQuality({
    this.focusScore = 1,
    this.brightnessScore = 1,
    this.acceptable = true,
  });
}

/// Refactored ScannerProvider using Clean Architecture
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
  String? errorMessage;

  // Batch scan
  List<String> batchImagePaths = [];
  bool batchMode = false;

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
      );
      await cameraController!.initialize();
      cameraInitialized = true;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Camera unavailable: $e';
      notifyListeners();
    }
  }

  Future<void> toggleTorch() async {
    if (cameraController == null || !cameraInitialized) return;
    torchOn = !torchOn;
    await cameraController!.setFlashMode(
        torchOn ? FlashMode.torch : FlashMode.off);
    notifyListeners();
  }

  Future<String?> captureImage() async {
    if (cameraController == null || !cameraInitialized) return null;
    try {
      final file = await cameraController!.takePicture();
      capturedImagePath = file.path;
      notifyListeners();
      return file.path;
    } catch (e) {
      errorMessage = 'Failed to capture image.';
      notifyListeners();
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null) return null;
    capturedImagePath = file.path;
    notifyListeners();
    return file.path;
  }

  Future<void> addToBatch() async {
    final path = await pickFromGallery();
    if (path != null) {
      batchImagePaths.add(path);
      notifyListeners();
    }
  }

  void setBatchMode(bool v) {
    batchMode = v;
    batchImagePaths.clear();
    notifyListeners();
  }

  /// Classify a single image and save to DB; returns saved detection ID.
  Future<int?> analyseAndSave(String imagePath) async {
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
      return result.data?.id;
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
    cameraController?.dispose();
    super.dispose();
  }
}

