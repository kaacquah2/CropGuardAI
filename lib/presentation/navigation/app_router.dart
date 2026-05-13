import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scanner/scanner_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/result/low_confidence_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/library/disease_library_screen.dart';
import '../screens/outbreak_map/outbreak_map_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/treatment_tracker/treatment_tracker_screen.dart';
import '../screens/legal/privacy_policy_screen.dart';
// TermsOfServiceScreen is defined in privacy_policy_screen.dart
import '../screens/analysing/analysing_screen.dart';
import '../screens/result/batch_result_screen.dart';

/// Equivalent of CropGuardNavGraph.kt
class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ─── Auth flow ─────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (ctx, state) => const RegisterScreen(),
      ),

      // ─── Main shell with bottom nav ────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) =>
            _BottomNavShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (ctx, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/scanner',
            builder: (ctx, state) => const ScannerScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (ctx, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (ctx, state) => const SettingsScreen(),
          ),
        ],
      ),

      // ─── Full-screen routes ────────────────────────────────────────────
      GoRoute(
        path: '/analysing',
        builder: (ctx, state) {
          final imagePath =
              state.uri.queryParameters['imagePath'] ?? '';
          return AnalisingScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: '/result/:id',
        builder: (ctx, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ResultScreen(detectionId: id);
        },
      ),
      GoRoute(
        path: '/batch_result',
        builder: (ctx, state) => const BatchResultScreen(),
      ),
      GoRoute(
        path: '/low_confidence',
        builder: (ctx, state) {
          final confidence = double.tryParse(
                  state.uri.queryParameters['confidence'] ?? '0') ??
              0.0;
          final imagePath =
              state.uri.queryParameters['imagePath'] ?? '';
          return LowConfidenceScreen(
              confidence: confidence, imagePath: imagePath);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (ctx, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/community',
        builder: (ctx, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/disease_library',
        builder: (ctx, state) => const DiseaseLibraryScreen(),
      ),
      GoRoute(
        path: '/outbreak_map',
        builder: (ctx, state) => const OutbreakMapScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (ctx, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/treatment_tracker',
        builder: (ctx, state) => const TreatmentTrackerScreen(),
      ),
      GoRoute(
        path: '/privacy_policy',
        builder: (ctx, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms_of_service',
        builder: (ctx, state) => const TermsOfServiceScreen(),
      ),
    ],
  );
}

class _BottomNavShell extends StatelessWidget {
  final String location;
  final Widget child;

  const _BottomNavShell({required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _CropNavBar(location: location),
    );
  }
}

class _CropNavBar extends StatelessWidget {
  final String location;

  const _CropNavBar({required this.location});

  static const _routes = ['/home', '/scanner', '/history', '/settings'];
  static const _labels = ['Home', 'Scan', 'History', 'Settings'];
  static const _icons = [Icons.home_outlined, Icons.camera_alt_outlined, Icons.history_outlined, Icons.settings_outlined];
  static const _selectedIcons = [Icons.home, Icons.camera_alt, Icons.history, Icons.settings];

  @override
  Widget build(BuildContext context) {
    final idx = _routes.indexWhere((r) => location.startsWith(r));
    return NavigationBar(
      selectedIndex: idx < 0 ? 0 : idx,
      onDestinationSelected: (i) => context.go(_routes[i]),
      destinations: List.generate(
        _routes.length,
        (i) => NavigationDestination(
          icon: Icon(_icons[i]),
          selectedIcon: Icon(_selectedIcons[i]),
          label: _labels[i],
        ),
      ),
    );
  }
}
