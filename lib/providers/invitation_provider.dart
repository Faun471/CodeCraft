import 'package:codecraft/models/invitation.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:flutter/material.dart';

class InvitationProvider with ChangeNotifier {
  final InvitationService _invitationService = InvitationService();

  Future<void> joinOrgWithCode(String code) async {
    String apprenticeId = DatabaseHelper().auth.currentUser!.uid;
    Invitation? invitation = await _invitationService.getInvitation(code);
    if (invitation != null) {
      await _invitationService.createJoinRequest(code, apprenticeId);
    } else {
      throw Exception('Invalid code');
    }
  }

  Future<List<Map<String, dynamic>>> getJoinRequests() async {
    String mentorId = 'currentMentor';
    return await _invitationService.getJoinRequests(mentorId);
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _invitationService.updateJoinRequestStatus(requestId, status);
    notifyListeners();
  }

  Future<void> createNewInvitation(String mentorId, String orgId) async {
    await _invitationService.createInvitation(mentorId, orgId);
    notifyListeners();
  }
}
