import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/services.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new challenge in the Firestore database under the specified organization.
  ///
  /// Throws an [Exception] if the organization has reached the maximum number of apprentices.
  ///
  /// [challenge] - The challenge to be created.
  /// [organizationId] - The ID of the organization where the challenge will be created.
  Future<void> createChallenge(
      Challenge challenge, String organizationId) async {
    final organization = await DatabaseHelper().getOrganization(organizationId);

    if (organization['maxApprentices'] <= organization['apprentices'].length) {
      throw Exception(
          'Organization has reached the maximum number of apprentices');
    }

    await _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('challenges')
        .doc(challenge.id)
        .set(challenge.toJson(), SetOptions(merge: true));
  }

  /// Creates multiple challenges from a JSON file and adds them to the specified organization.
  ///
  /// Throws an [Exception] if there is an error reading the JSON file or creating the challenges.
  ///
  /// [jsonFilePath] - The path to the JSON file containing the challenges.
  /// [orgId] - The ID of the organization where the challenges will be created.
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

  /// Deletes a challenge from the Firestore database under the specified organization.
  ///
  /// Throws an [Exception] if there is an error deleting the challenge.
  ///
  /// [organizationId] - The ID of the organization where the challenge will be deleted.
  /// [challengeId] - The ID of the challenge to be deleted.

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

  /// Returns a stream of challenges for the specified organization.
  ///
  /// [organizationId] - The ID of the organization whose challenges will be streamed.
  ///
  /// Returns a [Stream] of a list of [Challenge] objects.
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

  /// Retrieves a specific challenge from the Firestore database under the specified organization.
  ///
  /// Throws an [Exception] if the challenge is not found or there is an error retrieving the challenge.
  ///
  /// [organizationId] - The ID of the organization where the challenge is located.
  /// [challengeId] - The ID of the challenge to be retrieved.
  ///
  /// Returns a [Future] of a [Challenge] object.
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


  /// Marks a challenge as completed for the current user.
  ///
  /// Throws an [Exception] if there is an error marking the challenge as completed.
  ///
  /// [challengeId] - The ID of the challenge to be marked as completed.
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

  /// Retrieves a list of completed challenges for the current user.
  ///
  /// Throws an [Exception] if there is an error retrieving the completed challenges.
  ///
  /// [userId] - The ID of the user whose completed challenges will be retrieved.
  ///
  /// Returns a [Future] of a [List] of [String] objects.
  Future<List<String>> getCompletedChallenges(String userId) async {
    final doc = await DatabaseHelper().currentUser.get();

    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> completedChallengesData =
        data['completedChallenges'] ?? [];

    return completedChallengesData.map((e) => e.toString()).toList();
  }

  /// Returns a stream of the number of challenges for the specified organization.
  ///
  /// [organizationId] - The ID of the organization whose challenges count will be streamed.
  ///
  /// Returns a [Stream] of an [int] representing the number of challenges.
  Stream<int> streamChallengesCount(String organizationId) {
    return FirebaseFirestore.instance
        .collection('organizations')
        .doc(organizationId)
        .collection('challenges')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

/// Extension method to convert a string to a DateTime object.
///
/// Returns a [DateTime] object.
///
/// Throws an error if the string is empty.
///
/// Usage: '2021-08-01'.toDateTime()
extension DateTimeParsing on String {
  DateTime toDateTime() {
    if (isEmpty) {
      return DateTime.now().add(const Duration(days: 1));
    }

    return DateTime.parse(this);
  }
}
