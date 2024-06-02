import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitCode(
      String userId, String challengeId, String code) async {
    try {
      // Create a submission document with the necessary fields
      await _firestore.collection('submissions').add({
        'userId': userId,
        'challengeId': challengeId,
        'code': code,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error submitting code: $e');
    }
  }
}
