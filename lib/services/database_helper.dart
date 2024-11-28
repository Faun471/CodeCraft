import 'package:codecraft/firebase_options.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/organisation.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A helper class for managing database operations.
///
/// This class provides methods to perform CRUD (Create, Read, Update, Delete)
/// operations on the database. It abstracts the underlying database
/// implementation and provides a simple interface for interacting with the
/// database.
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

  CollectionReference get organizations =>
      _firestore.collection('organizations');

  CollectionReference get invitations => _firestore.collection('invitations');

  CollectionReference get joinRequests => _firestore.collection('joinRequests');

  DocumentReference get currentUser {
    return users.doc(FirebaseAuth.instance.currentUser!.uid);
  }

  /// Retrieves user data from the database for the given user ID.
  ///
  /// Takes a [userId] as a parameter and returns a [Future] that resolves
  /// to a [Map<String, dynamic>] containing the user data.
  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot doc = await users.doc(userId).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }

    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.uid == userId) {
      return {
        'id': FirebaseAuth.instance.currentUser!.uid,
        'displayName': FirebaseAuth.instance.currentUser!.displayName,
        'email': FirebaseAuth.instance.currentUser!.email,
        'phoneNumber': FirebaseAuth.instance.currentUser!.phoneNumber,
        'photoUrl': FirebaseAuth.instance.currentUser!.photoURL ??
            'https://api.dicebear.com/9.x/thumbs/png?seed=${FirebaseAuth.instance.currentUser!.uid}',
      };
    }

    return {};
  }

  /// Retrieves the current user's data from the database.
  ///
  /// Returns a [Future] that resolves to a [Map<String, dynamic>] containing
  /// the current user's data.
  ///
  /// Throws an [Exception] if the current user is not authenticated.
  ///
  /// If the current user is not authenticated, the method will throw an
  /// exception with the message "User not authenticated".
  Future<void> createUser(String userId, Map<String, String> userData,
      String accountType, String orgId) async {
    await users.doc(userId).set({
      'firstName': userData['firstName']!,
      'mi': userData['mi'] ?? '',
      'lastName': userData['lastName']!,
      'suffix': userData['suffix'] ?? '',
      'email': userData['email']!,
      'displayName': userData['displayName'] ??
          '${userData['firstName']} ${userData['lastName']}',
      'phoneNumber': userData['phoneNumber']!,
      'accountType': accountType,
      'preferredColor': 'ff9c27b0',
      'level': 1,
      'experience': 0,
      'orgId': orgId,
      'photoUrl': userData['photoUrl'] ??
          'https://api.dicebear.com/9.x/thumbs/png?seed=$userId',
      'id': userId,
    }, SetOptions(merge: true));
  }

  /// Creates a new organization for the given mentor ID.
  ///
  /// Takes a [mentorId] as a parameter and returns a [Future] that resolves
  /// to a [String] containing the ID of the newly created organization.
  ///
  /// The method creates a new organization with the name "Mentor Organization"
  /// and a default plan of "Free". It also creates a pre-made quiz for the
  /// organization.
  ///
  /// The method returns the ID of the newly created organization.
  Future<String> createOrganization(String mentorId) async {
    DocumentReference orgRef = await organizations.add({
      'orgName': 'Mentor Organization',
      'orgDescription': '',
      'mentorId': mentorId,
      'createdAt': Timestamp.now(),
      'plan': 'Free',
      'maxApprentices': 5,
      'apprentices': [],
      'planStatus': 'active',
    });

    // create pre-made quiz
    QuizService quizService = QuizService();
    await quizService.createQuiz(
      Quiz(
        id: 'quiz-1',
        title: 'Welcome Quiz',
        duration: Timestamp.now().toDate().toIso8601String(),
        questions: [
          Question(
            questionText: 'This is a sample question',
            answerOptions: [
              'Option 1',
              'Option 2',
              'Option 3',
              'Option 4',
            ],
            correctAnswer: 'Option 1',
            initialTimer: 30,
            penaltySeconds: 5,
          ),
        ],
      ),
      orgRef.id,
    );

    return orgRef.id;
  }

  Future<List<Map<String, dynamic>>> getJoinRequests(String mentorId) async {
    QuerySnapshot querySnapshot =
        await joinRequests.where('mentorId', isEqualTo: mentorId).get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<AppUser>> getOrganizationMembers(String orgId) async {
    QuerySnapshot querySnapshot =
        await users.where('orgId', isEqualTo: orgId).get();
    return querySnapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> getOrganizationStreamForMentor(String mentorId) {
    return organizations.where('mentorId', isEqualTo: mentorId).snapshots();
  }

  Stream<DocumentSnapshot> getOrganizationStream(String orgId) {
    return organizations.doc(orgId).snapshots();
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return users.doc(userId).snapshots();
  }

  Future<String> getCurrentUserOrgId() async {
    DocumentSnapshot doc = await currentUser.get();
    if (doc.exists) {
      final user = doc.data() as Map<String, dynamic>?;

      if (user?['orgId'] == null) {
        return defaultOrgId;
      }

      return user!['orgId'] as String;
    }
    return defaultOrgId;
  }

  Future<List<Map<String, dynamic>>> getQuizLeaderboard(String orgId) async {
    QuerySnapshot querySnapshot = await users
        .where('orgId', isEqualTo: orgId)
        .orderBy('completedQuizzes', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'displayName':
            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        'score': (data['completedQuizzes'] as List?)?.length ?? 0,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getChallengesLeaderboard(
      String orgId) async {
    QuerySnapshot querySnapshot = await users
        .where('orgId', isEqualTo: orgId)
        .orderBy('completedChallenges', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'displayName':
            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        'completed': (data['completedChallenges'] as List?)?.length ?? 0,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getLevelsLeaderboard(String orgId) async {
    QuerySnapshot querySnapshot = await users
        .where('orgId', isEqualTo: orgId)
        .orderBy('level', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'displayName':
            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        'level': (data['level'] as num?)?.toDouble() ?? 1.0,
      };
    }).toList();
  }

  Stream<List<AppUser>> getOrganizationMembersStream(String orgId) {
    return users
        .where('orgId', isEqualTo: orgId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final appUser =
                  AppUser.fromMap(doc.data() as Map<String, dynamic>);
              return appUser;
            }).toList());
  }

  Stream<List<AppUser>> getQuizLeaderboardStream(String orgId) {
    return users
        .where('orgId', isEqualTo: orgId)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      List<AppUser> users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppUser.fromMap(data);
      }).toList();

      users
          .sort((a, b) => b.quizResults.length.compareTo(a.quizResults.length));
      return users;
    });
  }

  Stream<List<AppUser>> getChallengesLeaderboardStream(String orgId) {
    return users
        .where('orgId', isEqualTo: orgId)
        .orderBy('completedChallenges', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return AppUser.fromMap(data);
            }).toList());
  }

  Stream<List<AppUser>> getLevelsLeaderboardStream(String orgId) {
    return users
        .where('orgId', isEqualTo: orgId)
        .orderBy('level', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return AppUser.fromMap(data);
            }).toList());
  }

  Future<Map<String, dynamic>> getOrganization(String orgId) async {
    DocumentSnapshot doc = await organizations.doc(orgId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['maxApprentices'] == null) {
        await organizations.doc(orgId).update({'maxApprentices': 5});
        data['maxApprentices'] = 5;
      }

      if (data['plan'] == null) {
        await organizations.doc(orgId).update({'plan': 'Free'});
        data['plan'] = 'Free';
      }

      return data;
    }

    return {};
  }

  Future<void> updateOrganizationDetails(
      String orgId, Organization organization) async {
    await organizations.doc(orgId).set(
          organization.toMap(),
          SetOptions(merge: true),
        );
  }
}
