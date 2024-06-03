import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class ThemeProvider extends ChangeNotifier {
  Color _preferredColor = Colors.orange;

  Color get preferredColor => _preferredColor;

  Future<void> updateColor(Color newColor, BuildContext? context) async {
    _preferredColor = newColor;

    await DatabaseHelper().currentUser.set({
      'preferredColor': _preferredColor.value.toRadixString(16),
    }, SetOptions(merge: true));

    if (context != null && context.mounted) {
      _updateTheme(context);
    }

    notifyListeners();
  }

  void _updateTheme(BuildContext context, {bool notify = true}) {
    final lightTheme = _createLightTheme(context);
    final darkTheme = _createDarkTheme(context);
  
    AdaptiveTheme.of(context).setTheme(
      light: lightTheme,
      dark: darkTheme,
      notify: notify,
    );
  }

  ThemeData _createLightTheme(BuildContext context) {
    return AppTheme.lightTheme.copyWith(
      primaryColor: _preferredColor,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            backgroundColor: _preferredColor,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
              backgroundColor: WidgetStateProperty.all(_preferredColor),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
              side: WidgetStateProperty.all(
                BorderSide(color: _preferredColor),
              ),
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _preferredColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _preferredColor),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              color: _preferredColor,
            ),
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(
              color: Colors.blueGrey,
            ),
      ),
    );
  }

  ThemeData _createDarkTheme(BuildContext context) {
    return AppTheme.darkTheme.copyWith(
      primaryColor: _preferredColor,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            backgroundColor: _preferredColor,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
              backgroundColor: WidgetStateProperty.all(_preferredColor),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
              side: WidgetStateProperty.all(
                BorderSide(color: _preferredColor),
              ),
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _preferredColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _preferredColor),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              color: _preferredColor,
            ),
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(
              color: Colors.blueGrey,
            ),
      ),
    );
  }
}
