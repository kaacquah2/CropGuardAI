import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';

/// Equivalent of OnboardingScreen.kt — 3-page horizontal pager with language picker
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.eco,
      title: 'Welcome to CropGuard AI',
      body:
          'Detect crop diseases instantly with AI-powered image analysis. '
          'Protect your harvest and maximize your yield.',
    ),
    _OnboardingPage(
      icon: Icons.camera_alt,
      title: 'Scan Your Crops',
      body:
          'Point your camera at any leaf. CropGuard AI analyses the image '
          'in seconds and identifies diseases with detailed treatment advice.',
    ),
    _OnboardingPage(
      icon: Icons.fact_check,
      title: 'Act Fast, Save More',
      body:
          'Get treatment plans, track farm health over time, and connect '
          'with agricultural experts — all offline-capable.',
    ),
  ];

  Future<void> _complete() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPageView(page: _pages[i]),
              ),
            ),

            // Dots + buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colors.primary
                              : colors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Primary action
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        } else {
                          _complete();
                        }
                      },
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Skip
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () {
                        _controller.jumpToPage(_pages.length - 1);
                      },
                      child: Text('Skip',
                          style: TextStyle(color: colors.muted)),
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

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage(
      {required this.icon, required this.title, required this.body});
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon, size: 120, color: colors.primary),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onBackgroundSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
