import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/invitation.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invitation_service.g.dart';

@riverpod
class InvitationService extends _$InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  FutureOr<List<Invitation>> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }
    return _fetchUserInvitations(user.uid);
  }

  Future<List<Invitation>> _fetchUserInvitations(String userId) async {
    var invitationsSnapshot = await _firestore
        .collection('invitations')
        .where('mentorId', isEqualTo: userId)
        .get();

    return invitationsSnapshot.docs
        .map((doc) => Invitation.fromMap(doc.data()))
        .toList();
  }

  Future<String> createInvitation(String mentorId, String orgId) async {
    String code = '';
    bool codeExists = true;

    while (codeExists) {
      code = _generateRandomCode(6);
      var existingCode =
          await _firestore.collection('invitations').doc(code).get();
      if (!existingCode.exists) {
        codeExists = false;
      }
    }

    var existingInvitations = await _firestore
        .collection('invitations')
        .where('mentorId', isEqualTo: mentorId)
        .get();

    for (var doc in existingInvitations.docs) {
      await _firestore.collection('invitations').doc(doc.id).delete();
    }

    Invitation invitation = Invitation(
      code: code,
      mentorId: mentorId,
      orgId: orgId,
      joinRequests: [],
    );
    await _firestore
        .collection('invitations')
        .doc(code)
        .set(invitation.toMap());

    await DatabaseHelper().organizations.doc(orgId).set({
      'code': code,
    }, SetOptions(merge: true));

    state = AsyncValue.data([...state.value ?? [], invitation]);

    return code;
  }

  Future<String?> getCurrentCode(String mentorId) async {
    var existingInvitations = state.value ?? [];
    if (existingInvitations.isNotEmpty) {
      return existingInvitations.first.code;
    }

    final user = await DatabaseHelper().getUserData(mentorId);
    return await createInvitation(mentorId, user['orgId']);
  }

  String _generateRandomCode(int length) {
    const allowedChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();

    return List.generate(length, (index) {
      return allowedChars[random.nextInt(allowedChars.length)];
    }).join();
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
    final timestamp = DateTime.now();

    await _firestore.collection('invitations').doc(code).update({
      'joinRequests': FieldValue.arrayUnion([
        {
          'apprenticeId': apprenticeId,
          'status': 'pending',
          'timestamp': timestamp.toIso8601String(),
        }
      ])
    });
  }

  Future<void> updateJoinRequestStatus(
    String code,
    String apprenticeId,
    String status,
  ) async {
    var invitationDoc =
        await _firestore.collection('invitations').doc(code).get();
    var invitation =
        Invitation.fromMap(invitationDoc.data() as Map<String, dynamic>);

    var updatedRequests = invitation.joinRequests.map((request) {
      if (request['apprenticeId'] == apprenticeId) {
        return {...request, 'status': status};
      }
      return request;
    }).toList();

    await _firestore.collection('invitations').doc(code).update({
      'joinRequests': updatedRequests,
    });

    if (status == 'accepted') {
      // Fetch the organization data
      var orgDoc =
          await DatabaseHelper().organizations.doc(invitation.orgId).get();
      var orgData = orgDoc.data() as Map<String, dynamic>;

      // Check if the maximum number of apprentices has been reached
      int currentApprentices = (orgData['apprentices'] as List?)?.length ?? 0;
      int maxApprentices = orgData['maxApprentices'] ?? 0;

      if (currentApprentices >= maxApprentices) {
        throw Exception('Maximum number of apprentices reached');
      }

      // If not exceeded, proceed with accepting the apprentice
      print(
          'Accepting apprentice invitation code: $code, orgId: ${invitation.orgId}, apprenticeId: $apprenticeId');
      await DatabaseHelper().organizations.doc(invitation.orgId).set({
        'apprentices': FieldValue.arrayUnion([apprenticeId]),
      }, SetOptions(merge: true));

      await DatabaseHelper().users.doc(apprenticeId).set({
        'orgId': invitation.orgId,
      }, SetOptions(merge: true));
    }
  }

  Stream<List<Map<String, dynamic>>> getJoinRequestsStream(String userId) {
    return _firestore
        .collection('invitations')
        .where('mentorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      var invitation = Invitation.fromMap(snapshot.docs.first.data());
      return invitation.joinRequests
          .where((request) => request['status'] == 'pending')
          .map((request) => {
                ...request,
                'code': invitation.code,
                'timestamp': request['timestamp']
              })
          .toList();
    });
  }

  Stream<String> getCurrentCodeStream(String userId) {
    return _firestore
        .collection('invitations')
        .where('mentorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return '';
      }
      return snapshot.docs.first.id;
    });
  }

  Future<void> leaveOrganization(String userId) async {
    var user = await DatabaseHelper().getUserData(userId);
    var orgId = user['orgId'];

    await DatabaseHelper().organizations.doc(orgId).update({
      'apprentices': FieldValue.arrayRemove([userId]),
    });

    await DatabaseHelper().users.doc(userId).update({
      'orgId': 'Default',
    });

    state = AsyncValue.data(
        state.value!.where((invitation) => invitation.orgId != orgId).toList());
  }

  Future<void> cancelJoinRequest(String code, String apprenticeId) {
    return updateJoinRequestStatus(code, apprenticeId, 'cancelled');
  }
}
