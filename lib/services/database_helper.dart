import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    Firebase.initializeApp();
  }

  FirebaseAuth get auth {
    return _auth;
  }

  FirebaseFirestore get firestore {
    return _firestore;
  }

  CollectionReference get users {
    return _firestore.collection('users');
  }
}
