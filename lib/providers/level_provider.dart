import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/models/app_user.dart';

class LevelProvider extends ChangeNotifier {
  late int _currentLevel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _username;

  LevelProvider() {
    _currentLevel = 1;
    _username = username;
    loadState();
  }

  int get currentLevel => _currentLevel;

  String get username => AppUser().email ?? 'default';

  Future<void> loadState() async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(username).get();

    if (!doc.exists) {
      _currentLevel = 1;
      await saveState();
      return;
    }

    _currentLevel = doc['level'] != null ? doc['level'] as int : 1;
  }

  Future<void> saveState() async {
    await _firestore.collection('users').doc(_username).set({
      'level': _currentLevel,
    }, SetOptions(merge: true));
  }

  void completeLevel() async {
    _currentLevel++;
    await saveState();
    notifyListeners();
  }
}
