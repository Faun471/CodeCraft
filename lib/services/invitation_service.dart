import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/invitation.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createInvitation(String mentorId, String orgId) async {
    String code = _firestore.collection('invitations').doc().id;

    var existingInvitations = await _firestore
        .collection('invitations')
        .where('mentorId', isEqualTo: mentorId)
        .get();

    for (var doc in existingInvitations.docs) {
      await _firestore.collection('invitations').doc(doc.id).delete();
    }

    Invitation invitation =
        Invitation(code: code, mentorId: mentorId, orgId: orgId);
    await _firestore
        .collection('invitations')
        .doc(code)
        .set(invitation.toMap());
  }

  Future<Invitation?> getInvitation(String code) async {
    DocumentSnapshot doc =
        await _firestore.collection('invitations').doc(code).get();
    if (doc.exists) {
      return Invitation.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> createJoinRequest(String code, String apprenticeId) async {
    await _firestore.collection('join_requests').add({
      'code': code,
      'apprenticeId': apprenticeId,
      'status': 'pending',
    });
  }

  Future<void> updateJoinRequestStatus(String requestId, String status) async {
    await _firestore
        .collection('join_requests')
        .doc(requestId)
        .update({'status': status});
  }

  Future<List<Map<String, dynamic>>> getJoinRequests(String mentorId) async {
    // Fetch the current invitation code for the mentor
    var invitationSnapshot = await _firestore
        .collection('invitations')
        .where('mentorId', isEqualTo: mentorId)
        .get();

    if (invitationSnapshot.docs.isEmpty) {
      return [];
    }

    String code = invitationSnapshot.docs.first.id;

    // Fetch join requests associated with the current invitation code
    var joinRequestsSnapshot = await _firestore
        .collection('join_requests')
        .where('code', isEqualTo: code)
        .where('status', isEqualTo: 'pending')
        .get();

    List<Map<String, dynamic>> joinRequests =
        joinRequestsSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'code': doc['code'],
        'apprenticeId': doc['apprenticeId'],
        'status': doc['status'],
      };
    }).toList();

    return joinRequests;
  }
}
