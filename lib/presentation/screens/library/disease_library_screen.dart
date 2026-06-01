import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/ml/disease_info.dart';
import '../../components/cropguard_card.dart';
import '../../components/severity_badge.dart';

/// Browse diseases by crop with search and detail sheets.
class DiseaseLibraryScreen extends StatefulWidget {
  const DiseaseLibraryScreen({super.key});

  @override
  State<DiseaseLibraryScreen> createState() => _DiseaseLibraryScreenState();
}

class _DiseaseLibraryScreenState extends State<DiseaseLibraryScreen> {
  String _query = '';

  static Map<String, List<DiseaseInfoEntry>> _groupedByCrop() {
    final grouped = <String, List<DiseaseInfoEntry>>{};
    for (final e in DiseaseDatabase.getAllDiseases()) {
      if (e.isHealthy) continue;
      grouped.putIfAbsent(e.cropType, () => []);
      if (!grouped[e.cropType]!.any((x) => x.displayName == e.displayName)) {
        grouped[e.cropType]!.add(e);
      }
    }
    return grouped;
  }

  Map<String, List<DiseaseInfoEntry>> _filteredGroups() {
    final grouped = _groupedByCrop();
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return grouped;

    final filtered = <String, List<DiseaseInfoEntry>>{};
    for (final entry in grouped.entries) {
      final cropMatch = entry.key.toLowerCase().contains(q);
      final diseases = entry.value.where((d) {
        return cropMatch ||
            d.displayName.toLowerCase().contains(q) ||
            d.cropType.toLowerCase().contains(q) ||
            d.label.toLowerCase().contains(q);
      }).toList();
      if (diseases.isNotEmpty) {
        filtered[entry.key] = diseases;
      }
    }
    return filtered;
  }

  void _showDiseaseDetail(DiseaseInfoEntry entry) {
    final info = DiseaseDatabase.getInfo(entry.label);
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          info.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SeverityBadge(severity: info.severity),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(info.cropType,
                      style: TextStyle(color: colors.muted, fontSize: 13)),
                  if (info.cause.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Cause',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(info.cause,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  if (info.treatments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Treatment',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...info.treatments.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ',
                                style: TextStyle(color: colors.primary)),
                            Expanded(
                              child: Text(t,
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sorted = _filteredGroups().entries.toList()
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
                      style: TextStyle(color: colors.muted, fontSize: 13)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search crop or disease…',
                      prefixIcon: Icon(Icons.search, color: colors.muted),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sorted.isEmpty
                  ? Center(
                      child: Text(
                        'No diseases match your search.',
                        style: TextStyle(color: colors.muted),
                      ),
                    )
                  : ListView.separated(
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
                              ...entry.value.map((d) => InkWell(
                                    onTap: () => _showDiseaseDetail(d),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              d.displayName,
                                              style: TextStyle(
                                                color: colors.onSurface,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.chevron_right,
                                              size: 18, color: colors.muted),
                                        ],
                                      ),
                                    ),
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
