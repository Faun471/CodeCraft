import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/providers/quiz_provider.dart';
import 'package:codecraft/screens/apprentice/coding_quizzes/completed_quiz_screen.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/viewers/quiz_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class QuizScreen extends ConsumerWidget {
  final String quizId;
  final String? orgId;

  const QuizScreen({super.key, required this.quizId, this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserNotifierProvider);
    final theme = Theme.of(context);
    Quiz? quiz;

    return FutureBuilder(
      future:
          QuizService().getQuizFromId(quizId, orgId ?? appUser.value!.orgId!),
      builder: (context2, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 200,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          quiz = snapshot.data as Quiz;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => _onWillPop(context, ref, quiz),
              ),
              centerTitle: true,
              title: Text(
                quiz!.title,
                style: theme.textTheme.headlineMedium!.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) return;
                await _onWillPop(context, ref, quiz);
              },
              child: QuizViewer(
                quiz: quiz!,
                onQuizFinished: (quiz) async {
                  final result =
                      await QuizService().saveQuizResultsWithAnswers(quiz);

                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizResultsScreen(
                        quiz: quiz,
                        quizResult: result,
                        showSolutions: true,
                        canRetake: true,
                      ),
                    ),
                  );

                  final appUserNotifier =
                      ref.watch(appUserNotifierProvider.notifier);
                  await appUserNotifier.addExperience(
                    quiz.experienceToEarn,
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  int getQuizScore(Quiz quiz) {
    int score = 0;
    for (final question in quiz.questions) {
      if (question.userAnswer == null || question.userAnswer == '') {
        continue;
      }

      if (question.userAnswer == question.correctAnswer) {
        score++;
      }
    }
    return score;
  }

  Future<void> _onWillPop(
      BuildContext context, WidgetRef ref, Quiz? quiz) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Utils.displayDialog(
          context: context,
          title: 'Exit',
          content: 'Are you sure you want to exit? Your progress will be lost.',
          buttonText: 'Back to quiz.',
          onPressed: () => Navigator.pop(context),
          lottieAsset: 'assets/anim/question.json',
          actions: [
            Builder(
                builder: (dialogContext) => IconsButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      text: 'Back to quiz.',
                      color: const Color.fromARGB(255, 17, 172, 77),
                      iconData: Icons.cancel_outlined,
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 16),
                      iconColor: Colors.white,
                    )),
            Builder(
              builder: (dialogContext) => IconsButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);

                  if (quiz != null) {
                    ref.read(quizProvider(quiz).notifier).resetQuiz();
                  }
                },
                text: 'Quit.',
                iconData: Icons.check_circle,
                iconColor: Colors.white,
                color: Colors.red,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
