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

ButtonStyle _customOutlinedButtonStyle(Color sideColor, Color textColor) {
  return OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    side: BorderSide(color: sideColor),
  ).merge(ButtonStyle(
    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      return states.contains(MaterialState.disabled) ? Colors.grey : textColor;
    }),
  ));
}

ButtonStyle _customElevatedButtonStyle(Color backgroundColor, Color textColor) {
  return ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    backgroundColor: backgroundColor,
  ).merge(ButtonStyle(
    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      return states.contains(MaterialState.disabled) ? Colors.grey : textColor;
    }),
    textStyle: MaterialStateProperty.all<TextStyle>(
        _customTextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  ));
}

final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: const Color.fromARGB(255, 21, 101, 192),
  appBarTheme: AppBarTheme(
    color: Colors.blue[700],
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: _customTextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: _customOutlinedButtonStyle(Colors.blueGrey, Colors.white),
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
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: _customElevatedButtonStyle(Colors.blue, Colors.white),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue[700],
    textTheme: ButtonTextTheme.primary,
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
