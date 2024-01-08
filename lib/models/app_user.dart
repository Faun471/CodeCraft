import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  static final AppUser _singleton = AppUser._internal();
  final FirebaseAuth _auth = DatabaseHelper().auth;
  User? _user;

  factory AppUser() {
    return _singleton;
  }

  AppUser._internal() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
    });
  }

  String? get email => _user?.email;

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
  }
}
