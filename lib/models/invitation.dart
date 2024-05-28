class Invitation {
  final String code;
  final String mentorId;
  final String orgId;

  Invitation({
    required this.code,
    required this.mentorId,
    required this.orgId,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'mentorId': mentorId,
      'orgId': orgId,
    };
  }

  static Invitation fromMap(Map<String, dynamic> map) {
    return Invitation(
      code: map['code'],
      mentorId: map['mentorId'],
      orgId: map['orgId'],
    );
  }
}
