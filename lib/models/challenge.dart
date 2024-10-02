import 'package:codecraft/models/unit_test.dart';

class Challenge {
  String id;
  String instructions;
  String? sampleCode;
  String className;
  String methodName;
  String duration;
  List<UnitTest> unitTests;
  int experienceToEarn;

  Challenge({
    required this.id,
    required this.instructions,
    this.sampleCode,
    required this.className,
    required this.methodName,
    required this.duration,
    required this.unitTests,
    this.experienceToEarn = 0,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      instructions: json['instructions'] ?? '',
      sampleCode: json['sampleCode'],
      className: json['className'] ?? '',
      methodName: json['methodName'] ?? '',
      duration: json['duration'] ?? '',
      unitTests: (json['unitTests'] as List<dynamic>)
          .map((e) => UnitTest.fromJson(e as Map<String, dynamic>))
          .toList(),
      experienceToEarn: json['experienceToEarn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructions': instructions,
      'sampleCode': sampleCode,
      'className': className,
      'methodName': methodName,
      'duration': duration,
      'unitTests': unitTests.map((e) => e.toJson()).toList(),
      'experienceToEarn': experienceToEarn,
    };
  }
}
