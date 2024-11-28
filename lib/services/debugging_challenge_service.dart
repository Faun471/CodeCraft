import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/debugging_challenge.dart';
import 'package:codecraft/services/database_helper.dart';

class DebuggingChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDebuggingChallenge(
      DebuggingChallenge challenge, String organizationId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('debuggingChallenges')
          .doc(challenge.id)
          .set(challenge.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied');
      } else {
        throw Exception('Error creating debugging challenge: $e');
      }
    }
  }

  Future<void> deleteDebuggingChallenge(
      String organizationId, String challengeId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('debuggingChallenges')
          .doc(challengeId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting debugging challenge: $e');
    }
  }

  Future<List<DebuggingChallenge>> getDebuggingChallenges(
      String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('debuggingChallenges')
          .get();

      List<DebuggingChallenge> challenges = [];

      if (snapshot.docs.isEmpty) {
        return challenges;
      }

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        challenges.add(DebuggingChallenge.fromJson(data));
      }

      return challenges;
    } catch (e) {
      throw Exception('Error getting debugging challenges: $e');
    }
  }

  Future<DebuggingChallenge> getDebuggingChallenge(
      String organizationId, String challengeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('debuggingChallenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) {
        throw Exception('Debugging challenge not found');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      final challenge = DebuggingChallenge.fromJson(data);

      return challenge;
    } catch (e) {
      throw Exception('Error getting debugging challenge: $e');
    }
  }

  Future<void> markDebuggingChallengeAsCompleted(String challengeId) async {
    try {
      await DatabaseHelper().currentUser.get().then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          if (data['completedDebuggingChallenges'] == null) {
            DatabaseHelper().currentUser.set({
              'completedDebuggingChallenges': [challengeId],
            }, SetOptions(merge: true));
            return;
          }

          List<String> completedChallenges =
              (data['completedDebuggingChallenges'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();

          if (completedChallenges.contains(challengeId)) {
            return;
          }

          completedChallenges.add(challengeId);

          DatabaseHelper().currentUser.set({
            'completedDebuggingChallenges': completedChallenges,
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      throw Exception('Error marking debugging challenge as completed: $e');
    }
  }

  Future<List<String>> getCompletedDebuggingChallenges() async {
    final doc = await DatabaseHelper().currentUser.get();

    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> completedChallengesData =
        data['completedDebuggingChallenges'] ?? [];

    return completedChallengesData.map((e) => e.toString()).toList();
  }

  Stream<List<DebuggingChallenge>> getDebuggingChallengesStream(
      String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('debuggingChallenges')
        .snapshots()
        .map((snapshot) {
      List<DebuggingChallenge> challenges = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        challenges.add(DebuggingChallenge.fromJson(data));
      }

      return challenges;
    });
  }

  // stream how many debugging challenges have been given by the mentor to the organization
  Stream<int> streamDebuggingChallengeCount(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('debuggingChallenges')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
