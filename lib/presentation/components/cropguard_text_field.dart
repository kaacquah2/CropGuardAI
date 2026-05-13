import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Text field matching CropGuardTextField.kt
class CropGuardTextField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? placeholder;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const CropGuardTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.muted,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.onBackground),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: colors.muted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: colors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
