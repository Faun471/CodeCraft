import 'package:codecraft/main.dart';
import 'package:codecraft/providers/debugging_challenge_provider.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_wrapper.dart';
import 'package:codecraft/widgets/screentypes/split_screen.dart';
import 'package:codecraft/widgets/viewers/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DebuggingChallengeScreen extends ConsumerWidget {
  final String organizationId;
  final String challengeId;

  const DebuggingChallengeScreen({
    super.key,
    required this.organizationId,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeState = ref.watch(debuggingChallengeNotifierProvider(
      organizationId,
      challengeId,
    ));

    return challengeState.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Debug Challenge',
              style: GoogleFonts.firaCode().copyWith(
                color: ThemeUtils.getTextColor(Theme.of(context).primaryColor),
              ),
            ),
          ),
          body: DraggableSplitScreen(
            leftWidget: _buildLeftPanel(context, ref, state),
            rightWidget: _buildRightPanel(context, ref, state),
          ),
        );
      },
    );
  }

  Widget _buildLeftPanel(
      BuildContext context, WidgetRef ref, DebuggingChallengeState state) {
    return DraggableSplitScreen(
      isVertical: true,
      leftWidget: _buildInstructionsCard(context, state),
      rightWidget: _buildOutputCard(context, ref, state),
    );
  }

  Widget _buildRightPanel(
      BuildContext context, WidgetRef ref, DebuggingChallengeState state) {
    return Stack(
      children: [
        _buildCodeEditorCard(context, ref, state),
        if (state.currentStage == ChallengeStage.editingLine)
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildActionButtons(context, ref, state),
          ),
      ],
    );
  }

  Widget _buildInstructionsCard(
      BuildContext context, DebuggingChallengeState state) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructions',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Expanded(
              child: MarkdownViewer(
                markdownData: state.challenge.instructions,
                displayToc: false,
              ),
            ),
            const SizedBox(height: 8),
            _buildLivesIndicator(state.attemptsLeft),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard(
      BuildContext context, WidgetRef ref, DebuggingChallengeState state) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Output', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: CodeWrapperWidget(
                  state.currentOutput.isEmpty
                      ? 'No output'
                      : state.currentOutput,
                  'txt',
                  theme: SyntaxTheme.dracula,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeEditorCard(
      BuildContext context, WidgetRef ref, DebuggingChallengeState state) {
    String stage = state.currentStage == ChallengeStage.findingFaultyLine
        ? "Click the line of code that we need to debug."
        : "Edit the line of code to fix the bug!";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              stage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: CodeWrapperWidget(
                state.challenge.initialCode,
                'java',
                theme: SyntaxTheme.dracula,
                isCopiable: false,
                editingLine: state.selectedLine,
                onLineEdited: (lineNumber, newContent) async {
                  if (state.currentStage == ChallengeStage.editingLine &&
                      lineNumber == state.selectedLine) {
                    ref
                        .read(debuggingChallengeNotifierProvider(
                          organizationId,
                          challengeId,
                        ).notifier)
                        .updateProposedFix(
                          getUpdatedCode(
                            state.challenge.initialCode,
                            lineNumber,
                            newContent,
                          ),
                        );
                  }
                },
                onLineClicked: (lineNumber) {
                  if (state.currentStage == ChallengeStage.findingFaultyLine) {
                    _handleLineSelection(context, ref, state, lineNumber);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getUpdatedCode(String code, int lineNumber, String newContent) {
    final lines = code.split('\n');
    lines[lineNumber - 1] = newContent;
    return lines.join('\n');
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, DebuggingChallengeState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => _handleProposeFix(context, ref),
          child: Text('Propose Fix', style: GoogleFonts.firaCode()),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _handleSubmit(context, ref, state),
          child: Text('Submit Fix', style: GoogleFonts.firaCode()),
        ),
      ],
    );
  }

  Widget _buildLivesIndicator(int attemptsLeft) {
    return Row(
      children: [
        Text('Lives: ', style: GoogleFonts.firaCode(fontSize: 18)),
        for (int i = 0; i < attemptsLeft; i++)
          const Icon(Icons.favorite, color: Colors.red),
      ],
    );
  }

  void _handleLineSelection(BuildContext context, WidgetRef ref,
      DebuggingChallengeState state, int lineNumber) async {
    final result = await ref
        .read(debuggingChallengeNotifierProvider(
          organizationId,
          challengeId,
        ).notifier)
        .selectLine(lineNumber);

    if (!context.mounted) return;

    if (state.attemptsLeft <= 1) {
      _handleGameOver(context);
      return;
    }

    if (result) {
      Utils.displayDialog(
        context: context,
        title: 'Correct!',
        content: 'You\'ve found the faulty line. Now edit it to fix the bug.',
        lottieAsset: 'assets/anim/congrats.json',
      );
    } else {
      Utils.displayDialog(
        context: context,
        title: 'Whoops!',
        content: 'That\'s not the faulty line. Try again!',
        lottieAsset: 'assets/anim/failed.json',
      );
    }
  }

  void _handleProposeFix(BuildContext context, WidgetRef ref) async {
    await ref
        .read(debuggingChallengeNotifierProvider(
          organizationId,
          challengeId,
        ).notifier)
        .proposeFix();
  }

  void _handleSubmit(BuildContext context, WidgetRef ref,
      DebuggingChallengeState state) async {
    final result = await ref
        .read(debuggingChallengeNotifierProvider(
          organizationId,
          challengeId,
        ).notifier)
        .submitFix();

    if (!context.mounted) return;

    if (result) {
      Utils.displayDialog(
        context: context,
        title: 'Congratulations!',
        content: 'You\'ve successfully fixed the bug!',
        lottieAsset: 'assets/anim/congrats.json',
        onDismiss: () => navigatorKey.currentState!.pop(),
      );
    } else {
      if (state.attemptsLeft <= 1) {
        _handleGameOver(context);
        return;
      }

      Utils.displayDialog(
        context: context,
        title: 'Whoops!',
        content: 'Your fix didn\'t work. Try again!',
        lottieAsset: 'assets/anim/failed.json',
      );
    }
  }

  void _handleGameOver(BuildContext context) {
    Utils.displayDialog(
      context: context,
      title: 'Game Over!',
      content: 'You\'ve run out of lives. Better luck next time!',
      lottieAsset: 'assets/anim/failed.json',
      onDismiss: () => navigatorKey.currentState!.pop(),
    );
  }
}
