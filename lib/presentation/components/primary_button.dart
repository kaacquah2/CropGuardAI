import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Primary green button — matches PrimaryButton.kt
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                ],
              ),
      ),
    );
  }
}

/// Secondary outlined button — matches SecondaryButton.kt
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.primary,
                )),
      ),
    );
  }
}

/// Lime gradient button — matches LimeButton composable
class LimeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const LimeButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [colors.accent, colors.limeDark]),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.background,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
