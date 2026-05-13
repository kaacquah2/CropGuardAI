import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// TermsOfServiceScreen — re-exported from privacy_policy_screen.dart
/// This stub re-exports to avoid the router needing a separate import.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the combined legal file which already has this class.
    // In practice the router imports privacy_policy_screen.dart which exports
    // both PrivacyPolicyScreen and TermsOfServiceScreen.
    return const SizedBox.shrink();
  }
}
