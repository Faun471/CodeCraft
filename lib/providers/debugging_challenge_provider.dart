import 'package:codecraft/services/debugging_challenge_service.dart';
import 'package:codecraft/models/debugging_challenge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debugging_challenge_provider.g.dart';

class DebuggingChallengeState {
  final DebuggingChallenge challenge;
  final int attemptsLeft;
  final bool isCompleted;
  final String? selectedLine;
  final String? proposedFix;

  DebuggingChallengeState({
    required this.challenge,
    required this.attemptsLeft,
    this.isCompleted = false,
    this.selectedLine,
    this.proposedFix,
  });

  DebuggingChallengeState copyWith({
    DebuggingChallenge? challenge,
    int? attemptsLeft,
    bool? isCompleted,
    String? selectedLine,
    String? proposedFix,
  }) {
    return DebuggingChallengeState(
      challenge: challenge ?? this.challenge,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      isCompleted: isCompleted ?? this.isCompleted,
      selectedLine: selectedLine ?? this.selectedLine,
      proposedFix: proposedFix ?? this.proposedFix,
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

  Future<void> selectLine(String line) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (line == currentState.challenge.correctLine.toString()) {
        return currentState.copyWith(selectedLine: line);
      } else {
        return currentState.copyWith(
            attemptsLeft: currentState.attemptsLeft - 1);
      }
    });
  }

  Future<void> proposeFix(String fix) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      return currentState.copyWith(proposedFix: fix);
    });
  }

  Future<bool> submitFix() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final currentState = state.value!;
      if (currentState.proposedFix == currentState.challenge.solution) {
        final newState = currentState.copyWith(isCompleted: true);
        state = AsyncValue.data(newState);
        // Call service to mark challenge as completed
        await markChallengeAsCompleted(currentState.challenge.id);
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

  Future<void> markChallengeAsCompleted(String challengeId) async {}
}
