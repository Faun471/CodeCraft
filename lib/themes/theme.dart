import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double defaultFontSize = 14.0;
  static const double titleFontSize = 20.0;
  static const double borderRadius = 8.0;

  static TextStyle baseTextStyle({
    double fontSize = defaultFontSize,
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

  static AppBarTheme baseAppBarTheme({
    Color backgroundColor = Colors.orange,
    Color iconColor = Colors.white,
    Color titleColor = Colors.white,
    double elevation = 0.0,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      iconTheme: IconThemeData(color: iconColor),
      titleTextStyle: baseTextStyle(
        color: titleColor,
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
      ),
      elevation: elevation,
    );
  }

  static ElevatedButtonThemeData baseElevatedButtonTheme({
    Color backgroundColor = Colors.orange,
    double borderRadius = AppTheme.borderRadius,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: backgroundColor,
      ).merge(
        ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            return states.contains(WidgetState.disabled)
                ? Colors.grey
                : Colors.white;
          }),
          textStyle: WidgetStateProperty.all<TextStyle>(
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData baseOutlinedButtonTheme({
    Color sideColor = Colors.white,
    double borderRadius = AppTheme.borderRadius,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: BorderSide(color: sideColor),
      ).merge(
        ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            return states.contains(WidgetState.disabled)
                ? Colors.grey
                : states.contains(WidgetState.pressed)
                    ? sideColor
                    : Colors.white;
          }),
          textStyle: WidgetStateProperty.all<TextStyle>(
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static InputDecorationTheme baseInputDecorationTheme(
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
        borderSide: const BorderSide(color: Color.fromARGB(255, 150, 147, 147)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: focusedBorderColor),
      ),
      labelStyle: baseTextStyle(color: color),
      hintStyle: baseTextStyle(color: Colors.blueGrey),
    );
  }

  static TextTheme baseTextTheme(Color color) {
    return TextTheme(
      displayLarge: baseTextStyle(
          fontSize: 34, fontWeight: FontWeight.bold, color: color),
      displayMedium: baseTextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: color),
      displaySmall: baseTextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: color),
      headlineLarge: baseTextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: color),
      headlineMedium: baseTextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: color),
      headlineSmall: baseTextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: color),
      titleLarge: baseTextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: color),
      titleMedium: baseTextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: color),
      titleSmall: baseTextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: color),
      bodyLarge: baseTextStyle(fontSize: 16, color: color),
      bodyMedium: baseTextStyle(fontSize: 14, color: color),
      bodySmall: baseTextStyle(fontSize: 12, color: color),
      labelLarge: baseTextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: color),
      labelMedium: baseTextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: color),
      labelSmall: baseTextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: color),
    );
  }

  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.orange,
    appBarTheme: baseAppBarTheme(),
    colorScheme: const ColorScheme.light(
      primary: Colors.orange,
      secondary: Colors.orange,
    ),
    inputDecorationTheme: baseInputDecorationTheme(
        const Color.fromARGB(255, 21, 21, 21),
        focusedBorderColor: Colors.orange,
        borderColor: Colors.black),
    elevatedButtonTheme: baseElevatedButtonTheme(),
    outlinedButtonTheme: baseOutlinedButtonTheme(),
    textTheme: baseTextTheme(const Color.fromARGB(255, 21, 21, 21)),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.orange,
    colorScheme: const ColorScheme.dark(
      primary: Colors.orange,
      secondary: Colors.orange,
    ),
    appBarTheme: baseAppBarTheme(),
    inputDecorationTheme: baseInputDecorationTheme(Colors.white,
        focusedBorderColor: Colors.orange, borderColor: Colors.white),
    elevatedButtonTheme: baseElevatedButtonTheme(),
    outlinedButtonTheme: baseOutlinedButtonTheme(),
    textTheme: baseTextTheme(Colors.white),
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
    return _camelCaseToTitle(toString().split('.').last);
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
