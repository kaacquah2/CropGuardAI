import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_quality_analyzer.dart';
import '../../../core/utils/permission_helper.dart';
import '../result/batch_result_provider.dart';
import 'scanner_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _showGuidance = true;
  bool? _permissionsGranted;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  @override
  void deactivate() {
    context.read<ScannerProvider>().releaseCamera();
    super.deactivate();
  }

  Future<void> _checkAndRequestPermissions() async {
    final granted = await PermissionHelper.hasScannerPermissions();
    if (granted) {
      if (mounted) {
        setState(() => _permissionsGranted = true);
        context.read<ScannerProvider>().initCamera();
      }
    } else {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final requested = await PermissionHelper.requestScannerPermissions();
    if (mounted) {
      setState(() => _permissionsGranted = requested);
      if (requested) {
        context.read<ScannerProvider>().initCamera();
      }
    }
  }

  Future<void> _onCapture(ScannerProvider provider) async {
    final path = await provider.captureImage();
    if (path == null || !mounted) return;

    if (provider.batchMode) {
      provider.addCapturedToBatch(path);
      setState(() => _showGuidance = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to batch (${provider.batchImagePaths.length})'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      _navigateToAnalysis(path);
    }
  }

  Future<void> _onGallery(ScannerProvider provider) async {
    final path = await provider.pickFromGallery();
    if (path == null || !mounted) return;

    if (provider.batchMode) {
      provider.addCapturedToBatch(path);
      setState(() => _showGuidance = false);
    } else {
      _navigateToAnalysis(path);
    }
  }

  void _navigateToAnalysis(String path) {
    context.push(
      Uri(path: '/analysing', queryParameters: {'imagePath': path}).toString(),
    );
  }

  Future<void> _onAnalyseBatch(ScannerProvider provider) async {
    final results = await provider.analyseBatch();
    if (!mounted) return;

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Batch analysis failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    context.read<BatchResultProvider>().calculateResults(results);

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }

    context.push('/batch_result');
  }

  void _showBatchExplanation(ScannerProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_motion,
                size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Batch Mode',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Capture multiple leaves and analyze them all at once. '
              'Great for checking a whole field quickly.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.setBatchMode(true);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Turn ON Batch Mode'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScannerProvider>();
    final colors = context.colors;

    if (_permissionsGranted == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (_permissionsGranted == false) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_enhance_outlined,
                      size: 48, color: colors.primary),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Camera & Storage Access Required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'To detect crop diseases, CropGuard AI needs permission to use your camera to scan leaves, and access your gallery to upload existing crop photos.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _requestPermissions,
                    child: const Text(
                      'Grant Permissions',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.go('/home'),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      floatingActionButton: provider.batchMode &&
              provider.batchImagePaths.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: provider.isAnalysing
                  ? null
                  : () => _onAnalyseBatch(provider),
              backgroundColor: colors.primary,
              icon: provider.isAnalysing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.analytics_outlined),
              label: Text(
                provider.isAnalysing
                    ? 'Analysing…'
                    : 'Analyse batch (${provider.batchImagePaths.length})',
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Scan Crop',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              provider.torchOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: provider.torchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () => provider.toggleTorch(),
          ),
          IconButton(
            icon: Icon(
              provider.batchMode
                  ? Icons.auto_awesome_motion
                  : Icons.auto_awesome_motion_outlined,
              color: provider.batchMode ? colors.primary : Colors.white,
            ),
            onPressed: () {
              if (!provider.batchMode) {
                _showBatchExplanation(provider);
              } else {
                provider.setBatchMode(false);
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (provider.cameraInitialized && provider.cameraController != null)
            CameraPreview(provider.cameraController!)
          else
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white54, size: 64),
                    SizedBox(height: 12),
                    Text('Initializing camera…',
                        style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
          _ScanOverlay(showGuidance: _showGuidance),
          if (provider.previewQuality != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 108,
              child: _QualityHud(quality: provider.previewQuality!),
            ),
          if (provider.errorMessage != null)
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () => _onGallery(provider),
                  ),
                  GestureDetector(
                    onTap: provider.isAnalysing
                        ? null
                        : () => _onCapture(provider),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color:
                            provider.isAnalysing ? Colors.white54 : Colors.white,
                      ),
                      child: provider.isAnalysing
                          ? const CircularProgressIndicator(
                              color: Colors.black54, strokeWidth: 2)
                          : Icon(
                              provider.batchMode
                                  ? Icons.add_a_photo
                                  : Icons.camera,
                              color: Colors.black87,
                              size: 36,
                            ),
                    ),
                  ),
                  if (provider.batchMode && provider.batchImagePaths.isNotEmpty)
                    _ControlButton(
                      icon: Icons.analytics_outlined,
                      label: 'Analyse',
                      onTap: provider.isAnalysing
                          ? () {}
                          : () => _onAnalyseBatch(provider),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          if (provider.batchMode && provider.batchImagePaths.isNotEmpty)
            Positioned(
              top: kToolbarHeight + 60,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.batchImagePaths.length} images',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  final bool showGuidance;
  const _ScanOverlay({required this.showGuidance});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: _OverlayPainter(),
          size: Size.infinite,
        ),
        if (showGuidance)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.67,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Centre a single leaf inside the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const padding = 60.0;
    const cornerLen = 24.0;
    final rect = Rect.fromLTRB(
      padding,
      size.height * 0.25,
      size.width - padding,
      size.height * 0.65,
    );

    void drawCorner(Offset o, double dx, double dy) {
      canvas.drawLine(o, o + Offset(dx, 0), paint);
      canvas.drawLine(o, o + Offset(0, dy), paint);
    }

    drawCorner(rect.topLeft, cornerLen, cornerLen);
    drawCorner(rect.topRight, -cornerLen, cornerLen);
    drawCorner(rect.bottomLeft, cornerLen, -cornerLen);
    drawCorner(rect.bottomRight, -cornerLen, -cornerLen);

    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, rect.top), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, rect.bottom, size.width, size.height), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, rect.top, rect.left, rect.bottom), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(rect.right, rect.top, size.width, rect.bottom), dimPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white30),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _QualityHud extends StatelessWidget {
  final ScanPreviewQuality quality;

  const _QualityHud({required this.quality});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: _QualityBadge(
                  label: 'Lighting',
                  band: quality.lighting,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QualityBadge(
                  label: 'Focus',
                  band: quality.focus,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QualityBadge(
                  label: 'Placement',
                  band: quality.placement,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final String label;
  final PreviewQualityBand band;

  const _QualityBadge({
    required this.label,
    required this.band,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (band) {
      PreviewQualityBand.good => const Color(0xFF4CAF50),
      PreviewQualityBand.fair => const Color(0xFFFFC107),
      PreviewQualityBand.poor => const Color(0xFFF44336),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            switch (band) {
              PreviewQualityBand.good => 'Good',
              PreviewQualityBand.fair => 'Fair',
              PreviewQualityBand.poor => 'Poor',
            },
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
