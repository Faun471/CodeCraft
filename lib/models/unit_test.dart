import 'package:codecraft/models/expected_output.dart';
import 'package:codecraft/models/input.dart';

class UnitTest {
  final List<Input> input;
  final ExpectedOutput expectedOutput;

  UnitTest({required this.input, required this.expectedOutput});

  factory UnitTest.fromJson(Map<String, dynamic> json) {
    return UnitTest(
      input: (json['input'] as List<dynamic>)
          .map((e) => Input.fromJson(e as Map<String, dynamic>))
          .toList(),
      expectedOutput: ExpectedOutput.fromJson(
          json['expectedOutput'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input.map((e) => e.toJson()).toList(),
      'expectedOutput': expectedOutput.toJson(),
    };
  }
}
