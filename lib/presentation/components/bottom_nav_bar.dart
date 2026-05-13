import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Bottom navigation items matching BottomNavBar.kt
class CropGuardBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const CropGuardBottomNavBar({super.key, required this.currentRoute});

  static const _items = [
    _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', route: '/home'),
    _NavItem(icon: Icons.camera_alt_outlined, selectedIcon: Icons.camera_alt, label: 'Scan', route: '/scanner'),
    _NavItem(icon: Icons.history_outlined, selectedIcon: Icons.history, label: 'History', route: '/history'),
    _NavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedIndex =
        _items.indexWhere((i) => currentRoute.startsWith(i.route));
    final idx = selectedIndex < 0 ? 0 : selectedIndex;

    return NavigationBar(
      selectedIndex: idx,
      backgroundColor: colors.surface,
      indicatorColor: colors.healthyBg,
      onDestinationSelected: (i) {
        final target = _items[i].route;
        if (!currentRoute.startsWith(target)) {
          context.go(target);
        }
      },
      destinations: _items.map((item) {
        final isSelected = currentRoute.startsWith(item.route);
        return NavigationDestination(
          icon: Icon(item.icon,
              color: isSelected ? colors.primary : colors.onBackgroundSecondary),
          selectedIcon: Icon(item.selectedIcon, color: colors.primary),
          label: item.label,
        );
      }).toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem(
      {required this.icon,
      required this.selectedIcon,
      required this.label,
      required this.route});
}
