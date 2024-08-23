import 'package:codecraft/providers/debugging_challenge_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (state) {
        return Column(
          children: [
            Text('Attempts left: ${state.attemptsLeft}'),
            Text('Challenge: ${state.challenge.instructions}'),
            Text('Code: ${state.challenge.initialCode}'),
            ElevatedButton(
              onPressed: () => ref
                  .read(debuggingChallengeNotifierProvider(
                          organizationId, challengeId)
                      .notifier)
                  .selectLine('1'),
              child: const Text('Select Line 1'),
            ),
            // ... other UI elements
          ],
        );
      },
    );
  }
}
