import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle _customTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.white,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );
}

final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.blue,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 21, 101, 192),
    secondary: Color.fromARGB(255, 21, 101, 192),
  ),
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.white),
    color: Color.fromARGB(255, 21, 101, 192),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color.fromARGB(255, 150, 147, 147)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.blue),
    ),
    labelStyle: _customTextStyle(color: Colors.white),
    hintStyle: _customTextStyle(color: Colors.blueGrey),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Colors.blue,
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
  textTheme: TextTheme(
    displayLarge: _customTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    displayMedium: _customTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    displaySmall: _customTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    headlineMedium: _customTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    headlineSmall: _customTextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    titleLarge: _customTextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    bodyLarge: _customTextStyle(fontSize: 14),
    bodyMedium: _customTextStyle(fontSize: 12),
    bodySmall: _customTextStyle(fontSize: 10),
  ),
);
