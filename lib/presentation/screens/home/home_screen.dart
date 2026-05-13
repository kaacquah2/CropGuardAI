import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/scan_severity.dart';
import '../../../domain/models/detection_result.dart';
import '../../components/cropguard_card.dart';
import '../../components/farm_health_ring.dart';
import '../../components/offline_banner.dart';
import '../../components/section_label.dart';
import '../../components/severity_badge.dart';
import 'home_provider.dart';

/// Equivalent of HomeScreen.kt
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: provider.refresh,
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: colors.surface,
              title: Row(
                children: [
                  Icon(Icons.eco, color: colors.primary, size: 28),
                  const SizedBox(width: 8),
                  Text('CropGuard AI',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: colors.primary)),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined,
                      color: colors.onBackground),
                  onPressed: () {},
                ),
                IconButton(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: colors.primary,
                    child: const Icon(Icons.person,
                        size: 18, color: Colors.white),
                  ),
                  onPressed: () => context.push('/profile'),
                ),
                const SizedBox(width: 8),
              ],
              floating: true,
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OfflineBanner(isOffline: provider.isOffline),

                  // Seasonal alert
                  if (provider.isHighRisk && provider.seasonalAlert.isNotEmpty)
                    _AlertBanner(message: provider.seasonalAlert),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Farm Health + Stats row
                        CropGuardCard(
                          child: Row(
                            children: [
                              FarmHealthRing(
                                percentage: provider.stats.healthScore,
                                size: 100,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Farm Health Score',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const SizedBox(height: 12),
                                    _StatRow(
                                      label: 'Total Scans',
                                      value: provider.stats.totalScans
                                          .toString(),
                                    ),
                                    _StatRow(
                                      label: 'Healthy',
                                      value: provider.stats.healthyScans
                                          .toString(),
                                      color: colors.healthy,
                                    ),
                                    _StatRow(
                                      label: 'Diseased',
                                      value: provider.stats.diseasedScans
                                          .toString(),
                                      color: colors.diseaseRed,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick action — Scan
                        InkWell(
                          onTap: () => context.go('/scanner'),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [colors.primary, colors.primaryLight],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Scan Now',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text('Detect crop diseases instantly',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.8),
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Daily tip
                        if (provider.dailyTip.isNotEmpty)
                          CropGuardCard(
                            backgroundColor: colors.healthyBg,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: colors.healthy, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Tip of the Day',
                                          style: TextStyle(
                                              color: colors.healthy,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(provider.dailyTip,
                                          style: TextStyle(
                                              color: colors.onBackground,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Recent scans
                        SectionLabel(text: 'Recent Scans'),
                        const SizedBox(height: 8),
                        if (provider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (provider.recentScans.isEmpty)
                          _EmptyState(
                            onScan: () => context.go('/scanner'),
                          )
                        else
                          Column(
                            children: provider.recentScans
                                .map((r) => _ScanListTile(
                                    result: r,
                                    onTap: () =>
                                        context.push('/result/${r.id}')))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String message;

  const _AlertBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colors.warning.withOpacity(0.15),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: colors.onBackground, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(color: colors.onBackgroundSecondary, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  color: color ?? colors.onBackground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ScanListTile extends StatelessWidget {
  final DetectionResult result;
  final VoidCallback onTap;

  const _ScanListTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date =
        DateFormat('MMM d, HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(result.timestamp),
        );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: result.isHealthy
                    ? colors.healthyBg
                    : colors.diseaseBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                result.isHealthy ? Icons.check_circle : Icons.warning,
                color: result.isHealthy ? colors.healthy : colors.diseaseRed,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('${result.cropType} • $date',
                      style: TextStyle(
                          color: colors.muted, fontSize: 11)),
                ],
              ),
            ),
            SeverityBadge(severity: result.severity),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.muted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;

  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(Icons.eco_outlined, size: 64, color: colors.border),
          const SizedBox(height: 12),
          Text('No scans yet',
              style: TextStyle(
                  color: colors.onBackgroundSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Scan your first crop to see results here',
              style: TextStyle(color: colors.muted, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onScan,
            icon: Icon(Icons.camera_alt, color: colors.primary),
            label: Text('Start Scanning',
                style: TextStyle(color: colors.primary)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
