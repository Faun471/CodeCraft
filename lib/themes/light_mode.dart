import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle _customTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.normal,
  Color color = const Color.fromARGB(255, 21, 21, 21),
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

ButtonStyle _customTextButtonStyle(Color textColor) {
  return TextButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ).merge(ButtonStyle(
    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      return states.contains(MaterialState.disabled) ? Colors.grey : textColor;
    }),
  ));
}

ButtonStyle _customFilledButtonStyle(Color backgroundColor, Color textColor) {
  return ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    backgroundColor: backgroundColor,
  ).merge(ButtonStyle(
    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      return states.contains(MaterialState.disabled) ? Colors.grey : textColor;
    }),
  ));
}

final ThemeData lightTheme = ThemeData(
  primaryColorLight: Colors.blue[700],
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  ),
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 21, 101, 192),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.blue[700],
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: _customTextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: _customOutlinedButtonStyle(
        Colors.blueGrey, const Color.fromARGB(255, 21, 21, 21)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.blueGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.blueGrey),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.blue),
    ),
    labelStyle: _customTextStyle(color: const Color.fromARGB(255, 21, 21, 21)),
    hintStyle: _customTextStyle(color: Colors.blueGrey),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: _customElevatedButtonStyle(Colors.blue, Colors.white),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue[700],
    textTheme: ButtonTextTheme.primary,
  ),
  textButtonTheme: TextButtonThemeData(
    style: _customTextButtonStyle(const Color.fromARGB(255, 21, 101, 192)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: _customFilledButtonStyle(Colors.blue, Colors.white),
  ),
  textTheme: TextTheme(
    displayLarge: _customTextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 21, 21, 21),
    ),
    displayMedium: _customTextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 21, 21, 21),
    ),
    displaySmall: _customTextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 21, 21, 21),
    ),
    headlineMedium: _customTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 21, 21, 21),
    ),
    headlineSmall: _customTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 21, 21, 21),
    ),
    titleLarge: _customTextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 21, 21, 21),
    ),
    bodyLarge: _customTextStyle(
        fontSize: 14, color: const Color.fromARGB(255, 21, 21, 21)),
    bodyMedium: _customTextStyle(
        fontSize: 12, color: const Color.fromARGB(255, 21, 21, 21)),
    bodySmall: _customTextStyle(
        fontSize: 10, color: const Color.fromARGB(255, 21, 21, 21)),
  ),
);
