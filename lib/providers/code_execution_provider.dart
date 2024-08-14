import 'dart:convert';
import 'package:codecraft/models/challenge.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodeExecutionState {
  final String output;

  CodeExecutionState({required this.output});

  CodeExecutionState copyWith({String? output}) {
    return CodeExecutionState(
      output: output ?? this.output,
    );
  }
}

class CodeExecutionNotifier extends StateNotifier<CodeExecutionState> {
  CodeExecutionNotifier() : super(CodeExecutionState(output: ''));

  Future<void> executeCode(String script, List<UnitTest> unitTests,
      String className, String language, String methodName) async {
    final url = Uri.parse('https://api.jdoodle.com/v1/execute');

    final headers = {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
      "Access-Control-Allow-Headers":
          "Origin, Content-Type, Accept, Authorization, X-Request-With",
    };

    final fullScript =
        _generateFullScript(script, unitTests, className, language, methodName);

    final payload = {
      "clientId": "3e01cb295a6d6dfef0c02c9b17e55845",
      "clientSecret":
          "5c687197c742b0c669fb31a43ac4fe7abe17661de152b7fd8401397a091c9e67",
      "script": fullScript,
      "stdin": "",
      "language": language == 'java' ? "java" : "python3",
      "versionIndex": language == 'java'
          ? "5"
          : "3", // Version index for Python is 3, adjust if needed
      "compileOnly": false,
    };

    final response = await http
        .post(url, headers: headers, body: jsonEncode(payload))
        .catchError((error) {
      state = state.copyWith(output: 'Error: $error');
      return http.Response('', 500, reasonPhrase: 'Error: $error');
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      state = state.copyWith(output: responseJson['output'] ?? '');
    } else {
      state = state.copyWith(
          output: 'Error: ${response.statusCode}, ${response.body}');
    }
  }

  String _expectedOutputToString(
      ExpectedOutput expectedOutput, String language) {
    if (language == 'java') {
      switch (expectedOutput.type) {
        case 'String':
          return '"${expectedOutput.value}"';
        case 'Char':
          return "'${expectedOutput.value}'";
        case 'Boolean':
          return expectedOutput.value.toLowerCase();
        case 'Integer':
          return expectedOutput.value;
        default:
          return expectedOutput.value;
      }
    } else if (language == 'python') {
      return expectedOutput.value;
    }
    return expectedOutput.value;
  }

  String _generateFullScript(String userScript, List<UnitTest> unitTests,
      String className, String language, String methodName) {
    if (language == 'java') {
      final buffer = StringBuffer();

      buffer.writeln(userScript); // User's code
      buffer.writeln('public class Main {');
      buffer.writeln('  public static void main(String[] args) {');
      buffer.writeln('    $className instance = new $className();');

      for (int i = 0; i < unitTests.length; i++) {
        UnitTest test = unitTests[i];
        bool isString = test.expectedOutput.type == 'String';
        String comparison = isString
            ? 'instance.$methodName(${test.input}).equals(${_expectedOutputToString(test.expectedOutput, language)})'
            : 'instance.$methodName(${test.input}) == ${_expectedOutputToString(test.expectedOutput, language)}';
        buffer.writeln('    boolean result${i + 1} = $comparison;');
        buffer.writeln(
            '    System.out.println("TEST_${i + 1}: " + result${i + 1});');
        buffer.writeln(
            '    System.out.println("Output: ${_expectedOutputToString(test.expectedOutput, language).replaceAll("\"", "\\\"")} Expected Output: ${test.expectedOutput.value.replaceAll("\"", "\\\"")}");');
      }

      buffer.writeln('  }');
      buffer.writeln('}');

      return buffer.toString();
    } else if (language == 'python') {
      final buffer = StringBuffer();

      buffer.writeln(userScript); // User's code

      buffer.writeln('if __name__ == "__main__":');
      buffer.writeln('    instance = $className()');

      for (int i = 0; i < unitTests.length; i++) {
        UnitTest test = unitTests[i];
        buffer.writeln(
            '    result${i + 1} = instance.$methodName(${test.input}) == ${_expectedOutputToString(test.expectedOutput, language)}');
        buffer.writeln(
            '    print("TEST_${i + 1}: " + str(result${i + 1}).lower())');
      }

      return buffer.toString();
    }
    return userScript;
  }

  Future<bool> allTestsPassed(String script, List<UnitTest> unitTests,
      String className, String language, String methodName) async {
    await executeCode(script, unitTests, className, language, methodName);

    for (int i = 0; i < unitTests.length; i++) {
      if (!state.output.contains('TEST_${i + 1}: true')) {
        return false;
      }
    }

    return true;
  }
}

final codeExecutionProvider =
    StateNotifierProvider<CodeExecutionNotifier, CodeExecutionState>((ref) {
  return CodeExecutionNotifier();
});
