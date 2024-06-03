import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class AppUser extends ChangeNotifier {
  static final AppUser _instance = AppUser._privateConstructor();

  AppUser._privateConstructor({Map<String, dynamic>? data})
      : _data = data ?? {};

  static AppUser get instance {
    if (FirebaseAuth.instance.currentUser != null) {
      return _instance;
    } else {
      throw Exception("User is not logged in");
    }
  }

  Map<String, dynamic> _data;

  Future<void> fetchData() async {
    await DatabaseHelper().currentUser.get().then((doc) {
      if (doc.exists) {
        _data = doc.data() as Map<String, dynamic>;
      }

      Logger('AppUser').info('Fetched data: $_data');
    });
    notifyListeners();
  }

  Future<void> updateData(Map<String, dynamic> newData) async {
    _data = {..._data, ...newData};
    await DatabaseHelper().currentUser.set(data, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> levelUp() async {
    await updateData({'level': _data['level'] + 1});

    notifyListeners();
  }

  get data => _data;

  get userId => FirebaseAuth.instance.currentUser!.uid;
}
