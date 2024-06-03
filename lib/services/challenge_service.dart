import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createChallenge(
      Challenge challenge, String organizationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challenge.id)
          .set({
        'instructions': challenge.instructions,
        'sampleCode': challenge.sampleCode,
        'className': challenge.className,
        'unitTests': challenge.unitTests
            .map((test) => {
                  'input': test.input,
                  'expectedOutput': {
                    'value': test.expectedOutput.value,
                    'type': test.expectedOutput.type,
                  },
                  'methodName': test.methodName,
                })
            .toList(),
        'organizationId': organizationId,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error creating challenge: $e');
    }
  }

  Future<List<Challenge>> getChallenges(String organizationId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('challenges')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      return snapshot.docs
          .map((doc) => Challenge(
                id: doc.id,
                instructions: doc['instructions'],
                sampleCode: doc['sampleCode'],
                className: doc['className'],
                unitTests: (doc['unitTests'] as List)
                    .map((e) => UnitTest(
                          input: e['input'],
                          expectedOutput: e['expectedOutput'],
                          methodName: e['methodName'],
                        ))
                    .toList(),
              ))
          .toList();
    } catch (e) {
      throw Exception('Error getting challenges: $e');
    }
  }

  Future<Challenge> getChallenge(String challengeId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .get();

    return Challenge(
      id: doc.id,
      instructions: doc['instructions'],
      sampleCode: doc['sampleCode'],
      className: doc['className'],
      unitTests: (doc['unitTests'] as List)
          .map((e) => UnitTest(
                input: e['input'],
                expectedOutput: ExpectedOutput(
                  value: e['expectedOutput']['value'],
                  type: e['expectedOutput']['type'],
                ),
                methodName: e['methodName'],
              ))
          .toList(),
    );
  }

  Future<void> markChallengeAsCompleted(
      String userId, String challengeId) async {
    try {
      await _firestore.collection('completedChallenges').doc(userId).set({
        'challengeIds': FieldValue.arrayUnion([challengeId]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error marking challenge as completed: $e');
    }
  }

  Future<List<String>> getCompletedChallenges(String userId) async {
    try {
      var querySnapshot = await _firestore
          .collection('completedChallenges')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc['challengeId'] as String)
          .toList();
    } catch (e) {
      throw Exception('Error fetching completed challenges: $e');
    }
  }
}
