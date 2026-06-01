import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../components/cropguard_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('More', style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MoreTile(
            icon: Icons.people_outline,
            title: 'Community',
            subtitle: 'Connect with other farmers',
            onTap: () => context.push('/community'),
          ),
          const SizedBox(height: 12),
          _MoreTile(
            icon: Icons.menu_book_outlined,
            title: 'Disease Library',
            subtitle: 'Learn about crop threats',
            onTap: () => context.push('/disease_library'),
          ),
          const SizedBox(height: 12),
          _MoreTile(
            icon: Icons.map_outlined,
            title: 'Outbreak Map',
            subtitle: 'See nearby disease reports',
            onTap: () => context.push('/outbreak_map'),
          ),
          const SizedBox(height: 12),
          _MoreTile(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            subtitle: 'Your farming milestones',
            onTap: () => context.push('/achievements'),
          ),
          const SizedBox(height: 12),
          _MoreTile(
            icon: Icons.medical_services_outlined,
            title: 'Treatment Tracker',
            subtitle: 'Follow your crop treatment plans',
            onTap: () => context.push('/treatment_tracker'),
          ),
          const SizedBox(height: 12),
          _MoreTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Your farm stats and preferences',
            onTap: () => context.push('/profile'),
          ),
          const SizedBox(height: 12),
          _MoreTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Language, display, and data',
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _MoreTile(
            icon: Icons.info_outline,
            title: 'About CropGuard AI',
            subtitle: 'App version, terms, and privacy',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'CropGuard AI',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.eco, color: colors.primary, size: 48),
                children: [
                  const Text('CropGuard AI is your assistant for healthier crops.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CropGuardCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle,
                    style: TextStyle(color: colors.muted, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.muted),
        ],
      ),
    );
  }
}
