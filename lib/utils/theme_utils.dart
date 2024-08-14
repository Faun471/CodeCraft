import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/themes/theme.dart';

class ThemeUtils {
  static ThemeData createLightTheme(Color color) {
    return AppTheme.lightTheme.copyWith(
        primaryColor: color,
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
        inputDecorationTheme: AppTheme.baseInputDecorationTheme(color));
  }

  static ThemeData createDarkTheme(Color color) {
    return AppTheme.darkTheme.copyWith(
        primaryColor: color,
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
        inputDecorationTheme: AppTheme.baseInputDecorationTheme(color));
  }

  static void changeTheme(BuildContext context, Color color) {
    final adaptiveTheme = AdaptiveTheme.of(context);
    adaptiveTheme.setTheme(
        light: createLightTheme(color), dark: createDarkTheme(color));
  }
}
