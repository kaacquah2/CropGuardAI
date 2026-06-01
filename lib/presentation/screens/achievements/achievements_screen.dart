import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/streak_manager.dart';
import '../../../data/local/database_helper.dart';
import '../../../data/remote/firestore_service.dart';
import '../../components/cropguard_card.dart';

class _Badge {
  final String icon;
  final String title;
  final String subtitle;
  final bool Function(Map<String, int>) isUnlocked;

  const _Badge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isUnlocked,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final DatabaseHelper _db = sl<DatabaseHelper>();
  final FirestoreService _firestore = sl<FirestoreService>();
  final StreakManager _streakManager = sl<StreakManager>();

  Map<String, int> _stats = {
    'totalScans': 0,
    'distinctDiseases': 0,
    'streakDays': 0,
    'completedTreatments': 0,
    'communityPosts': 0,
    'outbreakReports': 0,
  };
  bool _loading = true;

  static final _badges = [
    _Badge(
      icon: '🌱',
      title: 'First Scan',
      subtitle: 'Complete your first crop scan',
      isUnlocked: _badgeAtLeast('totalScans', 1),
    ),
    _Badge(
      icon: '🔥',
      title: 'Scan Streak',
      subtitle: 'Scan crops for 7 days straight',
      isUnlocked: _badgeAtLeast('streakDays', 7),
    ),
    _Badge(
      icon: '🔎',
      title: 'Disease Detective',
      subtitle: 'Detect 10 distinct diseases',
      isUnlocked: _badgeAtLeast('distinctDiseases', 10),
    ),
    _Badge(
      icon: '🏆',
      title: 'Pro Farmer',
      subtitle: 'Reach 100 scans',
      isUnlocked: _badgeAtLeast('totalScans', 100),
    ),
    _Badge(
      icon: '✅',
      title: 'Harvest Hero',
      subtitle: 'Complete a treatment plan',
      isUnlocked: _badgeAtLeast('completedTreatments', 1),
    ),
    _Badge(
      icon: '💬',
      title: 'Community Voice',
      subtitle: 'Share 5 community posts',
      isUnlocked: _badgeAtLeast('communityPosts', 5),
    ),
    _Badge(
      icon: '⚡',
      title: 'Quick Responder',
      subtitle: 'Act on one plan quickly',
      isUnlocked: _badgeAtLeast('completedTreatments', 1),
    ),
    _Badge(
      icon: '🗺️',
      title: 'Map Reporter',
      subtitle: 'Submit 3 outbreak reports',
      isUnlocked: _badgeAtLeast('outbreakReports', 3),
    ),
  ];

  static bool Function(Map<String, int>) _badgeAtLeast(
    String key,
    int minimum,
  ) {
    return (stats) => (stats[key] ?? 0) >= minimum;
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final farmStats = await _db.getFarmStats();
    final distinctDiseases = await _db.getDistinctDiseaseCount();
    final streakDays = _streakManager.getStreak();
    final completedTreatments = await _db.getCompletedTreatmentsCount();
    final communityPosts = (await _firestore.postsStream().first).length;
    final outbreakReports = (await _firestore.getOutbreakReports()).length;

    if (!mounted) return;
    setState(() {
      _stats = {
        'totalScans': farmStats['total'] ?? 0,
        'distinctDiseases': distinctDiseases,
        'streakDays': streakDays,
        'completedTreatments': completedTreatments,
        'communityPosts': communityPosts,
        'outbreakReports': outbreakReports,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unlockedCount = _badges.where((b) => b.isUnlocked(_stats)).length;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
            if (!_loading)
              Text(
                '$unlockedCount / ${_badges.length} unlocked',
                style: TextStyle(color: colors.primary, fontSize: 12),
              ),
          ],
        ),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.muted),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _ProgressHeader(
                  unlocked: unlockedCount,
                  total: _badges.length,
                  stats: _stats,
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _badges.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final badge = _badges[i];
                      final unlocked = badge.isUnlocked(_stats);
                      return Opacity(
                        opacity: unlocked ? 1.0 : 0.45,
                        child: CropGuardCard(
                          backgroundColor:
                              unlocked ? colors.healthyBg : colors.surface,
                          borderColor:
                              unlocked ? colors.primary : colors.border,
                          child: Row(
                            children: [
                              Text(badge.icon,
                                  style: const TextStyle(fontSize: 36)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      badge.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: unlocked
                                                ? colors.primary
                                                : colors.onBackground,
                                          ),
                                    ),
                                    Text(
                                      badge.subtitle,
                                      style: TextStyle(
                                        color: colors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                unlocked ? Icons.check_circle : Icons.lock_outline,
                                color:
                                    unlocked ? colors.primary : colors.border,
                                size: 20,
                              ),
                            ],
                          ),
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

class _ProgressHeader extends StatelessWidget {
  final int unlocked;
  final int total;
  final Map<String, int> stats;

  const _ProgressHeader({
    required this.unlocked,
    required this.total,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pct = total > 0 ? unlocked / total : 0.0;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(label: 'Scans', value: '${stats['totalScans'] ?? 0}'),
              _MiniStat(
                  label: 'Diseases',
                  value: '${stats['distinctDiseases'] ?? 0}'),
              _MiniStat(label: 'Streak', value: '${stats['streakDays'] ?? 0}'),
              _MiniStat(
                  label: 'Plans', value: '${stats['completedTreatments'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: colors.border,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$unlocked/$total',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(label, style: TextStyle(color: colors.muted, fontSize: 10)),
      ],
    );
  }
}
