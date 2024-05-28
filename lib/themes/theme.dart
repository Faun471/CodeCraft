import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextStyle _baseTextStyle({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }

  static AppBarTheme _baseAppBarTheme({
    Color backgroundColor = Colors.orange,
    Color iconColor = Colors.white,
    Color titleColor = Colors.white,
    double elevation = 0.0,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      iconTheme: IconThemeData(color: iconColor),
      titleTextStyle: _baseTextStyle(
        color: titleColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: elevation,
    );
  }

  static ButtonThemeData _baseButtonTheme({
    Color buttonColor = Colors.orange,
    double borderRadius = 8.0,
  }) {
    return ButtonThemeData(
      buttonColor: buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static ElevatedButtonThemeData _baseElevatedButtonTheme({
    Color backgroundColor = Colors.orange,
    double borderRadius = 8.0,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              backgroundColor: backgroundColor)
          .merge(
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
    );
  }

  static OutlinedButtonThemeData _baseOutlinedButtonTheme({
    Color sideColor = Colors.white,
    double borderRadius = 8.0,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: BorderSide(color: sideColor),
      ).merge(
        ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            return states.contains(MaterialState.disabled)
                ? Colors.grey
                : states.contains(MaterialState.pressed)
                    ? Colors.orange
                    : Colors.white;
          }),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static InputDecorationTheme _baseInputDecorationTheme(
    Color color, {
    Color borderColor = Colors.black,
    Color focusedBorderColor = Colors.orange,
  }) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color.fromARGB(255, 150, 147, 147)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: focusedBorderColor),
      ),
      labelStyle: _baseTextStyle(color: color),
      hintStyle: _baseTextStyle(color: Colors.blueGrey),
    );
  }

  static TextTheme _baseTextTheme(Color color) {
    return TextTheme(
      displayLarge: _baseTextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: color),
      displayMedium: _baseTextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: color),
      displaySmall: _baseTextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: color),
      headlineMedium: _baseTextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: color),
      headlineSmall: _baseTextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: color),
      titleLarge: _baseTextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: color),
      titleMedium: _baseTextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: color),
      titleSmall: _baseTextStyle(
          fontSize: 8, fontWeight: FontWeight.bold, color: color),
      bodyLarge: _baseTextStyle(fontSize: 14, color: color),
      bodyMedium: _baseTextStyle(fontSize: 12, color: color),
      bodySmall: _baseTextStyle(fontSize: 10, color: color),
      labelLarge: _baseTextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: color),
      labelMedium: _baseTextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: color),
      labelSmall: _baseTextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: color),
    );
  }

  static ThemeData baseTheme = ThemeData();

  static ThemeData lightTheme = baseTheme.copyWith(
    primaryColor: Colors.amber,
    appBarTheme: _baseAppBarTheme(),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber).copyWith(
      primary: Colors.amber,
      secondary: Colors.deepOrange,
    ),
    inputDecorationTheme: _baseInputDecorationTheme(
        Color.fromARGB(255, 21, 21, 21),
        focusedBorderColor: Colors.orange,
        borderColor: Colors.black),
    buttonTheme: _baseButtonTheme(),
    elevatedButtonTheme: _baseElevatedButtonTheme(),
    outlinedButtonTheme: _baseOutlinedButtonTheme(),
    textTheme: _baseTextTheme(Color.fromARGB(255, 21, 21, 21)),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.amber,
    colorScheme: const ColorScheme.dark(
      primary: Colors.amber,
      secondary: Colors.amber,
    ),
    appBarTheme: _baseAppBarTheme(),
    inputDecorationTheme: _baseInputDecorationTheme(Colors.white,
        focusedBorderColor: Colors.amber, borderColor: Colors.white),
    buttonTheme: _baseButtonTheme(),
    elevatedButtonTheme: _baseElevatedButtonTheme(),
    outlinedButtonTheme: _baseOutlinedButtonTheme(),
    textTheme: _baseTextTheme(Colors.white),
  );

  static Map<String, TextStyle> getSyntaxHighlighterTheme(SyntaxTheme theme) {
    return themeMap[theme.themeName]!;
  }
}

enum SyntaxTheme {
  dark,
  light,
  dracula,
  github,
  monokai,
  ocean,
  palenight,
  atelierEstuaryLight,
  atelierEstuaryDark,
  zenburn;

  const SyntaxTheme();

  bool get isLight {
    switch (this) {
      case SyntaxTheme.atelierEstuaryLight:
      case SyntaxTheme.light:
        return true;
      default:
        return false;
    }
  }

  String _camelCaseToTitle(String text) {
    return text
        .split(RegExp(r"(?=[A-Z])"))
        .join('-')
        .toLowerCase()
        .replaceAll('theme', '');
  }

  String get themeName {
    return _camelCaseToTitle(this.toString().split('.').last);
  }

  Map<String, TextStyle> get theme {
    return AppTheme.getSyntaxHighlighterTheme(this);
  }

  TextStyle get root {
    return AppTheme.getSyntaxHighlighterTheme(this)['root']!;
  }

  TextStyle get keyword {
    return AppTheme.getSyntaxHighlighterTheme(this)['keyword']!;
  }

  TextStyle get selectorTag {
    return AppTheme.getSyntaxHighlighterTheme(this)['selector-tag']!;
  }

  TextStyle get tag {
    return AppTheme.getSyntaxHighlighterTheme(this)['tag']!;
  }

  TextStyle get templateTag {
    return AppTheme.getSyntaxHighlighterTheme(this)['template-tag']!;
  }

  TextStyle get number {
    return AppTheme.getSyntaxHighlighterTheme(this)['number']!;
  }

  TextStyle get variable {
    return AppTheme.getSyntaxHighlighterTheme(this)['variable']!;
  }

  TextStyle get templateVariable {
    return AppTheme.getSyntaxHighlighterTheme(this)['template-variable']!;
  }

  TextStyle get attribute {
    return AppTheme.getSyntaxHighlighterTheme(this)['attribute']!;
  }

  TextStyle get literal {
    return AppTheme.getSyntaxHighlighterTheme(this)['literal']!;
  }

  TextStyle get subst {
    return AppTheme.getSyntaxHighlighterTheme(this)['subst']!;
  }

  TextStyle get title {
    return AppTheme.getSyntaxHighlighterTheme(this)['title']!;
  }

  TextStyle get name {
    return AppTheme.getSyntaxHighlighterTheme(this)['name']!;
  }

  TextStyle get selectorId {
    return AppTheme.getSyntaxHighlighterTheme(this)['selector-id']!;
  }

  TextStyle get selectorClass {
    return AppTheme.getSyntaxHighlighterTheme(this)['selector-class']!;
  }

  TextStyle get section {
    return AppTheme.getSyntaxHighlighterTheme(this)['section']!;
  }

  TextStyle get type {
    return AppTheme.getSyntaxHighlighterTheme(this)['type']!;
  }

  TextStyle get symbol {
    return AppTheme.getSyntaxHighlighterTheme(this)['symbol']!;
  }

  TextStyle get bullet {
    return AppTheme.getSyntaxHighlighterTheme(this)['bullet']!;
  }

  TextStyle get link {
    return AppTheme.getSyntaxHighlighterTheme(this)['link']!;
  }

  TextStyle get deletion {
    return AppTheme.getSyntaxHighlighterTheme(this)['deletion']!;
  }

  TextStyle get string {
    return AppTheme.getSyntaxHighlighterTheme(this)['string']!;
  }

  TextStyle get builtIn {
    return AppTheme.getSyntaxHighlighterTheme(this)['built_in']!;
  }

  TextStyle get builtinName {
    return AppTheme.getSyntaxHighlighterTheme(this)['builtin-name']!;
  }

  TextStyle get addition {
    return AppTheme.getSyntaxHighlighterTheme(this)['addition']!;
  }

  TextStyle get comment {
    return AppTheme.getSyntaxHighlighterTheme(this)['comment']!;
  }

  TextStyle get quote {
    return AppTheme.getSyntaxHighlighterTheme(this)['quote']!;
  }

  TextStyle get meta {
    return AppTheme.getSyntaxHighlighterTheme(this)['meta']!;
  }

  TextStyle get emphasis {
    return AppTheme.getSyntaxHighlighterTheme(this)['emphasis']!;
  }

  TextStyle get strong {
    return AppTheme.getSyntaxHighlighterTheme(this)['strong']!;
  }
}
