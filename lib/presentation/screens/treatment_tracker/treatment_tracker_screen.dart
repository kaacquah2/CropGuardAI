import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/cropguard_card.dart';
import '../../components/primary_button.dart';

class _Treatment {
  final String crop;
  final String disease;
  final String step;
  final bool completed;
  final String dueDate;

  const _Treatment({
    required this.crop,
    required this.disease,
    required this.step,
    this.completed = false,
    required this.dueDate,
  });
}

/// Equivalent of TreatmentTrackerScreen.kt
class TreatmentTrackerScreen extends StatefulWidget {
  const TreatmentTrackerScreen({super.key});

  @override
  State<TreatmentTrackerScreen> createState() =>
      _TreatmentTrackerScreenState();
}

class _TreatmentTrackerScreenState extends State<TreatmentTrackerScreen> {
  final List<_Treatment> _plans = [
    const _Treatment(
        crop: 'Tomato',
        disease: 'Late Blight',
        step: 'Apply metalaxyl fungicide to all plants',
        dueDate: 'Today',
        completed: false),
    const _Treatment(
        crop: 'Tomato',
        disease: 'Late Blight',
        step: 'Remove visibly infected leaves',
        dueDate: 'Tomorrow',
        completed: true),
    const _Treatment(
        crop: 'Maize',
        disease: 'Common Rust',
        step: 'Scout fields for rust progression',
        dueDate: 'May 15',
        completed: false),
  ];

  void _toggleComplete(int i) {
    setState(() {
      final t = _plans[i];
      _plans[i] = _Treatment(
        crop: t.crop,
        disease: t.disease,
        step: t.step,
        dueDate: t.dueDate,
        completed: !t.completed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pending = _plans.where((t) => !t.completed).length;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Treatment Tracker',
                style: Theme.of(context).textTheme.titleLarge),
            Text('$pending pending tasks',
                style: TextStyle(
                    color: colors.muted, fontSize: 12)),
          ],
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: _plans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 72, color: colors.healthy),
                  const SizedBox(height: 12),
                  Text('All caught up!',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('No pending treatment plans',
                      style: TextStyle(color: colors.muted)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = _plans[i];
                return CropGuardCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: t.completed,
                        activeColor: colors.primary,
                        onChanged: (_) => _toggleComplete(i),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${t.crop} — ${t.disease}',
                                style: TextStyle(
                                    color: colors.onBackgroundSecondary,
                                    fontSize: 11)),
                            Text(
                              t.step,
                              style: TextStyle(
                                color: t.completed
                                    ? colors.muted
                                    : colors.onBackground,
                                decoration: t.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 12, color: colors.muted),
                                const SizedBox(width: 4),
                                Text(t.dueDate,
                                    style: TextStyle(
                                        color: colors.muted,
                                        fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
