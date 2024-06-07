class Challenge {
  String id;
  String instructions;
  String? sampleCode;
  String className;
  String methodName;
  String duration;
  List<UnitTest> unitTests;

  Challenge({
    required this.id,
    required this.instructions,
    this.sampleCode,
    required this.className,
    required this.methodName,
    required this.duration,
    required this.unitTests,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructions': instructions,
      'sampleCode': sampleCode,
      'className': className,
      'duration': duration,
      'unitTests': unitTests.map((e) => e.toJson()).toList(),
    };
  }
}

class UnitTest {
  String input;
  ExpectedOutput expectedOutput;

  UnitTest({
    required this.input,
    required this.expectedOutput,
  });

  factory UnitTest.fromJson(Map<String, dynamic> json) {
    return UnitTest(
      input: json['input'] ?? '',
      expectedOutput: ExpectedOutput.fromJson(
          json['expectedOutput'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'expectedOutput': expectedOutput.toJson(),
    };
  }
}

class ExpectedOutput {
  String value;
  String type;

  ExpectedOutput({
    required this.value,
    required this.type,
  });

  factory ExpectedOutput.fromJson(Map<String, dynamic> json) {
    return ExpectedOutput(
      value: json['value'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type,
    };
  }
}
