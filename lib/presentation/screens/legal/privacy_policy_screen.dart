import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: BackButton(onPressed: () => context.pop()),
        backgroundColor: colors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Last updated: May 2025',
                style: TextStyle(color: colors.muted, fontSize: 12)),
            const SizedBox(height: 20),
            ..._sections.map((s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(s.body,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                height: 1.6,
                                color: colors.onBackgroundSecondary)),
                    const SizedBox(height: 20),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  static const _sections = [
    _Section(
      title: '1. Information We Collect',
      body:
          'CropGuard AI collects the following information: account email and display name, crop scan images processed locally on your device, and aggregate usage analytics (no personal data). We do not sell your data.',
    ),
    _Section(
      title: '2. How We Use Your Data',
      body:
          'Your data is used to provide the disease detection service, improve model accuracy through anonymised feedback, and deliver expert consultation requests. Scan images are never transmitted to external servers without your explicit consent.',
    ),
    _Section(
      title: '3. Data Storage',
      body:
          'Scan results are stored locally on your device using SQLite. Cloud sync is optional and gated behind authentication. You can delete all local data at any time from Settings → Clear Scan History.',
    ),
    _Section(
      title: '4. Third-Party Services',
      body:
          'We use Firebase for authentication and optional cloud sync (governed by Google\'s Privacy Policy). We do not share data with any other third parties.',
    ),
    _Section(
      title: '5. Contact',
      body:
          'For privacy enquiries, contact privacy@cropguardai.com.',
    ),
  ];
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        leading: BackButton(onPressed: () => context.pop()),
        backgroundColor: colors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Effective: May 2025',
                style: TextStyle(color: colors.muted, fontSize: 12)),
            const SizedBox(height: 20),
            ..._sections.map((s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(s.body,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                height: 1.6,
                                color: colors.onBackgroundSecondary)),
                    const SizedBox(height: 20),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  static const _sections = [
    _Section(
      title: '1. Acceptance of Terms',
      body:
          'By using CropGuard AI, you agree to these Terms of Service. If you disagree with any part, please do not use the application.',
    ),
    _Section(
      title: '2. Medical / Agronomical Disclaimer',
      body:
          'CropGuard AI provides guidance based on AI image analysis. Results are not a substitute for expert agronomical advice. Always consult a qualified agronomist before applying treatments, especially chemical pesticides.',
    ),
    _Section(
      title: '3. User Responsibilities',
      body:
          'You are responsible for the accuracy of information you provide, appropriate use of treatment recommendations, and compliance with local agricultural regulations.',
    ),
    _Section(
      title: '4. Intellectual Property',
      body:
          'All content, models, and branding within CropGuard AI are the property of CropGuard AI Ltd. Unauthorised reproduction is prohibited.',
    ),
    _Section(
      title: '5. Limitation of Liability',
      body:
          'CropGuard AI Ltd is not liable for any crop losses, financial damages, or adverse outcomes resulting from the use of this application.',
    ),
    _Section(
      title: '6. Changes to Terms',
      body:
          'We may update these terms periodically. Continued use of the application constitutes acceptance of the revised terms.',
    ),
  ];
}

class _Section {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});
}
