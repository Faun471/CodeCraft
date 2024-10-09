import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/themes/theme.dart';

class ThemeUtils {
  static ThemeData createLightTheme(Color color) {
    return AppTheme.lightTheme.copyWith(
      primaryColor: color,
      primaryColorDark: adjustColorBrightness(color),
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: color,
      ),
      elevatedButtonTheme:
          AppTheme.baseElevatedButtonTheme(backgroundColor: color),
      outlinedButtonTheme: AppTheme.baseOutlinedButtonTheme(sideColor: color),
      inputDecorationTheme: AppTheme.baseInputDecorationTheme(
        color,
        borderColor: Colors.black.withOpacity(0.2),
        focusedBorderColor: color,
      ),
    );
  }

  static ThemeData createDarkTheme(Color color) {
    return AppTheme.darkTheme.copyWith(
      primaryColor: color,
      primaryColorDark: adjustColorBrightness(color),
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: color,
      ),
      elevatedButtonTheme:
          AppTheme.baseElevatedButtonTheme(backgroundColor: color),
      outlinedButtonTheme: AppTheme.baseOutlinedButtonTheme(sideColor: color),
      inputDecorationTheme: AppTheme.baseInputDecorationTheme(
        color,
        borderColor: Colors.white.withOpacity(0.2),
        focusedBorderColor: color,
      ),
    );
  }

  static void changeTheme(BuildContext context, Color color) {
    final adaptiveTheme = AdaptiveTheme.of(context);
    adaptiveTheme.setTheme(
        light: createLightTheme(color), dark: createDarkTheme(color));
  }

  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5
        ? const Color.fromARGB(255, 21, 21, 21)
        : Colors.white;
  }

  static Color adjustColorBrightness(Color primaryColor) {
    final luminance = primaryColor.computeLuminance();
    if (luminance > 0.5) {
      final hsl = HSLColor.fromColor(primaryColor);
      final darkerColor =
          hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
      return darkerColor;
    } else {
      return primaryColor;
    }
  }

  static Color getDarkColor(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);
    final darkerColor =
        hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
    return darkerColor;
  }
}
