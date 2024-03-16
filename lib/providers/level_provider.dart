import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';

class LevelProvider extends ChangeNotifier {
  late int _currentLevel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LevelProvider() {
    _currentLevel = 1;
    loadState();
  }

  int get currentLevel => _currentLevel;

  Future<void> loadState() async {
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(DatabaseHelper().auth.currentUser!.email)
        .get();

    if (!doc.exists) {
      _currentLevel = 1;
      await saveState();
      return;
    }

    _currentLevel = doc['level'] != null ? doc['level'] as int : 1;
  }

  Future<void> saveState() async {
    await DatabaseHelper().currentUser.set({
      'level': _currentLevel,
    }, SetOptions(merge: true));
  }

  void completeLevel() async {
    _currentLevel++;
    await saveState();
    notifyListeners();
  }
}
