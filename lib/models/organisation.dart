import 'package:cloud_firestore/cloud_firestore.dart';
class Organization {
  final String id;
  final String orgName;
  final String orgDescription;
  final String createdAt;
  final String mentorId;
  final String code;
  final String plan;
  final int maxApprentices;
  final List<String> apprentices;
  final String imageUrl;

  Organization(
    this.id,
    this.orgName,
    this.orgDescription,
    this.createdAt,
    this.mentorId,
    this.code,
    this.plan,
    this.maxApprentices,
    this.apprentices,
    this.imageUrl,
  );

  Organization.fromMap(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        orgName = data['orgName'] ?? '',
        orgDescription = data['orgDescription'] ?? '',
        createdAt = (data['createdAt'] is Timestamp)
            ? (data['createdAt'] as Timestamp).toDate().toString()
            : data['createdAt'].toString(),
        mentorId = data['mentorId'] ?? '',
        code = data['code'] ?? '',
        plan = data['plan'] ?? '',
        maxApprentices = data['maxApprentices'] ?? 0,
        apprentices = List<String>.from(data['apprentices'] ?? []),
        imageUrl = data['imageUrl'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orgName': orgName,
      'orgDescription': orgDescription,
      'createdAt': createdAt,
      'mentorId': mentorId,
      'code': code,
      'plan': plan,
      'maxApprentices': maxApprentices,
      'apprentices': apprentices,
      'imageUrl': imageUrl,
    };
  }

  Organization copyWith({
    String? id,
    String? orgName,
    String? orgDescription,
    String? createdAt,
    String? mentorId,
    String? code,
    String? plan,
    int? maxApprentices,
    List<String>? apprentices,
    String? imageUrl,
  }) {
    return Organization(
      id ?? this.id,
      orgName ?? this.orgName,
      orgDescription ?? this.orgDescription,
      createdAt ?? this.createdAt,
      mentorId ?? this.mentorId,
      code ?? this.code,
      plan ?? this.plan,
      maxApprentices ?? this.maxApprentices,
      apprentices ?? this.apprentices,
      imageUrl ?? this.imageUrl,
    );
  }
}
