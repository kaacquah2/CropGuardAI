import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../settings/language_provider.dart';

/// 4-page horizontal pager with language picker on page 1 and animated hero widgets
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late final AnimationController _heroAnim;

  @override
  void initState() {
    super.initState();
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  static const _pageCount = 4;

  Future<void> _complete() async {
    await [Permission.camera, Permission.location].request();
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _heroAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Language picker (page 0 only) ──────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentPage == 0
                  ? _LanguageGrid(langProvider: langProvider)
                  : const SizedBox(height: 8),
            ),

            // ── Pages ──────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _heroAnim
                    ..reset()
                    ..repeat(reverse: true);
                },
                children: [
                  _WelcomePage(anim: _heroAnim),
                  _ScanPage(anim: _heroAnim),
                  _ActPage(anim: _heroAnim),
                  _PermissionsPage(anim: _heroAnim),
                ],
              ),
            ),

            // ── Dots + buttons ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pageCount, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? colors.primary : colors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_currentPage < _pageCount - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _complete();
                        }
                      },
                      child: Text(
                        _currentPage < _pageCount - 1
                            ? 'Continue'
                            : 'Enable & Get Started',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage == 0)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text('Already have an account? Sign In',
                          style: TextStyle(color: colors.primary, fontSize: 13)),
                    ),
                  if (_currentPage > 0 && _currentPage < _pageCount - 1)
                    TextButton(
                      onPressed: _complete,
                      child: Text('Skip',
                          style: TextStyle(color: colors.muted, fontSize: 13)),
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

// ──────────────────────────────────────────────────────────────────────────────
// Language Grid
// ──────────────────────────────────────────────────────────────────────────────

class _LanguageGrid extends StatelessWidget {
  final LanguageProvider langProvider;
  const _LanguageGrid({required this.langProvider});

  static const _langs = AppLanguage.values;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text('Select your language',
                  style: TextStyle(
                    color: colors.onBackgroundSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _langs.map((lang) {
              final selected = langProvider.currentLanguage == lang;
              return GestureDetector(
                onTap: () => langProvider.setLanguage(lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary
                        : colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? colors.primary : colors.border,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    lang.displayName,
                    style: TextStyle(
                      color:
                          selected ? Colors.white : colors.onBackgroundSecondary,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Page 0: Welcome — animated leaf pulse
// ──────────────────────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final AnimationController anim;
  const _WelcomePage({required this.anim});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: anim,
            builder: (_, __) {
              final scale = 0.9 + 0.1 * anim.value;
              final glow = anim.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.15 + 0.15 * glow),
                        colors.primary.withValues(alpha: 0.03),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.25 * glow),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.eco_rounded,
                        size: 90, color: colors.primary),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 36),
          Text(
            'Welcome to CropGuard AI',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Spot tomato blight, maize rust, and cassava mosaic before they spread. '
            'Built for Ghanaian farmers with Twi and local crop knowledge.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onBackgroundSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Page 1: Scan — simulated camera scan animation
// ──────────────────────────────────────────────────────────────────────────────

class _ScanPage extends StatelessWidget {
  final AnimationController anim;
  const _ScanPage({required this.anim});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, __) {
                final scanY = anim.value;
                return Stack(
                  children: [
                    // Camera viewfinder corners
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _ViewfinderPainter(colors.primary),
                    ),
                    // Leaf icon in center
                    Center(
                      child: Icon(Icons.local_florist_rounded,
                          size: 70, color: colors.primary.withValues(alpha: 0.8)),
                    ),
                    // Scanning line
                    Positioned(
                      top: 10 + 160 * scanY,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              colors.primary,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Scan Your Crops',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Point your camera at any leaf. CropGuard AI analyses the image '
            'in seconds and identifies diseases with detailed treatment advice.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onBackgroundSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final Color color;
  _ViewfinderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    const r = 8.0;

    void drawCorner(double cx, double cy, bool right, bool down) {
      final dx = right ? 1.0 : -1.0;
      final dy = down ? 1.0 : -1.0;
      final path = Path()
        ..moveTo(cx + dx * len, cy)
        ..lineTo(cx + dx * r, cy)
        ..arcToPoint(Offset(cx, cy + dy * r),
            radius: const Radius.circular(r), clockwise: right != down)
        ..lineTo(cx, cy + dy * len);
      canvas.drawPath(path, paint);
    }

    drawCorner(0, 0, true, true);
    drawCorner(size.width, 0, false, true);
    drawCorner(0, size.height, true, false);
    drawCorner(size.width, size.height, false, false);
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) => old.color != color;
}

// ──────────────────────────────────────────────────────────────────────────────
// Page 2: Act Fast — rotating treatment plan cards
// ──────────────────────────────────────────────────────────────────────────────

class _ActPage extends StatelessWidget {
  final AnimationController anim;
  const _ActPage({required this.anim});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final steps = [
      ('🔬', 'Disease Detected'),
      ('📋', 'Treatment Plan'),
      ('✅', 'Recovery Tracked'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 170,
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: steps.asMap().entries.map((e) {
                    final i = e.key;
                    final s = e.value;
                    final offset = (i - anim.value * 2.0).clamp(-1.0, 1.0);
                    final t = (1.0 - offset.abs()).clamp(0.0, 1.0);
                    return Transform(
                      transform: Matrix4.identity()
                        ..translateByDouble(offset * 80.0, -i * 8.0, 0.0, 1.0)
                        ..scaleByDouble(0.75 + 0.25 * t, 0.75 + 0.25 * t, 1.0, 1.0),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: (0.4 + 0.6 * t).clamp(0.0, 1.0),
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.border),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(s.$1,
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(width: 10),
                              Text(s.$2,
                                  style: TextStyle(
                                    color: colors.onBackground,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Act Fast, Save More',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get treatment plans, track farm health over time, and connect '
            'with agricultural experts — all offline-capable.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onBackgroundSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Page 3: Permissions — shield animation
// ──────────────────────────────────────────────────────────────────────────────

class _PermissionsPage extends StatelessWidget {
  final AnimationController anim;
  const _PermissionsPage({required this.anim});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: anim,
            builder: (_, __) {
              final pulse = math.sin(anim.value * math.pi);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 160 + 20 * pulse,
                    height: 160 + 20 * pulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary
                          .withValues(alpha: 0.05 + 0.05 * pulse),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(Icons.shield_rounded,
                        size: 64, color: colors.primary),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          // Permission items
          const _PermItem(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            desc: 'To scan crop leaves for disease detection',
          ),
          const SizedBox(height: 10),
          const _PermItem(
            icon: Icons.location_on_rounded,
            label: 'Location',
            desc: 'To map disease outbreaks in your region',
          ),
          const SizedBox(height: 24),
          Text(
            'Permissions & Privacy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your data stays on your device. We never sell or share your information.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _PermItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  const _PermItem({required this.icon, required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    )),
                Text(desc,
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: colors.healthy, size: 18),
        ],
      ),
    );
  }
}
