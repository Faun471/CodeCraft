import 'package:codecraft/models/invitation.dart';
import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invitation_provider.g.dart';

class InvitationState {
  final List<Map<String, dynamic>> joinRequests;
  final String? currentCode;

  InvitationState({required this.joinRequests, this.currentCode});

  InvitationState copyWith({
    List<Map<String, dynamic>>? joinRequests,
    String? currentCode,
  }) {
    return InvitationState(
      joinRequests: joinRequests ?? this.joinRequests,
      currentCode: currentCode ?? this.currentCode,
    );
  }
}

@riverpod
class InvitationNotifier extends _$InvitationNotifier {
  @override
  Stream<InvitationState> build() {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Stream.value(InvitationState(joinRequests: []));
    }

    return invitationService.getJoinRequestsStream(userId).map((joinRequests) {
      return InvitationState(joinRequests: joinRequests);
    });
  }

  Future<void> joinOrgWithCode(String code) async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    final apprenticeId = ref.watch(authProvider).value!.user!.uid;

    Invitation? invitation = await invitationService.getInvitation(code);

    if (invitation == null) {
      throw Exception('Invalid code');
    }

    if (invitation.joinRequests.any((request) =>
        request['apprenticeId'] == apprenticeId &&
        request['status'] == 'pending')) {
      throw Exception('You already have a pending request');
    }

    await invitationService.createJoinRequest(code, apprenticeId);
  }

  Future<void> cancelJoinRequest(String code) async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    final apprenticeId = ref.watch(authProvider).value!.user!.uid;

    await invitationService.cancelJoinRequest(code, apprenticeId);
  }

  Future<void> updateRequestStatus(
      String code, String apprenticeId, String status) async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    await invitationService.updateJoinRequestStatus(code, apprenticeId, status);
  }

  Future<void> createNewInvitation(String mentorId, String orgId) async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    await invitationService.createInvitation(mentorId, orgId);
  }

  Future<String?> getCurrentCode() async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    final userId = ref.watch(authProvider).value!.user!.uid;
    return invitationService.getCurrentCode(userId);
  }
}
