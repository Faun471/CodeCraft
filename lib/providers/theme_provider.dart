import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class ThemeProvider extends ChangeNotifier {
  Color _preferredColor = Colors.blue;

  Color get preferredColor => _preferredColor;

  void updateColor(Color newColor, BuildContext? context) {
    _preferredColor = newColor;
    saveColorToFirestore();
    if (context != null) _updateTheme(context);
    notifyListeners();
  }

  Future<void> saveColorToFirestore() async {
    DatabaseHelper().currentUser.set({
      'preferredColor': _preferredColor.value.toRadixString(16),
    }, SetOptions(merge: true));
  }

  Future<Color> loadColorFromFirestore() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(DatabaseHelper().auth.currentUser!.email)
        .get();

    if (!doc.exists) {
      _preferredColor = Colors.blue;
      await saveColorToFirestore();
      return _preferredColor;
    }

    updateColor(
        Color(int.parse(doc['preferredColor'] as String, radix: 16)), null);
    notifyListeners();

    return _preferredColor;
  }

  void _updateTheme(BuildContext context) {
    AdaptiveTheme.of(context).setTheme(
      light: AppTheme.lightTheme.copyWith(
        primaryColor: _preferredColor,
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: _preferredColor,
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                backgroundColor: MaterialStatePropertyAll(_preferredColor),
              ),
        ),
      ),
      dark: AppTheme.darkTheme.copyWith(
        primaryColor: _preferredColor,
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: _preferredColor,
            ),
      ),
    );
  }
}
