import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/cropguard_card.dart';
import 'treatment_tracker_provider.dart';

class TreatmentTrackerScreen extends StatelessWidget {
  const TreatmentTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Consumer<TreatmentTrackerProvider>(
      builder: (context, provider, child) {
        final plans = provider.plans;
        final pending = plans.where((t) => !t.completed).length;
        final completed = plans.where((t) => t.completed).length;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.surface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Treatment Tracker',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(
                  pending == 0
                      ? 'All caught up!'
                      : '$pending pending • $completed done',
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ],
            ),
            leading: BackButton(onPressed: () => context.pop()),
            actions: [
              if (plans.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: colors.muted),
                  onPressed: provider.refresh,
                  tooltip: 'Refresh',
                ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
                  ? Center(
                      child: Text(
                        'Error: ${provider.error}',
                        style: TextStyle(color: colors.diseaseRed),
                      ),
                    )
                  : plans.isEmpty
                      ? _EmptyState()
                      : RefreshIndicator(
                          onRefresh: provider.refresh,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: plans.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final t = plans[i];
                              return Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: colors.diseaseRed.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.delete_outline,
                                      color: colors.diseaseRed),
                                ),
                                onDismissed: (_) => provider.deletePlan(t.id),
                                child: CropGuardCard(
                                  backgroundColor: t.completed
                                      ? colors.healthyBg.withValues(alpha: 0.4)
                                      : colors.surface,
                                  borderColor: t.completed
                                      ? colors.healthy.withValues(alpha: 0.3)
                                      : colors.border,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () => provider.toggleComplete(i),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          width: 28,
                                          height: 28,
                                          margin: const EdgeInsets.only(
                                              top: 2, right: 12),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: t.completed
                                                ? colors.healthy
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: t.completed
                                                  ? colors.healthy
                                                  : colors.border,
                                              width: 2,
                                            ),
                                          ),
                                          child: t.completed
                                              ? const Icon(Icons.check,
                                                  size: 16,
                                                  color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${t.cropType} — ${t.diseaseName}',
                                              style: TextStyle(
                                                color: colors
                                                    .onBackgroundSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              t.step,
                                              style: TextStyle(
                                                color: t.completed
                                                    ? colors.muted
                                                    : colors.onBackground,
                                                decoration: t.completed
                                                    ? TextDecoration
                                                        .lineThrough
                                                    : null,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 11,
                                                    color: colors.muted),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Due ${t.dueDateFormatted}',
                                                  style: TextStyle(
                                                    color: colors.muted,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 72, color: colors.healthy),
          const SizedBox(height: 12),
          Text('No treatment plans yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'After a scan, tap "Track Treatment" on the result screen.',
            style: TextStyle(color: colors.muted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
