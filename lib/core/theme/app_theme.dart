import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(isDark: false);
  static ThemeData get dark => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final colors = CropColors(isDark: isDark);
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.accent,
        onSecondary: colors.onBackground,
        error: colors.error,
        onError: Colors.white,
        background: colors.background,
        onBackground: colors.onBackground,
        surface: colors.surface,
        onSurface: colors.onSurface,
        surfaceVariant: colors.surfaceVariant,
        outline: colors.border,
      ),
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      dividerColor: colors.divider,
      textTheme: _buildTextTheme(colors),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: colors.onBackground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 44),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.healthyBg,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: colors.primary);
          }
          return IconThemeData(color: colors.onBackgroundSecondary);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(
              color: colors.primary,
              fontSize: 12,
              fontFamily: 'Inter',
            );
          }
          return TextStyle(
            color: colors.onBackgroundSecondary,
            fontSize: 12,
            fontFamily: 'Inter',
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
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
        hintStyle: TextStyle(color: colors.muted),
        labelStyle: TextStyle(color: colors.onBackgroundSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return colors.primary;
          return colors.muted;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return colors.healthyBg;
          return colors.border;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return colors.primaryLight;
          return null;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(color: colors.border),
      ),
      extensions: [AppColorsThemeExtension(colors: colors)],
    );
  }

  static TextTheme _buildTextTheme(CropColors colors) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.w600, fontSize: 24),
      headlineSmall: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.bold, fontSize: 18),
      titleMedium: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontSize: 14),
      bodySmall: TextStyle(fontFamily: 'Inter', color: colors.onBackgroundSecondary, fontSize: 12),
      labelLarge: TextStyle(fontFamily: 'Inter', color: colors.onBackground, fontWeight: FontWeight.w500, fontSize: 14),
      labelMedium: TextStyle(fontFamily: 'Inter', color: colors.onBackgroundSecondary, fontSize: 12),
      labelSmall: TextStyle(fontFamily: 'Inter', color: colors.muted, fontSize: 11),
    );
  }
}

/// ThemeExtension to access CropColors from any BuildContext
class AppColorsThemeExtension extends ThemeExtension<AppColorsThemeExtension> {
  final CropColors colors;

  const AppColorsThemeExtension({required this.colors});

  @override
  AppColorsThemeExtension copyWith({CropColors? colors}) =>
      AppColorsThemeExtension(colors: colors ?? this.colors);

  @override
  AppColorsThemeExtension lerp(ThemeExtension<AppColorsThemeExtension>? other, double t) => this;
}

extension BuildContextColors on BuildContext {
  CropColors get colors {
    return Theme.of(this).extension<AppColorsThemeExtension>()?.colors ??
        const CropColors();
  }
}
