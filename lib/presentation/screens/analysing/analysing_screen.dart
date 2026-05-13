import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../scanner/scanner_provider.dart';

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
    final id = await provider.analyseAndSave(widget.imagePath);

    if (!mounted) return;

    if (id == null) {
      // Navigate back with error
      context.pop();
      return;
    }

    // Check confidence — if below threshold show low confidence screen
    // (The actual confidence comes from the saved detection)
    context.replace('/result/$id');
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
