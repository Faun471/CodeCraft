import 'package:codecraft/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String defaultOrgId = 'Default';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  FirebaseFirestore get firestore => _firestore;

  CollectionReference get users => _firestore.collection('users');

  CollectionReference get organisations =>
      _firestore.collection('organizations');

  CollectionReference get invitations => _firestore.collection('invitations');

  CollectionReference get joinRequests => _firestore.collection('joinRequests');

  DocumentReference get currentUser {
    return users.doc(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot doc = await users.doc(userId).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> createUser(String userId, Map<String, String> userData,
      String accountType, String orgId) async {
    await users.doc(userId).set({
      'firstName': userData['firstName']!,
      'mi': userData['mi']!,
      'lastName': userData['lastName']!,
      'suffix': userData['suffix']!,
      'email': userData['email']!,
      'phoneNumber': userData['phoneNumber']!,
      'accountType': accountType,
      'preferredColor': 'ff9c27b0',
      'level': 1,
      'orgId': orgId,
    }, SetOptions(merge: true));
  }

  Future<String> createOrganization(String mentorId) async {
    DocumentReference orgRef = await organisations.add({
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
