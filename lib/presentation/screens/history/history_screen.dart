import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/scan_report_pdf_exporter.dart';
import '../../../domain/models/detection_result.dart';
import '../../components/severity_badge.dart';
import 'history_provider.dart';

/// Equivalent of HistoryScreen.kt
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('Scan History',
            style: Theme.of(context).textTheme.titleLarge),
        actions: [
          if (provider.filtered.isNotEmpty)
            Semantics(
              label: 'Export scan history',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () async {
                  final first = provider.filtered.first;
                  await ScanReportPdfExporter.shareScanReport(first);
                },
                tooltip: 'Share latest scan report',
              ),
            ),
          PopupMenuButton<HistorySort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: provider.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: HistorySort.dateNewest,
                child: Text('Newest first'),
              ),
              PopupMenuItem(
                value: HistorySort.dateOldest,
                child: Text('Oldest first'),
              ),
              PopupMenuItem(
                value: HistorySort.severity,
                child: Text('By confidence'),
              ),
              PopupMenuItem(
                value: HistorySort.cropType,
                child: Text('By crop type'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              provider.comparisonMode ? Icons.close : Icons.compare_arrows,
              color: provider.comparisonMode ? colors.primary : colors.onBackground,
            ),
            onPressed: provider.toggleComparisonMode,
            tooltip: 'Comparison Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Search by crop or disease…',
                prefixIcon: Icon(Icons.search, color: colors.muted),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: HistoryFilter.values.map((f) {
                final labels = {
                  HistoryFilter.all: 'All',
                  HistoryFilter.healthy: 'Healthy',
                  HistoryFilter.diseased: 'Diseased',
                };
                final isSelected = provider.filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(labels[f]!),
                    selected: isSelected,
                    onSelected: (_) => provider.setFilter(f),
                    selectedColor: colors.primary,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : colors.onBackground,
                    ),
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Results list
          Expanded(
            child: provider.isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: colors.primary))
                : provider.filtered.isEmpty
                    ? _EmptyHistory()
                    : RefreshIndicator(
                        onRefresh: provider.load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final r = provider.filtered[i];
                            return _HistoryTile(
                              result: r,
                              comparisonMode: provider.comparisonMode,
                              selected: provider.selectedIds.contains(r.id),
                              onTap: () {
                                if (provider.comparisonMode) {
                                  provider.toggleSelection(r.id);
                                } else {
                                  context.push('/result/${r.id}');
                                }
                              },
                              onDelete: () {
                                final deletedItem = r;
                                provider.deleteResult(r.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Scan deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () =>
                                          provider.restoreDetection(deletedItem),
                                    ),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: provider.comparisonMode && provider.selectedIds.length == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                _showComparisonDialog(context, provider);
              },
              label: const Text('Compare Scans'),
              icon: const Icon(Icons.compare),
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final DetectionResult result;
  final bool comparisonMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.result,
    required this.comparisonMode,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = DateFormat('MMM d, yyyy HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(result.timestamp),
    );

    return Dismissible(
      key: ValueKey(result.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? colors.healthyBg : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: File(result.imagePath).existsSync()
                    ? Image.file(File(result.imagePath),
                        width: 56, height: 56, fit: BoxFit.cover)
                    : Container(
                        width: 56,
                        height: 56,
                        color: colors.surfaceVariant,
                        child:
                            Icon(Icons.image_not_supported, color: colors.muted),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(result.cropType,
                        style: TextStyle(
                            color: colors.muted, fontSize: 12)),
                    Text(date,
                        style: TextStyle(
                            color: colors.muted, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SeverityBadge(severity: result.severity),
                  const SizedBox(height: 4),
                  Text(
                      '${(result.confidence * 100).toInt()}%',
                      style: TextStyle(
                          color: colors.onBackgroundSecondary,
                          fontSize: 11)),
                ],
              ),
              if (comparisonMode)
                Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(),
                  activeColor: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: colors.border),
          const SizedBox(height: 12),
          Text('No scans found',
              style: TextStyle(
                  color: colors.onBackgroundSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Scan a crop to build your history',
              style: TextStyle(color: colors.muted, fontSize: 13)),
        ],
      ),
    );
  }
}

void _showComparisonDialog(BuildContext context, HistoryProvider provider) {
  final colors = context.colors;
  final scans = provider.selectedScans;
  if (scans.length < 2) return;

  final scan1 = scans[0];
  final scan2 = scans[1];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle bar
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Compare Scans',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Scan Column
                  Expanded(
                    child: _ComparisonColumn(scan: scan1),
                  ),
                  const SizedBox(width: 16),
                  // Divider
                  Container(
                    width: 1,
                    height: 500,
                    color: colors.border,
                  ),
                  const SizedBox(width: 16),
                  // Second Scan Column
                  Expanded(
                    child: _ComparisonColumn(scan: scan2),
                  ),
                ],
              ),
            ),
          ),
          // Close button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
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
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close Comparison',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ComparisonColumn extends StatelessWidget {
  final DetectionResult scan;

  const _ComparisonColumn({required this.scan});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = DateFormat('MMM d, yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(scan.timestamp),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: File(scan.imagePath).existsSync()
              ? Image.file(
                  File(scan.imagePath),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 140,
                  width: double.infinity,
                  color: colors.surfaceVariant,
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
        ),
        const SizedBox(height: 16),
        Text(
          scan.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          scan.cropType,
          style: TextStyle(
            color: colors.muted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Severity',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        SeverityBadge(severity: scan.severity),
        const SizedBox(height: 16),
        const Text(
          'Confidence',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(scan.confidence * 100).toInt()}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Scan Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: TextStyle(
            fontSize: 14,
            color: colors.onBackgroundSecondary,
          ),
        ),
      ],
    );
  }
}
