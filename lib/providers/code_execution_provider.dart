import 'dart:convert';
import 'package:codecraft/models/unit_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodeExecutionState {
  final String output;
  final bool isLoading;

  CodeExecutionState({required this.output, this.isLoading = false});

  CodeExecutionState copyWith({String? output, bool? isLoading}) {
    return CodeExecutionState(
      output: output ?? this.output,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CodeExecutionNotifier extends StateNotifier<CodeExecutionState> {
  CodeExecutionNotifier() : super(CodeExecutionState(output: ''));

  Future<void> executeCode(String script, List<UnitTest> unitTests,
      String className, String language, String methodName) async {
    state = state.copyWith(isLoading: true);

    final url = Uri.parse(
        'https://us-central1-code-craft-bb5b1.cloudfunctions.net/executeCode');

    final headers = {
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "script": script,
      "unitTests": unitTests,
      "className": className,
      "language": language,
      "methodName": methodName,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        state = state.copyWith(
          output: responseJson['output'] ?? '',
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          output: 'Error: ${response.statusCode}, ${response.body}',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        output: 'Error: $e',
        isLoading: false,
      );
    }
  }

  Future<bool> allTestsPassed(
    String script,
    List<UnitTest> unitTests,
    String className,
    String language,
    String methodName,
  ) async {
    // Execute the code
    await executeCode(script, unitTests, className, language, methodName);

    // Parse the output to check if all tests passed
    final lines = state.output.split('\n');
    bool allPassed = true;

    for (final line in lines) {
      if (line.contains(':')) {
        final result = line.split(':').last.trim().toLowerCase();
        if (result != 'true') {
          allPassed = false;
          break;
        }
      }
    }

    resetOutput();

    return allPassed;
  }

  void resetOutput() {
    state = state.copyWith(output: '', isLoading: false);
  }
}

final codeExecutionProvider =
    StateNotifierProvider<CodeExecutionNotifier, CodeExecutionState>((ref) {
  return CodeExecutionNotifier();
});
