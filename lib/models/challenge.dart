import 'package:json/json.dart';

@JsonCodable()
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
}

@JsonCodable()
class UnitTest {
  String input;
  ExpectedOutput expectedOutput;
  String methodName;

  UnitTest({
    required this.input,
    required this.expectedOutput,
    required this.methodName,
  });
}

@JsonCodable()
class ExpectedOutput {
  String value;
  String type;

  ExpectedOutput({
    required this.value,
    required this.type,
  });
}
