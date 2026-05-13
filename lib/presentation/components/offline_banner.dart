import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Offline warning banner — matches OfflineBanner.kt
class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();
    final colors = context.colors;
    return Container(
      width: double.infinity,
      color: colors.warning,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.black87),
          const SizedBox(width: 8),
          Text(
            'You are offline — using local data',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
