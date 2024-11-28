import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/providers/quiz_provider.dart';

class QuizViewer extends ConsumerWidget {
  final Quiz quiz;
  final Function(Quiz) onQuizFinished;

  const QuizViewer({
    super.key,
    required this.quiz,
    required this.onQuizFinished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider(quiz));
    final quizNotifier = ref.read(quizProvider(quiz).notifier);

    if (quizState.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onQuizFinished(quizState.quiz);
      });
    }

    return Container(
      color: ThemeUtils.getDarkColor(Theme.of(context).primaryColor),
      child: Center(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 375),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProgressBar(quizState),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildQuestionCard(
                          quizState,
                          quizNotifier,
                          context,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildNextButton(quizState, quizNotifier),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(QuizState state) {
    return LinearProgressIndicator(
      value: (state.currentQuestionIndex + 1) / state.quiz.questions.length,
      backgroundColor: Colors.white.withOpacity(0.3),
      color: Colors.greenAccent,
      minHeight: 5,
    );
  }

  Widget _buildQuestionCard(
      QuizState state, QuizNotifier notifier, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            constraints: const BoxConstraints(maxWidth: 100),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.alarm,
                  color: ThemeUtils.getTextColorForBackground(
                      Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 5),
                Text(
                  "${(state.remainingTimer ~/ 60).toString().padLeft(2, '0')}:${(state.remainingTimer % 60).toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: ThemeUtils.getTextColorForBackground(
                        Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          AutoSizeText(
            state.quiz.questions[state.currentQuestionIndex].questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          if (state.canAnswer)
            ..._buildAnswerButtons(state, notifier, context)
          else
            _buildFeedbackContent(state),
          const SizedBox(height: 20),
          _buildAttemptCounter(state),
        ],
      ),
    );
  }

  Widget _buildAttemptCounter(QuizState state) {
    return Center(
      child: Text(
        'Attempts left: ${state.quiz.questions[state.currentQuestionIndex].maxAttempts - state.attemptsPerQuestion[state.currentQuestionIndex]}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  List<Widget> _buildAnswerButtons(
      QuizState state, QuizNotifier notifier, BuildContext context) {
    return state.quiz.questions[state.currentQuestionIndex].answerOptions
        .map((answer) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: ListTile(
            title: AutoSizeText(
              answer,
              maxFontSize: 12,
              minFontSize: 10,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            onTap: () => notifier.checkAnswer(answer),
          ),
        ),
      ).animate(
        effects: [
          FadeEffect(begin: 0, end: 1, duration: 300.ms),
          SlideEffect(
            begin: const Offset(-0.1, 0),
            end: Offset.zero,
            duration: 300.ms,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildFeedbackContent(QuizState state) {
    bool isCorrect = state.quiz.questions[state.currentQuestionIndex]
        .checkAnswer(state.userAnswer);
    String feedbackText = state.userAnswer == 'Time\'s Up!'
        ? 'Time\'s Up!'
        : isCorrect
            ? 'Correct!'
            : 'Incorrect';

    return Center(
      child: Column(
        children: [
          Lottie.asset(
            state.userAnswer == 'Time\'s Up!'
                ? 'assets/anim/timeout.json'
                : isCorrect
                    ? 'assets/anim/correct.json'
                    : 'assets/anim/incorrect.json',
            height: 200,
            width: 200,
            fit: BoxFit.contain,
            repeat: false,
          ),
          const SizedBox(height: 20),
          Text(
            feedbackText,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (!isCorrect &&
              state.attemptsPerQuestion[state.currentQuestionIndex] <
                  state.quiz.questions[state.currentQuestionIndex].maxAttempts)
            Text(
              'Attempts left: ${state.quiz.questions[state.currentQuestionIndex].maxAttempts - state.attemptsPerQuestion[state.currentQuestionIndex]}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
        ],
      ).animate(
        effects: [
          FadeEffect(begin: 0, end: 1, duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildNextButton(QuizState state, QuizNotifier notifier) {
    return ElevatedButton(
      onPressed: !state.canAnswer
          ? () {
              if (state.userAnswer != 'Time\'s Up!' &&
                  !state.quiz.questions[state.currentQuestionIndex]
                      .checkAnswer(state.userAnswer) &&
                  state.attemptsPerQuestion[state.currentQuestionIndex] <
                      state.quiz.questions[state.currentQuestionIndex]
                          .maxAttempts) {
                notifier.repeatQuestion();
              } else {
                notifier.nextQuestion();
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7EF17E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        "Next",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
