import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/scan_feedback_helper.dart';
import '../../../core/utils/tts_manager.dart';
import '../scanner/scanner_provider.dart';
import '../settings/language_provider.dart';

/// Intermediate screen that runs TFLite inference on the captured image
/// Equivalent of the "analyzing" state in ScannerViewModel / ScannerScreen
class AnalisingScreen extends StatefulWidget {
  final String imagePath;

  const AnalisingScreen({super.key, required this.imagePath});

  @override
  State<AnalisingScreen> createState() => _AnalisingScreenState();
}

class _AnalisingScreenState extends State<AnalisingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _analyse();
  }

  Future<void> _analyse() async {
    final provider = context.read<ScannerProvider>();
    final result = await provider.analyseAndSave(widget.imagePath);

    if (!mounted) return;

    if (result == null) {
      final errorMsg = provider.errorMessage ?? 'Analysis failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMsg,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      context.pop();
      return;
    }

    final lang = context.read<LanguageProvider>().currentLanguage.code;
    final summary = result.isHealthy
        ? '${result.displayName} looks healthy.'
        : '${result.displayName} detected.';

    await ScanFeedbackHelper.playScanComplete(
      isHealthy: result.isHealthy,
      soundEnabled: true,
      hapticEnabled: true,
    );

    if (!mounted) return;

    await TtsManager().speak(summary, languageCode: lang);

    if (!mounted) return;

    const double kLowConfidenceThreshold = 0.60;

    if (result.confidence < kLowConfidenceThreshold) {
      context.replace(Uri(
        path: '/low_confidence',
        queryParameters: {
          'confidence': result.confidence.toString(),
          'imagePath': result.imagePath,
        },
      ).toString());
    } else {
      context.replace('/result/${result.id}');
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Image preview
            if (File(widget.imagePath).existsSync())
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _spin,
                        child: Icon(Icons.eco, size: 72, color: colors.primary),
                      ),
                      const SizedBox(height: 24),
                      Text('Analysing…',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Running AI disease detection on your crop image.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: colors.onBackgroundSecondary,
                            fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      LinearProgressIndicator(
                        backgroundColor: colors.border,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.primary),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
