import 'dart:async';

import 'package:codecraft/models/unit_test.dart';
import 'package:codecraft/providers/code_execution_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/services/code_clash_service.dart';

class CodeClashState {
  final CodeClash codeClash;
  final List<CodeClashParticipant> participants;
  final String output;

  CodeClashState({
    required this.codeClash,
    required this.participants,
    this.output = '',
  });

  CodeClashState copyWith({
    CodeClash? codeClash,
    List<CodeClashParticipant>? participants,
    String? output,
  }) {
    return CodeClashState(
      codeClash: codeClash ?? this.codeClash,
      participants: participants ?? this.participants,
      output: output ?? this.output,
    );
  }
}

class CodeClashNotifier extends StateNotifier<CodeClashState> {
  final CodeClashService _codeClashService = CodeClashService();
  final Ref _ref;
  StreamSubscription? _submissionSubscription;

  CodeClashNotifier(this._ref, CodeClash initialCodeClash)
      : super(CodeClashState(
          codeClash: initialCodeClash,
          participants: [],
        ));

  void startListening(String codeClashId, String orgId) {
    _submissionSubscription = CodeClashService()
        .getSubmissionsStream(orgId, codeClashId)
        .listen((submissions) async {
      final participants = <CodeClashParticipant>[];

      for (final submission in submissions) {
        final CodeClashParticipant participant = await getParticipantById(
          submission.userId,
        );

        participants.add(participant);
      }

      state = state.copyWith(participants: participants);
    });
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  Future<CodeClashParticipant> getParticipantById(String userId) async {
    final userData = await _codeClashService.getParticipantById(userId);

    return userData;
  }

  void stopListening() {
    _submissionSubscription?.cancel();
  }

  Future<void> executeCode(
    String script,
    List<UnitTest> unitTests,
    String className,
    String language,
    String methodName,
  ) async {
    final codeExecutionNotifier = _ref.read(codeExecutionProvider.notifier);
    await codeExecutionNotifier.executeCode(
      script,
      unitTests,
      className,
      language,
      methodName,
    );
    state = state.copyWith(output: _ref.read(codeExecutionProvider).output);
  }

  Future<void> resetOutput() async {
    final codeExecutionNotifier = _ref.read(codeExecutionProvider.notifier);
    codeExecutionNotifier.resetOutput();

    state = state.copyWith(output: '');
    return;
  }

  Future<bool> isCorrectSolution(
    String script,
    List<UnitTest> unitTests,
    String className,
    String language,
    String methodName,
  ) async {
    final codeExecutionNotifier = _ref.read(codeExecutionProvider.notifier);
    return await codeExecutionNotifier.allTestsPassed(
      script,
      unitTests,
      className,
      language,
      methodName,
    );
  }

  Future<void> submitSolution(
      String userId, String solution, String organizationId) async {
    await _codeClashService.submitSolution(
      organizationId,
      state.codeClash.id,
      userId,
      solution,
    );
  }
}

final codeClashProvider =
    StateNotifierProvider<CodeClashNotifier, CodeClashState>((ref) {
  return CodeClashNotifier(ref, CodeClash.empty());
});
