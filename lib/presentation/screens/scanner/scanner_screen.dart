import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import 'scanner_provider.dart';

/// Equivalent of ScannerScreen.kt
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScannerProvider>().initCamera();
    });
  }

  Future<void> _onCapture(ScannerProvider provider) async {
    final path = await provider.captureImage();
    if (path == null || !mounted) return;
    _navigateToAnalysis(path);
  }

  Future<void> _onGallery(ScannerProvider provider) async {
    final path = await provider.pickFromGallery();
    if (path == null || !mounted) return;
    _navigateToAnalysis(path);
  }

  void _navigateToAnalysis(String path) {
    context.push(
      Uri(path: '/analysing', queryParameters: {'imagePath': path}).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScannerProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Scan Crop',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // Torch
          IconButton(
            icon: Icon(
              provider.torchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () => provider.toggleTorch(),
          ),
          // Batch mode
          IconButton(
            icon: Icon(
              Icons.photo_library_outlined,
              color: provider.batchMode ? colors.accent : Colors.white,
            ),
            onPressed: () => provider.setBatchMode(!provider.batchMode),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview or placeholder
          if (provider.cameraInitialized &&
              provider.cameraController != null)
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

          // Scanning overlay frame
          _ScanOverlay(),

          // Error message
          if (provider.errorMessage != null)
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(provider.errorMessage!,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),

          // Bottom controls
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
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery
                  _ControlButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () => _onGallery(provider),
                  ),

                  // Shutter
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
                        color: provider.isAnalysing
                            ? Colors.white54
                            : Colors.white,
                      ),
                      child: provider.isAnalysing
                          ? const CircularProgressIndicator(
                              color: Colors.black54, strokeWidth: 2)
                          : const Icon(Icons.camera, color: Colors.black87,
                              size: 36),
                    ),
                  ),

                  // Batch add
                  _ControlButton(
                    icon: Icons.add_photo_alternate_outlined,
                    label: 'Batch',
                    onTap: () => provider.addToBatch(),
                  ),
                ],
              ),
            ),
          ),

          // Batch image count badge
          if (provider.batchMode && provider.batchImagePaths.isNotEmpty)
            Positioned(
              top: kToolbarHeight + 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

/// Scan guide frame overlay
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
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

    // Corner brackets
    void drawCorner(Offset o, double dx, double dy) {
      canvas.drawLine(o, o + Offset(dx, 0), paint);
      canvas.drawLine(o, o + Offset(0, dy), paint);
    }

    drawCorner(rect.topLeft, cornerLen, cornerLen);
    drawCorner(rect.topRight, -cornerLen, cornerLen);
    drawCorner(rect.bottomLeft, cornerLen, -cornerLen);
    drawCorner(rect.bottomRight, -cornerLen, -cornerLen);

    // Dim surrounding
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, rect.top), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, rect.bottom, size.width, size.height), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, rect.top, rect.left, rect.bottom), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(rect.right, rect.top, size.width, rect.bottom),
        dimPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton(
      {required this.icon, required this.label, required this.onTap});

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
              color: Colors.white.withOpacity(0.15),
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
