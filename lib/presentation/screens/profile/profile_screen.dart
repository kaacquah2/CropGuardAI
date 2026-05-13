import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/cropguard_card.dart';
import '../../components/farm_health_ring.dart';
import '../../components/offline_banner.dart';
import '../../components/section_label.dart';
import 'profile_provider.dart';

/// Equivalent of ProfileScreen.kt
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: colors.primary,
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colors.primaryDark_, colors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colors.primaryLight,
                        backgroundImage: provider.avatarUrl != null
                            ? CachedNetworkImageProvider(provider.avatarUrl!)
                            : null,
                        child: provider.avatarUrl == null
                            ? const Icon(Icons.person,
                                size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        provider.userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(
                        provider.userEmail,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Text('PRO FARMER',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                OfflineBanner(isOffline: provider.isOffline),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatCell(
                              label: 'Total Scans',
                              value: provider.stats.totalScans.toString()),
                          _StatCell(
                              label: 'Health Score',
                              value:
                                  '${(provider.stats.healthScore * 100).toInt()}%'),
                          _StatCell(
                              label: 'Diseases',
                              value: provider.stats.diseasesCaught
                                  .toString()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Account options
                      CropGuardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionLabel(
                                text: 'Account',
                                padding:
                                    const EdgeInsets.only(bottom: 8)),
                            _ProfileRow(
                              icon: Icons.edit,
                              label: 'Edit Profile',
                              onTap: () {},
                            ),
                            _ProfileRow(
                              icon: Icons.lock_outline,
                              label: 'Privacy & Security',
                              onTap: () => context.push('/settings'),
                            ),
                            _ProfileRow(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              onTap: () => context.push('/settings'),
                            ),
                            _ProfileRow(
                              icon: Icons.book_outlined,
                              label: 'Disease Library',
                              onTap: () =>
                                  context.push('/disease_library'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Preferences
                      CropGuardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionLabel(
                                text: 'Preferences',
                                padding:
                                    const EdgeInsets.only(bottom: 8)),
                            _PrefToggle(
                              icon: Icons.notifications_outlined,
                              label: 'Disease Alerts',
                              value: provider.alertsEnabled,
                              onChanged: provider.setAlertsEnabled,
                            ),
                            _PrefToggle(
                              icon: Icons.wifi_off,
                              label: 'Offline Mode',
                              value: provider.offlineMode,
                              onChanged: provider.setOfflineMode,
                            ),
                            _PrefToggle(
                              icon: Icons.high_quality_outlined,
                              label: 'High Quality Scans',
                              value: provider.highQualityScans,
                              onChanged: provider.setHighQualityScans,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign out
                      InkWell(
                        onTap: () => provider.signOut(
                            () => context.go('/login')),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: colors.error.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(10),
                            color: colors.diseaseBg,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.logout,
                                  color: colors.error, size: 20),
                              const SizedBox(width: 12),
                              Text('Sign Out',
                                  style: TextStyle(
                                      color: colors.error,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: colors.greenXL,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: colors.muted, fontSize: 11)),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: colors.muted),
          ],
        ),
      ),
    );
  }
}

class _PrefToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrefToggle(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
