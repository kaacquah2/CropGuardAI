import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/cropguard_card.dart';

class _Badge {
  final String icon;
  final String title;
  final String subtitle;
  final bool unlocked;

  const _Badge(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.unlocked = false});
}

/// Achievements screen — equivalent of the achievements section in the Kotlin codebase
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _badges = [
    _Badge(icon: '🌿', title: 'First Scan', subtitle: 'Complete your first crop scan', unlocked: true),
    _Badge(icon: '📸', title: 'Scan Streak', subtitle: 'Scan crops 7 days in a row'),
    _Badge(icon: '🔬', title: 'Disease Detective', subtitle: 'Identify 10 different diseases'),
    _Badge(icon: '🏆', title: 'Pro Farmer', subtitle: 'Complete 100 scans', unlocked: true),
    _Badge(icon: '🌾', title: 'Harvest Hero', subtitle: 'Track a full harvest cycle'),
    _Badge(icon: '🤝', title: 'Community Voice', subtitle: 'Post 5 updates to the community'),
    _Badge(icon: '⚡', title: 'Quick Responder', subtitle: 'Act on a treatment plan within 24 hours'),
    _Badge(icon: '🌍', title: 'Map Reporter', subtitle: 'Submit 3 outbreak reports'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('Achievements',
            style: Theme.of(context).textTheme.titleLarge),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _badges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final b = _badges[i];
          return Opacity(
            opacity: b.unlocked ? 1.0 : 0.45,
            child: CropGuardCard(
              backgroundColor: b.unlocked ? colors.healthyBg : colors.surface,
              borderColor: b.unlocked ? colors.primary : colors.border,
              child: Row(
                children: [
                  Text(b.icon,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: b.unlocked
                                        ? colors.primary
                                        : colors.onBackground)),
                        Text(b.subtitle,
                            style: TextStyle(
                                color: colors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (b.unlocked)
                    Icon(Icons.check_circle,
                        color: colors.primary, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
