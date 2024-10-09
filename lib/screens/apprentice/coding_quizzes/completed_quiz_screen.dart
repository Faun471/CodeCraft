import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/screens/apprentice/coding_quizzes/coding_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class QuizResultsScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  final QuizResult quizResult;
  final bool? showSolutions;
  final bool? canRetake;
  final String? orgId;

  const QuizResultsScreen({
    super.key,
    required this.quiz,
    required this.quizResult,
    this.showSolutions,
    this.canRetake,
    this.orgId,
  });

  @override
  _QuizResultsScreenState createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correctAnswers = getCorrectAnswers(widget.quiz, widget.quizResult);
    final totalQuestions = widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onPrimary.computeLuminance() > 0.5
                ? theme.colorScheme.onPrimary
                : Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Result',
          style: TextStyle(
            color: theme.colorScheme.onPrimary.computeLuminance() > 0.5
                ? theme.colorScheme.onPrimary
                : Colors.white,
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 700,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Lottie.asset(
                  'assets/anim/trophy.json',
                  repeat: false,
                  animate: true,
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Test Result',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 75,
                            width: 75,
                            child: CircularProgressIndicator(
                              value: correctAnswers / totalQuestions,
                              strokeWidth: 8,
                              backgroundColor: theme.disabledColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Text(
                            '$correctAnswers/$totalQuestions',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Quiz Analysis',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAnalysisItem(
                            context,
                            correctAnswers,
                            'Correct',
                            Colors.green,
                          ),
                          _buildAnalysisItem(
                            context,
                            totalQuestions - correctAnswers,
                            'Incorrect',
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.canRetake ?? false)
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(
                                quizId: widget.quiz.id!,
                                orgId: widget.orgId,
                              ),
                            ),
                          );

                          if (result is QuizResult) {
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizResultsScreen(
                                  quiz: widget.quiz,
                                  quizResult: result,
                                  showSolutions: true,
                                  canRetake: true,
                                  orgId: widget.orgId,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                        child: Text(
                          'Retake Quiz',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SolutionScreen(
                              quiz: widget.quiz,
                              quizResult: widget.quizResult,
                              showSolutions: widget.showSolutions,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: Text(
                        (widget.showSolutions ?? true)
                            ? 'Show Answers'
                            : 'Show Solutions',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(
      BuildContext context, int value, String label, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Text(
            '$value',
            style: TextStyle(
              color: theme.colorScheme.onPrimary.computeLuminance() > 0.5
                  ? theme.colorScheme.onPrimary
                  : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  int getCorrectAnswers(Quiz quiz, QuizResult quizResult) {
    int correctAnswers = 0;
    for (final question in quiz.questions) {
      final userAnswer = quizResult.answers[question.questionText];
      if (userAnswer == question.correctAnswer) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }
}

class SolutionScreen extends ConsumerWidget {
  final Quiz quiz;
  final QuizResult quizResult;
  final bool? showSolutions;

  const SolutionScreen({
    super.key,
    required this.quiz,
    required this.quizResult,
    this.showSolutions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quizState = ref.watch(quizSolutionProvider(quiz));
    final quizNotifier = ref.read(quizSolutionProvider(quiz).notifier);

    final currentQuestion = quiz.questions[quizState.currentQuestionIndex];
    final userAnswer = quizResult.answers[currentQuestion.questionText];
    final isCorrect = userAnswer == currentQuestion.correctAnswer;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onPrimary.computeLuminance() > 0.5
                ? theme.colorScheme.onPrimary
                : Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Solution for ${quiz.title}',
          style: TextStyle(
            color: theme.colorScheme.onPrimary.computeLuminance() > 0.5
                ? theme.colorScheme.onPrimary
                : Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Question ${quizState.currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion.questionText,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your Answer: ${(userAnswer ?? 'Not answered') == 'Time\'s Up!' ? 'You ran out of time.' : userAnswer}',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (showSolutions ?? true)
                        Text(
                          'Correct Answer: ${currentQuestion.correctAnswer}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),

                      // number of attempts
                      Text(
                        'Attempts Left: ${quiz.questions[quizState.currentQuestionIndex].maxAttempts - quizResult.attempts[quizState.currentQuestionIndex]}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (isCorrect) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: LottieBuilder.asset(
                            'assets/anim/correct.json',
                            height: 100,
                            width: 100,
                            repeat: false,
                            animate: true,
                          ),
                        ),
                      ],
                      if (!isCorrect && userAnswer != 'Time\'s Up!') ...[
                        const SizedBox(height: 16),
                        Center(
                          child: LottieBuilder.asset(
                            'assets/anim/incorrect.json',
                            height: 100,
                            width: 100,
                            repeat: false,
                            animate: true,
                          ),
                        ),
                      ],
                      if (!isCorrect && userAnswer == 'Time\'s Up!') ...[
                        const SizedBox(height: 16),
                        Center(
                          child: LottieBuilder.asset(
                            'assets/anim/timeout.json',
                            height: 100,
                            width: 100,
                            repeat: true,
                            animate: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: quizNotifier.hasPreviousQuestion
                          ? quizNotifier.previousQuestion
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor:
                            theme.colorScheme.onPrimary.computeLuminance() > 0.5
                                ? theme.colorScheme.onPrimary
                                : Colors.white,
                      ),
                      child: const Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: quizNotifier.hasNextQuestion()
                          ? quizNotifier.nextQuestion
                          : () {
                              quizNotifier.reset();
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor:
                            theme.colorScheme.onPrimary.computeLuminance() > 0.5
                                ? theme.colorScheme.onPrimary
                                : Colors.white,
                      ),
                      child: Text(
                        quizNotifier.hasNextQuestion() ? 'Next' : 'Finish',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizSolutionState {
  final int currentQuestionIndex;
  final int totalQuestions;

  QuizSolutionState({
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  QuizSolutionState copyWith({
    int? currentQuestionIndex,
  }) {
    return QuizSolutionState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions,
    );
  }
}

class QuizSolutionNotifier extends StateNotifier<QuizSolutionState> {
  QuizSolutionNotifier(Quiz quiz)
      : super(QuizSolutionState(
          currentQuestionIndex: 0,
          totalQuestions: quiz.questions.length,
        ));

  void reset() {
    state = QuizSolutionState(
      currentQuestionIndex: 0,
      totalQuestions: state.totalQuestions,
    );
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.totalQuestions - 1) {
      state =
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state =
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  bool hasNextQuestion() {
    return state.currentQuestionIndex < state.totalQuestions - 1;
  }

  bool get hasPreviousQuestion => state.currentQuestionIndex > 0;
}

final quizSolutionProvider =
    StateNotifierProvider.family<QuizSolutionNotifier, QuizSolutionState, Quiz>(
        (ref, quiz) {
  return QuizSolutionNotifier(quiz);
});
