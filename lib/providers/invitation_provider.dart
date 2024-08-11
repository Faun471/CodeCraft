import 'package:codecraft/models/invitation.dart';
import 'package:codecraft/services/auth/auth_provider.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invitation_provider.g.dart';

class InvitationState {
  final List<Map<String, dynamic>> joinRequests;

  InvitationState({required this.joinRequests});

  InvitationState copyWith({List<Map<String, dynamic>>? joinRequests}) {
    return InvitationState(joinRequests: joinRequests ?? this.joinRequests);
  }
}

@riverpod
class InvitationNotifier extends _$InvitationNotifier {
  @override
  FutureOr<InvitationState> build() async {
    return InvitationState(joinRequests: await _fetchJoinRequests());
  }

  Future<void> joinOrgWithCode(String code) async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);

    String apprenticeId = ref.watch(authProvider).auth.currentUser!.uid;
    Invitation? invitation = await invitationService.getInvitation(code);

    if (invitation == null) {
      throw Exception('Invalid code');
    }

    if (await invitationService.hasJoinRequest(
        apprenticeId, invitation.orgId)) {
      throw Exception('You already have a pending request');
    }

    await invitationService.createJoinRequest(code, apprenticeId);
  }

  Future<List<Map<String, dynamic>>> _fetchJoinRequests() async {
    List<Map<String, dynamic>> requests = [];

    final invitationService = ref.watch(invitationServiceProvider.notifier);
    String mentorId = ref.watch(authProvider).auth.currentUser!.uid;
    requests = await invitationService.getJoinRequests(mentorId);

    return requests;
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    await invitationService.updateJoinRequestStatus(requestId, status);
    _fetchJoinRequests();
  }

  Future<void> createNewInvitation(String mentorId, String orgId) async {
    final invitationService = ref.watch(invitationServiceProvider.notifier);
    await invitationService.createInvitation(mentorId, orgId);
    _fetchJoinRequests();
  }
}
