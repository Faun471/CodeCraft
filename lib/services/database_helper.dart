import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String defaultOrgId = 'Default';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  FirebaseAuth get auth => _auth;

  FirebaseFirestore get firestore => _firestore;

  CollectionReference get users => _firestore.collection('users');

  CollectionReference get organizations =>
      _firestore.collection('organizations');

  CollectionReference get invitations => _firestore.collection('invitations');

  CollectionReference get joinRequests =>
      _firestore.collection('join_requests');

  DocumentReference get currentUser {
    return users.doc(_auth.currentUser!.uid);
  }

  Future<void> createUser(String userId, Map<String, String> userData,
      String accountType, String orgId) async {
    await users.doc(userId).set({
      'first_name': userData['first_name']!,
      'mi': userData['mi']!,
      'last_name': userData['last_name']!,
      'suffix': userData['suffix']!,
      'email': userData['email']!,
      'phone_number': userData['phone_number']!,
      'account_type': accountType,
      'preferred_color': 'ff9c27b0',
      'level': 1,
      'orgId': orgId,
    }, SetOptions(merge: true));
  }

  Future<String> createOrganization(String mentorId) async {
    DocumentReference orgRef = await organizations.add({
      'orgName': 'Mentor Organization',
      'orgDescription': '',
      'mentorId': mentorId,
      'createdAt': Timestamp.now(),
    });
    return orgRef.id;
  }

  Future<List<Map<String, dynamic>>> getJoinRequests(String mentorId) async {
    QuerySnapshot querySnapshot =
        await joinRequests.where('mentorId', isEqualTo: mentorId).get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getOrganizationMembers(
      String orgId) async {
    QuerySnapshot querySnapshot =
        await users.where('orgId', isEqualTo: orgId).get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
