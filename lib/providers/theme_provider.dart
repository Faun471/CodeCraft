import 'package:codecraft/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider extends ChangeNotifier {
  Color _preferredColor = Colors.blue;

  Color get preferredColor => _preferredColor;

  void updateColor(Color newColor) {
    _preferredColor = newColor;
    saveColorToFirestore();
    notifyListeners();
  }

  Future<void> saveColorToFirestore() async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(AppUser().email);

    await docRef.set(
        {'preferredColor': _preferredColor.value.toRadixString(16)},
        SetOptions(merge: true));
  }

  Future<void> loadColorFromFirestore() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(AppUser().email)
        .get();

    if (!doc.exists) {
      _preferredColor = Colors.blue;
      await saveColorToFirestore();
      return;
    }

    updateColor(Color(int.parse(doc['preferredColor'] as String, radix: 16)));
    notifyListeners();

    return;
  }
}
