import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../components/confidence_bar.dart';
import '../../components/cropguard_card.dart';
import '../../components/primary_button.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/remote/firestore_service.dart';
import '../../../data/remote/firebase_auth_service.dart';

class LowConfidenceScreen extends StatefulWidget {
  final double confidence;
  final String imagePath;

  const LowConfidenceScreen({
    super.key,
    required this.confidence,
    required this.imagePath,
  });

  @override
  State<LowConfidenceScreen> createState() => _LowConfidenceScreenState();
}

class _LowConfidenceScreenState extends State<LowConfidenceScreen> {
  bool _reportSent = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pct = (widget.confidence * 100).toInt();

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
          if (File(widget.imagePath).existsSync())
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.4), BlendMode.srcOver),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
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
                                ?? const TextStyle()
                                .copyWith(color: colors.lowConfidence)),
                        const SizedBox(height: 8),
                        Text(
                          'The AI detected a possible disease but is only $pct% '
                          'confident. This result may not be accurate.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ConfidenceBar(
                          confidence: widget.confidence,
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
                  const SizedBox(height: 12),

                  if (!_reportSent)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.feedback_outlined, size: 20),
                      label: const Text('My crop is not in the list'),
                      onPressed: () => _showReportDialog(context),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Report submitted. Thank you!',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final cropController = TextEditingController();
    final symptomsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Missing Crop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('What crop are you scanning? This helps us train our AI.'),
            const SizedBox(height: 16),
            TextField(
              controller: cropController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: symptomsController,
              decoration: const InputDecoration(
                labelText: 'Observed Symptoms (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final crop = cropController.text;
              final symptoms = symptomsController.text;
              Navigator.pop(ctx);
              
              final uid = sl<FirebaseAuthService>().currentUserId;
              await sl<FirestoreService>().submitCropNotFound(
                userId: uid,
                suggestedCrop: crop,
                observedSymptoms: symptoms,
                imagePath: widget.imagePath,
              );
              
              if (mounted) {
                setState(() => _reportSent = true);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
