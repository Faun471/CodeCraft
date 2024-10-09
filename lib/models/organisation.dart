import 'package:cloud_firestore/cloud_firestore.dart';

class Organization {
  final String id;
  final String orgName;
  final String orgDescription;
  final String createdAt;
  final String mentorId;
  final String code;
  final List<String> apprentices;

  Organization(
    this.id,
    this.orgName,
    this.orgDescription,
    this.createdAt,
    this.mentorId,
    this.code,
    this.apprentices,
  );

  Organization.fromMap(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        orgName = data['name'] ?? '',
        orgDescription = data['description'] ?? '',
        createdAt = (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        mentorId = data['mentorId'] ?? '',
        code = data['code'] ?? '',
        apprentices = List<String>.from(data['apprentices'] ?? []);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orgName': orgName,
      'orgDescription': orgDescription,
      'createdAt': createdAt,
      'mentorId': mentorId,
      'code': code,
      'apprentices': apprentices,
    };
  }
}
