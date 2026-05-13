import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/cropguard_card.dart';

/// Equivalent of OutbreakMapScreen — placeholder with report list
class OutbreakMapScreen extends StatelessWidget {
  const OutbreakMapScreen({super.key});

  static const _sampleReports = [
    _Report(region: 'Greater Accra', disease: 'Tomato Late Blight', cases: 14, date: 'May 10'),
    _Report(region: 'Ashanti', disease: 'Maize Common Rust', cases: 8, date: 'May 8'),
    _Report(region: 'Brong-Ahafo', disease: 'Cassava Mosaic Disease', cases: 22, date: 'May 7'),
    _Report(region: 'Central', disease: 'Potato Early Blight', cases: 5, date: 'May 5'),
    _Report(region: 'Volta', disease: 'Banana Sigatoka', cases: 11, date: 'May 3'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('Outbreak Map',
            style: Theme.of(context).textTheme.titleLarge),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map placeholder
          Container(
            height: 220,
            width: double.infinity,
            color: colors.surfaceVariant,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.map_outlined, size: 72, color: colors.border),
                Positioned(
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      'Live map requires google_maps_flutter setup',
                      style:
                          TextStyle(color: colors.muted, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Recent Disease Reports',
                style: Theme.of(context).textTheme.titleMedium),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sampleReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = _sampleReports[i];
                return CropGuardCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.diseaseBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.warning_amber,
                            color: colors.diseaseRed, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.disease,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600)),
                            Text('${r.region} • ${r.date}',
                                style: TextStyle(
                                    color: colors.muted,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.diseaseBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${r.cases} reports',
                            style: TextStyle(
                                color: colors.diseaseRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Report {
  final String region;
  final String disease;
  final int cases;
  final String date;

  const _Report(
      {required this.region,
      required this.disease,
      required this.cases,
      required this.date});
}
