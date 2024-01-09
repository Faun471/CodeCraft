import 'package:flutter/material.dart';

class ThemeUtils {
  static ThemeData changeThemeColor(ThemeData themeData, Color color) {
    return themeData.copyWith(
      primaryColor: color,
      colorScheme: themeData.brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: color,
              secondary: color,
            )
          : ColorScheme.light(
              primary: color,
              secondary: color,
            ),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(color: Colors.white),
        color: color,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: color,
        ).merge(
          ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              return states.contains(MaterialState.disabled)
                  ? Colors.grey
                  : Colors.white;
            }),
            textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: Colors.white),
        ).merge(
          ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              return states.contains(MaterialState.disabled)
                  ? Colors.grey
                  : Colors.white;
            }),
            textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
