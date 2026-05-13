import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
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
          IconButton(
            icon: Icon(
              provider.comparisonMode
                  ? Icons.compare_arrows
                  : Icons.compare_arrows_outlined,
              color: provider.comparisonMode
                  ? colors.primary
                  : colors.onBackground,
            ),
            onPressed: provider.toggleComparison,
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
                              selected:
                                  provider.selectedIds.contains(r.id),
                              onTap: provider.comparisonMode
                                  ? () => provider.toggleSelection(r.id)
                                  : () => context.push('/result/${r.id}'),
                              onDelete: () => provider.deleteResult(r.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
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
