import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/confidence_bar.dart';
import '../../components/cropguard_card.dart';
import '../../components/primary_button.dart';

/// Equivalent of LowConfidenceScreen.kt
class LowConfidenceScreen extends StatelessWidget {
  final double confidence;
  final String imagePath;

  const LowConfidenceScreen({
    super.key,
    required this.confidence,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pct = (confidence * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.lowConfidence,
        foregroundColor: Colors.white,
        title: const Text('Low Confidence',
            style: TextStyle(color: Colors.white)),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go('/scanner'),
        ),
      ),
      backgroundColor: colors.background,
      body: Column(
        children: [
          // Blurred image preview
          if (File(imagePath).existsSync())
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), BlendMode.srcOver),
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline,
                      size: 56, color: colors.lowConfidence),
                  const SizedBox(height: 16),

                  CropGuardCard(
                    backgroundColor: colors.lowConfidenceBg,
                    borderColor: colors.lowConfidence,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Low Confidence Result',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: colors.lowConfidence)),
                        const SizedBox(height: 8),
                        Text(
                          'The AI detected a possible disease but is only $pct% '
                          'confident. This result may not be accurate.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ConfidenceBar(
                          confidence: confidence,
                          color: colors.lowConfidence,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'For a more accurate result, try:\n'
                    '• Taking a clearer, closer photo\n'
                    '• Ensuring good lighting\n'
                    '• Focusing on a single leaf with visible symptoms',
                    style: TextStyle(
                        color: colors.onBackgroundSecondary, fontSize: 14,
                        height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    text: 'Try Again',
                    icon: Icons.camera_alt,
                    onPressed: () => context.go('/scanner'),
                  ),
                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose from Gallery'),
                    onPressed: () => context.go('/scanner'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
