import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/models/submission.dart';
import 'package:codecraft/services/database_helper.dart';

class CodeClashService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> createCodeClash(
      CodeClash codeClash, String organizationId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('codeClashes')
          .doc(codeClash.id)
          .set(codeClash.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied');
      } else {
        throw Exception('Error creating Code Clash: $e');
      }
    }
  }

  Future<CodeClash> getCodeClash(
      String organizationId, String codeClashId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('codeClashes')
          .doc(codeClashId)
          .get();

      if (!doc.exists) {
        throw Exception('Code Clash not found');
      }

      return CodeClash.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error getting Code Clash: $e');
    }
  }

  Stream<List<Submission>> getSubmissionsStream(
      String organizationId, String codeClashId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('codeClashes')
        .doc(codeClashId)
        .collection('submissions')
        .orderBy('submissionTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Submission.fromJson(data);
      }).toList();
    });
  }

  Future<CodeClashParticipant> getParticipantById(String userId) async {
    final userData = await _dbHelper.getUserData(userId);

    return CodeClashParticipant(
      id: userId,
      displayName: '${userData['firstName']} ${userData['lastName']}',
      score: 0, // Default score, will be updated later
      photoUrl: userData['photoUrl'],
    );
  }

  Future<void> updateCodeClash(
    CodeClash codeClash,
    String organizationId,
  ) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('codeClashes')
          .doc(codeClash.id)
          .update(codeClash.toJson());
    } catch (e) {
      throw Exception('Error updating Code Clash: $e');
    }
  }

  // Delete a Code Clash
  Future<void> deleteCodeClash(
      String organizationId, String codeClashId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('codeClashes')
          .doc(codeClashId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting Code Clash: $e');
    }
  }

  // Start a Code Clash
  Future<void> startCodeClash(String organizationId, String codeClashId) async {
    await _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('codeClashes')
        .doc(codeClashId)
        .update({
      'status': 'active',
      'startTime': FieldValue.serverTimestamp(),
    });
  }

  // End a Code Clash
  Future<void> endCodeClash(String organizationId, String codeClashId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('codeClashes')
          .doc(codeClashId)
          .update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error ending Code Clash: $e');
    }
  }

  Future<void> submitSolution(
    String organizationId,
    String codeClashId,
    String userId,
    String solution,
  ) async {
    try {
      final user = await _dbHelper.getUserData(userId);
      final submission = Submission(
        userId: userId,
        solution: solution,
        displayName: user['displayName'],
        photoUrl: user['photoUrl'],
        submissionTime: DateTime.now(),
        score: 0,
      );

      final updatedSubmission = submission.copyWith(
        score: await _computeScore(submission, codeClashId, organizationId),
      );

      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('codeClashes')
          .doc(codeClashId)
          .collection('submissions')
          .doc(userId)
          .set(updatedSubmission.toJson());
    } catch (e) {
      throw Exception('Error submitting solution: $e');
    }
  }

  Future<int> _computeScore(
      Submission submission, String codeClashId, String organizationId) async {
    final submissionTime = submission.submissionTime;

    final CodeClashService codeClashService = CodeClashService();
    final codeClash = await codeClashService.getCodeClash(
      organizationId,
      codeClashId,
    );

    final startTime = codeClash.startTime!.toDate();
    final duration = submissionTime.difference(startTime);
    final timeLimit = Duration(minutes: codeClash.timeLimit);

    final score = _computeScoreFromDuration(duration, timeLimit);
    return score;
  }

  int _computeScoreFromDuration(Duration duration, Duration timeLimit) {
    final timeLimitInSeconds = timeLimit.inSeconds;
    final durationInSeconds = duration.inSeconds;

    if (durationInSeconds > timeLimitInSeconds) {
      return 0;
    }

    // Calculate the score out of 1000
    final score =
        ((timeLimitInSeconds - durationInSeconds) / timeLimitInSeconds) * 1000;
    return score.round();
  }

  Future<bool> hasUserSubmitted(
      String organizationId, String codeClashId, String userId) async {
    final snapshot = await _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('codeClashes')
        .doc(codeClashId)
        .collection('submissions')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Stream<List<CodeClash>> getUpcomingCodeClashesStream(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('codeClashes')
        .where('status', isEqualTo: 'pending')
        .where('startTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CodeClash.fromJson(doc.data()))
            .toList());
  }

  // Get a specific Code Clash as a stream
  Stream<CodeClash> getCodeClashStream(
    String organizationId,
    String codeClashId,
  ) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('codeClashes')
        .doc(codeClashId)
        .snapshots()
        .map((doc) => CodeClash.fromJson(doc.data()!));
  }

  Stream<List<CodeClash>> getCodeClashesStream(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('codeClashes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CodeClash.fromJson(doc.data()))
            .toList());
  }

  Future<void> joinCodeClash(
      String codeClashId, CodeClashParticipant participant) async {
    final db = DatabaseHelper();
    final userData = await db.getUserData(participant.id);
    final user = AppUser.fromMap(userData);

    await db.organizations
        .doc(user.orgId)
        .collection('codeClashes')
        .doc(codeClashId)
        .update({
      'participants': FieldValue.arrayUnion(
        [
          participant.toJson(),
        ],
      )
    });
  }

  // Leave a Code Clash
  Future<void> leaveCodeClash(String codeClashId, String userId) async {
    try {
      final db = DatabaseHelper();
      final userData = await db.getUserData(userId);
      final user = AppUser.fromMap(userData);

      await _firestore
          .collection('organizations')
          .doc(user.orgId)
          .collection('codeClashes')
          .doc(codeClashId)
          .update({
        'participants': FieldValue.arrayRemove([
          {
            'id': user.id,
          }
        ])
      });
    } catch (e) {
      throw Exception('Error leaving Code Clash: $e');
    }
  }

  // stream how many clashes are active within the organization
  Stream<int> streamActiveCodeClashesCount(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('codeClashes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
