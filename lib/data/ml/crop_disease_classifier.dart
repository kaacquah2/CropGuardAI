import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'disease_info.dart';

/// Classification result from the TFLite model
class ClassificationResult {
  final String label;
  final double confidence;
  final bool isHealthy;
  final DiseaseInfoEntry diseaseInfo;

  const ClassificationResult({
    required this.label,
    required this.confidence,
    required this.isHealthy,
    required this.diseaseInfo,
  });
}

/// Equivalent of CropDiseaseClassifier.kt — wraps tflite_flutter
class CropDiseaseClassifier {
  static const int inputSize = 224;
  static const double confidenceThreshold = 0.60;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  /// Initialise the model and labels. Must be called before [classify].
  Future<void> loadModel() async {
    if (_isLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/cropguard_plant_disease.tflite');
      final labelsData =
          await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      _isLoaded = true;
    } catch (e) {
      // Model file not present — graceful degradation
      _isLoaded = false;
    }
  }

  bool get isLoaded => _isLoaded;

  /// Classify an image from a file path.
  /// Returns null if the model is not loaded.
  Future<ClassificationResult?> classifyFromPath(String imagePath) async {
    if (!_isLoaded) await loadModel();
    if (!_isLoaded || _interpreter == null) return null;

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    return _runInference(decoded);
  }

  /// Classify from raw RGBA bytes (used for live camera frames).
  Future<ClassificationResult?> classifyFromBytes(
      Uint8List rgbaBytes, int width, int height) async {
    if (!_isLoaded) await loadModel();
    if (!_isLoaded || _interpreter == null) return null;

    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgbaBytes.buffer,
      format: img.Format.uint8,
      numChannels: 4,
    );
    return _runInference(image);
  }

  ClassificationResult _runInference(img.Image raw) {
    // Resize to 224×224
    final resized = img.copyResize(raw, width: inputSize, height: inputSize);

    // Normalise to [0,1] float32 — matches ImagePreprocessor.kt
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    final outputBuffer =
        List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

    _interpreter!.run(input, outputBuffer);

    final scores = (outputBuffer[0] as List).cast<double>();
    int topIndex = 0;
    double topScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > topScore) {
        topScore = scores[i];
        topIndex = i;
      }
    }

    final topLabel = topIndex < _labels.length
        ? _labels[topIndex]
        : 'Unknown';
    final info = DiseaseDatabase.getInfo(topLabel);

    return ClassificationResult(
      label: topLabel,
      confidence: topScore,
      isHealthy: info.isHealthy,
      diseaseInfo: info,
    );
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
