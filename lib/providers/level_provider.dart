import 'package:codecraft/models/user.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class LevelProvider extends ChangeNotifier {
  late int _currentLevel;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Database _db;
  String _username = User().username ?? 'default';

  LevelProvider() {
    _currentLevel = 1;
  }

  int get currentLevel => _currentLevel;

  void updateUsername() {
    _username = User().username ?? 'default';
  }

  String get username => _username;

  Future<void> loadState() async {
    updateUsername();

    _db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await _db
        .query('levels', where: 'username = ?', whereArgs: [_username]);

    if (result.isEmpty) {
      _currentLevel = 1;
      await saveState();
      return;
    }

    _currentLevel = result[0]['level'] != null ? result[0]['level'] as int : 1;
  }

  Future<void> saveState() async {
    updateUsername();

    final Database db = await _databaseHelper.database;
    await db.insert(
      'levels',
      {'username': _username, 'level': _currentLevel},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void completeLevel() async {
    updateUsername();
    _currentLevel++;
    await saveState();
    notifyListeners();
  }
}
