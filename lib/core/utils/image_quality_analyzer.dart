import 'dart:math';
import 'package:image/image.dart' as img;

/// Lightweight pre-scan checks: Laplacian variance (blur proxy), mean luminance, minimum resolution.
class ImageQualityAnalyzer {
  static const int _analysisMaxSide = 320;
  static const int _minShortSidePx = 160;
  static const double _minLaplacianVariance = 38.0;
  static const double _minMeanLuminance = 0.11;
  static const double _maxMeanLuminance = 0.90;

  static ImageQualityResult analyze(img.Image image) {
    final w = image.width;
    final h = image.height;
    final shortSide = min(w, h);

    if (shortSide < _minShortSidePx) {
      return const ImageQualityResult(false, ImageQualityIssue.tooSmall);
    }

    final scaled = _scaleForAnalysis(image);
    final gray = _toGrayscale(scaled);

    final height = gray.length;
    final width = gray[0].length;

    final meanLum = _meanLuminance(gray, width, height);
    if (meanLum < _minMeanLuminance) {
      return const ImageQualityResult(false, ImageQualityIssue.tooDark);
    }
    if (meanLum > _maxMeanLuminance) {
      return const ImageQualityResult(false, ImageQualityIssue.tooBright);
    }

    final lapVar = _laplacianVariance(gray, width, height);
    if (lapVar < _minLaplacianVariance) {
      return const ImageQualityResult(false, ImageQualityIssue.blurry);
    }

    return const ImageQualityResult(true, null);
  }

  static ScanPreviewQuality previewScanQuality(img.Image image) {
    final w = image.width;
    final h = image.height;
    final shortSide = min(w, h);

    final scaled = _scaleForAnalysis(image);
    final gray = _toGrayscale(scaled);

    final gh = gray.length;
    final gw = gray[0].length;

    final meanLum = _meanLuminance(gray, gw, gh);
    final lapVar = _laplacianVariance(gray, gw, gh);

    final lighting = _getBand(meanLum, 0.12, 0.92, 0.15, 0.82);
    final focus = _getFocusBand(lapVar);
    final coverage = _getCoverageBand(shortSide);

    return ScanPreviewQuality(lighting, focus, coverage);
  }

  static PreviewQualityBand _getBand(double val, double minPoor, double maxPoor,
      double minGood, double maxGood) {
    if (val < minPoor || val > maxPoor) return PreviewQualityBand.poor;
    if (val >= minGood && val <= maxGood) return PreviewQualityBand.good;
    return PreviewQualityBand.fair;
  }

  static PreviewQualityBand _getFocusBand(double lapVar) {
    if (lapVar < 28.0) return PreviewQualityBand.poor;
    if (lapVar >= 65.0) return PreviewQualityBand.good;
    return PreviewQualityBand.fair;
  }

  static PreviewQualityBand _getCoverageBand(int shortSide) {
    if (shortSide < 280) return PreviewQualityBand.poor;
    if (shortSide < 480) return PreviewQualityBand.fair;
    return PreviewQualityBand.good;
  }

  static img.Image _scaleForAnalysis(img.Image image) {
    final longest = max(image.width, image.height);
    if (longest <= _analysisMaxSide) return image;
    return img.copyResize(image,
        width: image.width > image.height ? _analysisMaxSide : null,
        height: image.height >= image.width ? _analysisMaxSide : null);
  }

  static List<List<int>> _toGrayscale(img.Image image) {
    final w = image.width;
    final h = image.height;
    final gray = List.generate(h, (_) => List.filled(w, 0));

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        gray[y][x] = (0.299 * r + 0.587 * g + 0.114 * b).toInt().clamp(0, 255);
      }
    }
    return gray;
  }

  static double _meanLuminance(List<List<int>> gray, int width, int height) {
    var sum = 0.0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        sum += gray[y][x] / 255.0;
      }
    }
    return sum / (width * height);
  }

  static double _laplacianVariance(
      List<List<int>> gray, int width, int height) {
    if (width < 3 || height < 3) return 0.0;
    var sum = 0.0;
    var sumSq = 0.0;
    var count = 0;

    for (var y = 1; y < height - 1; y++) {
      for (var x = 1; x < width - 1; x++) {
        final center = gray[y][x];
        final lap = (gray[y - 1][x] +
                gray[y + 1][x] +
                gray[y][x - 1] +
                gray[y][x + 1] -
                4 * center)
            .toDouble();
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 0.0;
    final mean = sum / count;
    return (sumSq / count) - mean * mean;
  }
}

class ImageQualityResult {
  final bool isAcceptable;
  final ImageQualityIssue? issue;

  const ImageQualityResult(this.isAcceptable, this.issue);
}

enum ImageQualityIssue { blurry, tooDark, tooBright, tooSmall }

enum PreviewQualityBand { good, fair, poor }

class ScanPreviewQuality {
  final PreviewQualityBand lighting;
  final PreviewQualityBand focus;
  final PreviewQualityBand coverage;

  const ScanPreviewQuality(this.lighting, this.focus, this.coverage);
}
