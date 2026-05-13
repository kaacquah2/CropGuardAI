import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/ml/disease_info.dart';
import '../../components/cropguard_card.dart';

/// Equivalent of DiseaseLibraryScreen.kt
class DiseaseLibraryScreen extends StatelessWidget {
  const DiseaseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Group entries by cropType (same as Kotlin getLibraryData())
    final grouped = <String, List<String>>{};
    for (final e in DiseaseDatabase.getAllDiseases()) {
      if (e.isHealthy) continue;
      grouped.putIfAbsent(e.cropType, () => []);
      if (!grouped[e.cropType]!.contains(e.displayName)) {
        grouped[e.cropType]!.add(e.displayName);
      }
    }
    final sorted = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: Text('← Back',
                        style: TextStyle(color: colors.muted, fontSize: 14)),
                  ),
                  const SizedBox(height: 8),
                  Text('Disease Library',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                      'Browse all supported crops and their known diseases',
                      style:
                          TextStyle(color: colors.muted, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: sorted.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final entry = sorted[i];
                  return CropGuardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco,
                                color: colors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(entry.key,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map((d) => Padding(
                              padding:
                                  const EdgeInsets.only(top: 3),
                              child: Text('• $d',
                                  style: TextStyle(
                                      color: colors.muted,
                                      fontSize: 13)),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
