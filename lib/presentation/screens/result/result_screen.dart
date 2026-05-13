import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/scan_severity.dart';
import '../../components/confidence_bar.dart';
import '../../components/cropguard_card.dart';
import '../../components/primary_button.dart';
import '../../components/section_label.dart';
import '../../components/severity_badge.dart';
import '../../components/status_badge.dart';
import '../../../data/remote/firebase_auth_service.dart';
import '../../../core/di/service_locator.dart';
import 'result_provider.dart';

const double _kLowConfidenceThreshold = 0.60;

/// Equivalent of ResultScreen.kt
class ResultScreen extends StatefulWidget {
  final int detectionId;

  const ResultScreen({super.key, required this.detectionId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultProvider>().load(widget.detectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResultProvider>();
    final colors = context.colors;

    if (provider.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    if (provider.result == null) {
      return Scaffold(
        body: Center(child: Text(provider.errorMessage ?? 'Error')),
      );
    }

    final result = provider.result!;

    // Route to low confidence screen if confidence is below threshold
    if (result.confidence < _kLowConfidenceThreshold) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.replace(Uri(
          path: '/low_confidence',
          queryParameters: {
            'confidence': result.confidence.toString(),
            'imagePath': result.imagePath,
          },
        ).toString());
      });
      return const SizedBox.shrink();
    }

    final isHealthy = result.isHealthy;
    final headerColor = isHealthy ? colors.healthy : colors.diseaseRed;
    final headerBg = isHealthy ? colors.healthyBg : colors.diseaseBg;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        title: Text(isHealthy ? 'Healthy Crop' : 'Disease Detected',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (File(result.imagePath).existsSync())
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Image.file(File(result.imagePath),
                    fit: BoxFit.cover),
              ),

            // Result header band
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: headerBg,
              child: Row(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.warning_amber,
                    color: headerColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: headerColor,
                                    fontWeight: FontWeight.bold)),
                        Text(result.cropType,
                            style: TextStyle(
                                color: headerColor.withOpacity(0.8),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  SeverityBadge(severity: result.severity),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confidence bar
                  CropGuardCard(
                    child: ConfidenceBar(
                      confidence: result.confidence,
                      color: headerColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cause
                  if (!isHealthy && result.cause.isNotEmpty) ...[
                    SectionLabel(text: 'Cause'),
                    const SizedBox(height: 8),
                    CropGuardCard(
                      child: Text(result.cause,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Treatments
                  if (result.treatments.isNotEmpty) ...[
                    SectionLabel(
                        text: isHealthy
                            ? 'Crop Care Tips'
                            : 'Treatment Steps'),
                    const SizedBox(height: 8),
                    CropGuardCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result.treatments
                            .asMap()
                            .entries
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        margin:
                                            const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: headerColor.withOpacity(0.15),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${e.key + 1}',
                                            style: TextStyle(
                                                color: headerColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(e.value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Actions
                  if (!isHealthy) ...[
                    PrimaryButton(
                      text: 'Request Expert Help',
                      icon: Icons.support_agent,
                      isLoading: provider.isRequestingExpert,
                      onPressed: provider.expertRequestSent
                          ? null
                          : () => _showExpertDialog(context, provider),
                    ),
                    const SizedBox(height: 10),
                  ],

                  PrimaryButton(
                    text: 'Scan Another Crop',
                    icon: Icons.camera_alt,
                    onPressed: () => context.go('/scanner'),
                  ),
                  const SizedBox(height: 10),

                  // Feedback
                  if (!provider.feedbackSent)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(Icons.feedback_outlined,
                          color: colors.muted, size: 16),
                      label: Text('Was this diagnosis wrong?',
                          style: TextStyle(
                              color: colors.onBackgroundSecondary,
                              fontSize: 13)),
                      onPressed: () =>
                          _showFeedbackDialog(context, provider),
                    ),
                  if (provider.feedbackSent)
                    Center(
                      child: Text('Thanks for your feedback!',
                          style: TextStyle(
                              color: colors.healthy, fontSize: 13)),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpertDialog(BuildContext ctx, ResultProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Expert Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Describe your situation and an agronomist will respond.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'My tomatoes are showing…',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final uid =
                  sl<FirebaseAuthService>().currentUserId;
              provider.requestExpertHelp(
                  userId: uid, message: controller.text);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext ctx, ResultProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text('Correct the Diagnosis'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Correct disease name or label',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final uid =
                  sl<FirebaseAuthService>().currentUserId;
              provider.submitFeedback(
                userId: uid,
                correctedLabel: controller.text,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
