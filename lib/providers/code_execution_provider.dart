import 'dart:convert';
import 'package:codecraft/models/challenge.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class CodeExecutionProvider with ChangeNotifier {
  String _output = '';
  String get output => _output;

  Future<void> executeCode(
      String script, List<UnitTest> unitTests, String className) async {
    final url = Uri.parse('https://api.jdoodle.com/v1/execute');

    final headers = {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    };

    final fullScript = _generateFullScript(script, unitTests, className);

    final payload = {
      "clientId": "3e01cb295a6d6dfef0c02c9b17e55845",
      "clientSecret":
          "5c687197c742b0c669fb31a43ac4fe7abe17661de152b7fd8401397a091c9e67",
      "script": fullScript,
      "stdin": "",
      "language": "java",
      "versionIndex": "5",
      "compileOnly": false,
    };

    final response = await http
        .post(url, headers: headers, body: jsonEncode(payload))
        .catchError((error) {
      _output = 'Error: $error';
      print('Error: $error');
      notifyListeners();
      return Response('', 500, reasonPhrase: 'Error: $error');
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      _output = responseJson['output'] ?? '';
    } else {
      _output = 'Error: ${response.statusCode}, ${response.body}';
    }

    notifyListeners();
  }

  String _expectedOutputToString(ExpectedOutput expectedOutput) {
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
  }

  String _generateFullScript(
      String userScript, List<UnitTest> unitTests, String className) {
    final buffer = StringBuffer();

    buffer.writeln(userScript); // User's code
    buffer.writeln('public class Main {');
    buffer.writeln('  public static void main(String[] args) {');

    for (int i = 0; i < unitTests.length; i++) {
      UnitTest test = unitTests[i];
      buffer.writeln('    ${className} instance = new ${className}();');
      buffer.writeln(
          '    if (instance.${test.methodName}(${test.input}) == ${_expectedOutputToString(test.expectedOutput)}) {');
      buffer.writeln('      System.out.println("Test ${i + 1} passed");');
      buffer.writeln('    } else {');
      buffer.writeln('      System.out.println("Test ${i + 1} failed");');
      buffer.writeln('    }');
    }

    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  Future<bool> allTestsPassed(
      String script, List<UnitTest> unitTests, String className) async {
    await executeCode(script, unitTests, className);

    return !_output.contains('failed');
  }
}
