import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/remote/firebase_auth_service.dart';
import '../../components/cropguard_text_field.dart';
import '../../components/section_label.dart';
import '../settings/language_provider.dart';
import 'settings_provider.dart';

/// Equivalent of SettingsScreen.kt
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text('App preferences & data',
                style: TextStyle(
                    color: colors.onBackgroundSecondary, fontSize: 12)),
          ],
        ),
      ),
      body: ListView(
        children: [
          _ActionRow(
            label: 'My Profile',
            onTap: () => context.push('/profile'),
          ),
          // Display section
          const _SectionHeader('Display'),
          _ActionRow(
            label: 'Language',
            value: langProvider.currentLanguage.displayName,
            onTap: () => _showLanguagePicker(context, langProvider),
          ),
          _ToggleRow(
            label: 'Large Text Mode',
            value: provider.largeTextMode,
            onChanged: provider.setLargeTextMode,
          ),
          _ToggleRow(
            label: 'Show Confidence Score',
            value: provider.showConfidence,
            onChanged: provider.setShowConfidence,
          ),

          // Model & data section
          const _SectionHeader('Model & Data'),
          _InfoRow(
            label: 'Model Version',
            value: provider.updateMessage ?? 'MobileNetV2 v1.0 (bundled)',
            badge: 'Active',
            actionLabel: provider.isCheckingUpdates ? 'Checking…' : 'Check Updates',
            onAction: provider.isCheckingUpdates ? null : provider.checkForModelUpdates,
          ),
          const _InfoRow(
            label: 'Supported Crops',
            value: 'Tomato, Potato, Maize, Cassava, Rice, Banana, Groundnut + more',
          ),
          _ActionRow(
            label: 'Clear Scan History',
            color: colors.diseaseRed,
            onTap: () => _confirmClear(context, provider),
          ),
          _ActionRow(
            label: 'Delete Account',
            color: colors.diseaseRed,
            onTap: () => _confirmDelete(context, provider),
          ),

          // About section
          const _SectionHeader('About'),
          _InfoRow(
            label: 'App Version',
            value: provider.appVersionLabel,
          ),
          const _InfoRow(
            label: 'Disclaimer',
            value:
                'CropGuard AI provides guidance only. Always consult a qualified agricultural expert for critical decisions.',
          ),
          _ActionRow(
            label: 'Privacy Policy',
            onTap: () => context.push('/privacy_policy'),
          ),
          _ActionRow(
            label: 'Terms of Service',
            onTap: () => context.push('/terms_of_service'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    LanguageProvider langProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final colors = context.colors;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Select Language',
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
              ...AppLanguage.values.map((lang) {
                final isSelected =
                    langProvider.currentLanguage == lang;
                return ListTile(
                  leading: Icon(Icons.language,
                      color: isSelected ? colors.primary : colors.muted),
                  title: Text(
                    lang.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? colors.primary
                          : colors.onBackground,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: colors.primary)
                      : null,
                  onTap: () {
                    langProvider.setLanguage(lang);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmClear(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Scan History?'),
        content: const Text(
            'This will permanently delete all scan records. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?',
            style: TextStyle(color: Colors.red)),
        content: const Text(
            'Are you absolutely sure? This will permanently delete your account and all cloud data.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _finalDeleteConfirmation(context, provider);
            },
            child: const Text('Yes, I am sure',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _finalDeleteConfirmation(BuildContext context, SettingsProvider provider) {
    final auth = sl<FirebaseAuthService>();
    _showReauthAndDeleteDialog(context, provider, auth);
  }

  void _showReauthAndDeleteDialog(
    BuildContext context,
    SettingsProvider provider,
    FirebaseAuthService auth,
  ) {
    String password = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Confirm deletion',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Re-enter your credentials to permanently delete your account.',
              ),
              if (auth.hasPasswordProvider) ...[
                const SizedBox(height: 16),
                CropGuardTextField(
                  value: password,
                  onChanged: (v) => setState(() => password = v),
                  label: 'Password',
                  obscureText: true,
                ),
              ],
              if (provider.deleteError != null) ...[
                const SizedBox(height: 8),
                Text(provider.deleteError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: provider.isDeleting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (auth.hasGoogleProvider && !auth.hasPasswordProvider)
              TextButton(
                onPressed: provider.isDeleting
                    ? null
                    : () async {
                        await provider.deleteAccount(
                          onSuccess: () {
                            Navigator.pop(ctx);
                            context.go('/login');
                          },
                          reauthWithGoogle: true,
                        );
                      },
                child: const Text('Confirm with Google'),
              ),
            TextButton(
              onPressed: provider.isDeleting
                  ? null
                  : () async {
                      await provider.deleteAccount(
                        onSuccess: () {
                          Navigator.pop(ctx);
                          context.go('/login');
                        },
                        password:
                            auth.hasPasswordProvider ? password : null,
                        reauthWithGoogle:
                            auth.hasGoogleProvider && password.isEmpty,
                      );
                    },
              child: provider.isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('DELETE PERMANENTLY',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: SectionLabel(text: title),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow(
      {required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodyLarge),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
        Divider(height: 0, color: colors.divider,
            indent: 16, endIndent: 16),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final String? value;
  final Color? color;
  final VoidCallback onTap;

  const _ActionRow(
      {required this.label, this.value, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: color ?? colors.onBackground,
                            )),
                    if (value != null)
                      Text(value!,
                          style: TextStyle(
                              color: colors.muted, fontSize: 12)),
                  ],
                ),
                Icon(Icons.chevron_right, color: colors.muted),
              ],
            ),
          ),
        ),
        Divider(height: 0, color: colors.divider,
            indent: 16, endIndent: 16),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _InfoRow(
      {required this.label,
      required this.value,
      this.badge,
      this.actionLabel,
      this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.bodyLarge),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.healthyBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badge!,
                          style: TextStyle(
                              color: colors.healthy,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const Spacer(),
                  if (actionLabel != null)
                    TextButton(
                      onPressed: onAction,
                      child: Text(actionLabel!,
                          style: TextStyle(
                              color: colors.primary, fontSize: 13)),
                    ),
                ],
              ),
              Text(value,
                  style: TextStyle(
                      color: colors.onBackgroundSecondary,
                      fontSize: 13)),
            ],
          ),
        ),
        Divider(height: 0, color: colors.divider,
            indent: 16, endIndent: 16),
      ],
    );
  }
}
