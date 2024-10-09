import 'package:codecraft/services/debugging_challenge_service.dart';
import 'package:codecraft/models/debugging_challenge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'debugging_challenge_provider.g.dart';

enum ChallengeStage { findingFaultyLine, editingLine }

class DebuggingChallengeState {
  final DebuggingChallenge challenge;
  final int attemptsLeft;
  final bool isCompleted;
  final int? selectedLine;
  final String? proposedFix;
  final ChallengeStage currentStage;
  final String currentOutput;

  DebuggingChallengeState({
    required this.challenge,
    required this.attemptsLeft,
    this.isCompleted = false,
    this.selectedLine,
    this.proposedFix,
    this.currentStage = ChallengeStage.findingFaultyLine,
    this.currentOutput = '',
  });

  DebuggingChallengeState copyWith({
    DebuggingChallenge? challenge,
    int? attemptsLeft,
    bool? isCompleted,
    int? selectedLine,
    String? proposedFix,
    ChallengeStage? currentStage,
    String? currentOutput,
  }) {
    return DebuggingChallengeState(
      challenge: challenge ?? this.challenge,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      isCompleted: isCompleted ?? this.isCompleted,
      selectedLine: selectedLine ?? this.selectedLine,
      proposedFix: proposedFix ?? this.proposedFix,
      currentStage: currentStage ?? this.currentStage,
      currentOutput: currentOutput ?? this.currentOutput,
    );
  }
}

@riverpod
class DebuggingChallengeNotifier extends _$DebuggingChallengeNotifier {
  final DebuggingChallengeService _service = DebuggingChallengeService();

  @override
  Future<DebuggingChallengeState> build(
      String organizationId, String challengeId) async {
    final challenge =
        await _service.getDebuggingChallenge(organizationId, challengeId);
    return DebuggingChallengeState(
      challenge: challenge,
      attemptsLeft: challenge.attemptsLeft,
    );
  }

  Future<bool> selectLine(int line) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (currentState.currentStage == ChallengeStage.findingFaultyLine) {
        if (line == currentState.challenge.correctLine) {
          return currentState.copyWith(
            selectedLine: line,
            currentStage: ChallengeStage.editingLine,
          );
        } else {
          return currentState.copyWith(
            attemptsLeft: currentState.attemptsLeft - 1,
          );
        }
      }
      return currentState;
    });

    state = result;
    return result.value?.selectedLine == line;
  }

  void updateProposedFix(String fix) {
    state = AsyncValue.data(state.value!.copyWith(proposedFix: fix));
  }

  Future<void> proposeFix() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;

      String newOutput = await _executeCode(currentState.proposedFix ?? '');

      return currentState.copyWith(currentOutput: newOutput);
    });
  }

  Future<bool> submitFix() async {
    state = const AsyncValue.loading();

    await _executeCode(state.value!.proposedFix ?? '');

    final result = await AsyncValue.guard(() async {
      final currentState = state.value!;

      if (currentState.currentOutput == currentState.challenge.expectedOutput) {
        final newState = currentState.copyWith(isCompleted: true);
        state = AsyncValue.data(newState);
        await markChallengeAsCompleted(currentState.challenge.id);
        reset();
        return true;
      } else {
        final newState =
            currentState.copyWith(attemptsLeft: currentState.attemptsLeft - 1);
        state = AsyncValue.data(newState);
        return false;
      }
    });
    return result.value ?? false;
  }

  Future<void> markChallengeAsCompleted(String challengeId) async {
    await _service.markDebuggingChallengeAsCompleted(challengeId);
  }

  void reset() {
    state = const AsyncValue.loading();
    state = AsyncValue.data(state.value!.copyWith(
      selectedLine: null,
      proposedFix: null,
      currentStage: ChallengeStage.findingFaultyLine,
      currentOutput: '',
    ));
  }

  Future<String> _executeCode(String script) async {
    final url = Uri.parse(
        'https://us-central1-code-craft-bb5b1.cloudfunctions.net/executeSimpleCode');

    final headers = {
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "script": script,
      "language": 'java',
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      return responseJson['output'] ?? '';
    } else {
      return 'Error: ${response.statusCode}, ${response.body}';
    }
  }
}
