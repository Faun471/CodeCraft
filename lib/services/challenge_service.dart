import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/services.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createChallenge(
      Challenge challenge, String organizationId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('challenges')
          .doc(challenge.id)
          .set(challenge.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error creating challenge: $e');
    }
  }

  Future<void> createChallengesFromJson(
      String jsonFilePath, String orgId) async {
    try {
      final String response = await rootBundle.loadString(jsonFilePath);
      final List<dynamic> data = json.decode(response);
      for (var jsonText in data) {
        Challenge challenge = Challenge.fromJson(jsonText);
        await createChallenge(challenge, orgId);
      }
    } catch (e) {
      throw Exception('Error creating challenges: $e');
    }
  }

  Future<void> deleteChallenge(
      String organizationId, String challengeId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('challenges')
          .doc(challengeId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting challenge: $e');
    }
  }

  Stream<List<Challenge>> getChallengesStream(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('challenges')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              data['id'] = doc.id;

              return Challenge.fromJson(data);
            }).toList());
  }

  Future<Challenge> getChallenge(
      String organizationId, String challengeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('challenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) {
        throw Exception('Challenge not found');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      final challenge = Challenge.fromJson(data);

      return challenge;
    } catch (e) {
      throw Exception('Error getting challenge: $e');
    }
  }

  Future<void> markChallengeAsCompleted(String challengeId) async {
    try {
      await DatabaseHelper().currentUser.get().then((doc) async {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          List<dynamic> completedChallengesData =
              data['completedChallenges'] ?? [];

          if (!completedChallengesData.contains(challengeId)) {
            completedChallengesData.add(challengeId);
          }

          await DatabaseHelper().currentUser.update({
            'completedChallenges': completedChallengesData,
          });

          return;
        }
      });
    } catch (e) {
      throw Exception('Error marking challenge as completed: $e');
    }
  }

  Future<List<String>> getCompletedChallenges(String userId) async {
    final doc = await DatabaseHelper().currentUser.get();

    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> completedChallengesData =
        data['completedChallenges'] ?? [];

    return completedChallengesData.map((e) => e.toString()).toList();
  }
}

extension DateTimeParsing on String {
  DateTime toDateTime() {
    if (isEmpty) {
      return DateTime.now().add(const Duration(days: 1));
    }

    return DateTime.parse(this);
  }
}
