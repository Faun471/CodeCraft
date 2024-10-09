import 'package:codecraft/models/unit_test.dart';

class Challenge {
  String id;
  String instructions;
  String? sampleCode;
  int? levelRequired;
  String className;
  String methodName;
  String duration;
  List<UnitTest> unitTests;
  int experienceToEarn;
  String? introAnimation;
  String? outroAnimation;

  Challenge({
    required this.id,
    required this.instructions,
    this.sampleCode,
    this.levelRequired,
    required this.className,
    required this.methodName,
    required this.duration,
    required this.unitTests,
    this.experienceToEarn = 0,
    this.introAnimation,
    this.outroAnimation,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      instructions: json['instructions'] ?? '',
      levelRequired: json['levelRequired'],
      sampleCode: json['sampleCode'],
      className: json['className'] ?? '',
      methodName: json['methodName'] ?? '',
      duration: json['duration'] ?? '',
      unitTests: (json['unitTests'] as List<dynamic>)
          .map((e) => UnitTest.fromJson(e as Map<String, dynamic>))
          .toList(),
      experienceToEarn: json['experienceToEarn'] ?? 0,
      introAnimation: json['introAnimation'],
      outroAnimation: json['outroAnimation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructions': instructions,
      'sampleCode': sampleCode,
      'levelRequired': levelRequired,
      'className': className,
      'methodName': methodName,
      'duration': duration,
      'unitTests': unitTests.map((e) => e.toJson()).toList(),
      'experienceToEarn': experienceToEarn,
      'introAnimation': introAnimation,
      'outroAnimation': outroAnimation,
    };
  }
}
