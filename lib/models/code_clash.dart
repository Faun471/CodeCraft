import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/unit_test.dart';

class CodeClash {
  final String id;
  final String title;
  final String description;
  final String instructions;
  final String? sampleCode;
  final String className;
  final String methodName;
  final int timeLimit; // in minutes
  final String status;
  final Timestamp? startTime; // Added startTime field
  final List<UnitTest> unitTests;
  final List<CodeClashParticipant> participants;

  CodeClash({
    required this.id,
    required this.title,
    required this.description,
    required this.instructions,
    this.sampleCode,
    required this.className,
    required this.methodName,
    required this.timeLimit,
    required this.status,
    required this.unitTests,
    this.startTime, // New field
    this.participants = const [],
  });

  factory CodeClash.empty() {
    return CodeClash(
      id: '',
      title: '',
      description: '',
      instructions: '',
      className: '',
      methodName: '',
      timeLimit: 0,
      status: '',
      unitTests: [],
    );
  }

  // Add startTime in factory and toJson methods
  factory CodeClash.fromJson(Map<String, dynamic> json) {
    return CodeClash(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      sampleCode: json['sampleCode'] ?? '',
      className: json['className'] ?? '',
      methodName: json['methodName'] ?? '',
      timeLimit: json['timeLimit'] ?? 0,
      status: json['status'] ?? '',
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp)
          : null, // New
      unitTests: (json['unitTests'] as List<dynamic>?)
              ?.map((e) => UnitTest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) =>
                  CodeClashParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructions': instructions,
      'sampleCode': sampleCode,
      'className': className,
      'methodName': methodName,
      'timeLimit': timeLimit,
      'status': status,
      'startTime': startTime, // Include startTime in toJson
      'unitTests': unitTests.map((e) => e.toJson()).toList(),
      'participants': participants.map((e) => e.toJson()).toList(),
    };
  }

  bool isUserInClash(String userId) {
    return participants.any((participant) => participant.id == userId);
  }
}

class CodeClashParticipant {
  final String id;
  final String displayName;
  final int score;
  final String? photoUrl;

  CodeClashParticipant({
    required this.id,
    required this.displayName,
    required this.score,
    this.photoUrl,
  });

  factory CodeClashParticipant.fromJson(Map<String, dynamic> json) {
    return CodeClashParticipant(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      score: json['score'] ?? 0,
      photoUrl: json['photoUrl'] == null || json['photoUrl'].isEmpty
          ? 'https://api.dicebear.com/9.x/thumbs/png?seed=${json['id']}'
          : json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'score': score,
      'photoUrl': photoUrl,
    };
  }

  CodeClashParticipant copyWith({
    String? id,
    String? displayName,
    int? score,
    String? photoUrl,
  }) {
    return CodeClashParticipant(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      score: score ?? this.score,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
