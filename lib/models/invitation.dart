import 'package:codecraft/services/challenge_service.dart';

class Invitation {
  final String code;
  final String mentorId;
  final String orgId;
  final List<Map<String, dynamic>> joinRequests;

  Invitation({
    required this.code,
    required this.mentorId,
    required this.orgId,
    required this.joinRequests,
  });

  factory Invitation.fromMap(Map<String, dynamic> map) {
    return Invitation(
      code: map['code'],
      mentorId: map['mentorId'],
      orgId: map['orgId'],
      joinRequests: List<Map<String, dynamic>>.from(map['joinRequests'] ?? [])
          .map((request) {
        if (request['timestamp'] is String) {
          (request['timestamp'] as String).toDateTime();
        }
        return request;
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'mentorId': mentorId,
      'orgId': orgId,
      'joinRequests': joinRequests.toList(),
    };
  }
}
