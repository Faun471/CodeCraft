import 'package:cloud_firestore/cloud_firestore.dart';

class Submission {
  final String userId;
  final String solution;
  final String displayName;
  final String photoUrl;
  final DateTime submissionTime;
  final int score;

  Submission({
    required this.userId,
    required this.solution,
    required this.displayName,
    required this.photoUrl,
    required this.submissionTime,
    required this.score,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      userId: json['userId'] ?? '',
      solution: json['solution'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] == null || json['photoUrl'].isEmpty
          ? 'https://api.dicebear.com/9.x/thumbs/png?seed=${json['userId']}'
          : json['photoUrl'],
      submissionTime: json['submissionTime'] != null
          ? (json['submissionTime'] as Timestamp).toDate()
          : DateTime.now(),
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'solution': solution,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'submissionTime': Timestamp.fromDate(submissionTime),
      'score': score,
    };
  }

  Submission copyWith({
    String? userId,
    String? solution,
    String? displayName,
    String? photoUrl,
    DateTime? submissionTime,
    int? score,
  }) {
    return Submission(
      userId: userId ?? this.userId,
      solution: solution ?? this.solution,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      submissionTime: submissionTime ?? this.submissionTime,
      score: score ?? this.score,
    );
  }
}
