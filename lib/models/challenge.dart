class Challenge {
  final String id;
  final String instructions;
  final String sampleCode;
  final String className;
  final List<UnitTest> unitTests;

  Challenge({
    required this.id,
    required this.instructions,
    required this.sampleCode,
    required this.className,
    required this.unitTests,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      instructions: json['instructions'],
      sampleCode: json['sampleCode'],
      className: json['className'],
      unitTests: (json['unitTests'] as List)
          .map((unitTest) => UnitTest.fromJson(unitTest))
          .toList(),
    );
  }
}

class UnitTest {
  final String input;
  final ExpectedOutput expectedOutput;
  final String methodName;

  UnitTest({
    required this.input,
    required this.expectedOutput,
    required this.methodName,
  });

  factory UnitTest.fromJson(Map<String, dynamic> json) {
    return UnitTest(
      input: json['input'],
      expectedOutput: ExpectedOutput(
        value: json['expectedOutput']['value'],
        type: json['expectedOutput']['type'],
      ),
      methodName: json['methodName'],
    );
  }
}

class ExpectedOutput {
  final String value;
  final String type;

  ExpectedOutput({
    required this.value,
    required this.type,
  });
}
