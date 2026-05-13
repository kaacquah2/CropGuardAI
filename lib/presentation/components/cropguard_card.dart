import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Equivalent of CropGuardCard composable — Surface bg, 1px border, 14dp radius
class CropGuardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const CropGuardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? colors.border, width: 1),
      ),
      child: child,
    );
  }
}
