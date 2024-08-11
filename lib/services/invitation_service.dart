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
      code = _generateRandomCode(8);
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

    Invitation invitation =
        Invitation(code: code, mentorId: mentorId, orgId: orgId);
    await _firestore
        .collection('invitations')
        .doc(code)
        .set(invitation.toMap());

    await DatabaseHelper().organisations.doc(orgId).set({
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
    const allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
    DocumentReference docRef = _firestore.collection('joinRequests').doc();

    await docRef.set({
      'id': docRef.id,
      'code': code,
      'apprenticeId': apprenticeId,
      'status': 'pending',
    });
  }

  Future<void> updateJoinRequestStatus(String requestId, String status) async {
    await _firestore
        .collection('joinRequests')
        .doc(requestId)
        .update({'status': status});

    if (status == 'accepted') {
      var requestSnapshot =
          await _firestore.collection('joinRequests').doc(requestId).get();

      var code = requestSnapshot['code'];
      var apprenticeId = requestSnapshot['apprenticeId'];

      var invitationSnapshot =
          await _firestore.collection('invitations').doc(code).get();

      await DatabaseHelper()
          .organisations
          .doc(invitationSnapshot['orgId'])
          .set({
        'apprentices': FieldValue.arrayUnion(
          [apprenticeId],
        )
      }, SetOptions(merge: true));

      await DatabaseHelper().users.doc(apprenticeId).set({
        'orgId': invitationSnapshot['orgId'],
      }, SetOptions(merge: true));
    }

    await _firestore.collection('joinRequests').doc(requestId).delete();
  }

  Future<List<Map<String, dynamic>>> getJoinRequests(String mentorId) async {
    var invitationSnapshot = await _firestore
        .collection('invitations')
        .where('mentorId', isEqualTo: mentorId)
        .get();

    if (invitationSnapshot.docs.isEmpty) {
      return [];
    }

    String code = invitationSnapshot.docs.first.id;

    var joinRequestsSnapshot = await _firestore
        .collection('joinRequests')
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

  Future<bool> hasJoinRequest(String apprenticeId, String orgId) async {
    return await _firestore
        .collection('joinRequests')
        .where('apprenticeId', isEqualTo: apprenticeId)
        .where('status', isEqualTo: 'pending')
        .get()
        .then((value) => value.docs.isNotEmpty);
  }
}
