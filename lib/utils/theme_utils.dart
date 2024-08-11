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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.all(
            BorderSide(color: color),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        hintStyle: TextStyle(color: color),
        labelStyle: const TextStyle(color: Colors.blueGrey),
      ),
    );
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.all(
            BorderSide(color: color),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        hintStyle: TextStyle(color: color),
        labelStyle: const TextStyle(color: Colors.blueGrey),
      ),
    );
  }

  static void changeTheme(BuildContext context, Color color) {
    final adaptiveTheme = AdaptiveTheme.of(context);
    adaptiveTheme.setTheme(
        light: createLightTheme(color), dark: createDarkTheme(color));
  }
}
