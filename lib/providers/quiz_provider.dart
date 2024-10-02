import 'package:codecraft/models/quiz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizState {
  final Quiz quiz;
  final int currentQuestionIndex;
  final int score;
  final bool canAnswer;
  final String userAnswer;
  final bool isFinished;
  final bool shouldAnimateLottie;
  final bool showContinuePrompt;
  final int remainingTimer;
  final bool hasCheckedAnswer;
  final List<int> attemptsPerQuestion;

  QuizState({
    required this.quiz,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.canAnswer = true,
    this.userAnswer = '',
    this.isFinished = false,
    this.shouldAnimateLottie = false,
    this.showContinuePrompt = false,
    this.remainingTimer = 0,
    this.hasCheckedAnswer = false,
    required this.attemptsPerQuestion,
  });

  QuizState copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    int? score,
    bool? canAnswer,
    String? userAnswer,
    bool? isFinished,
    bool? shouldAnimateLottie,
    bool? showContinuePrompt,
    int? remainingTimer,
    bool? hasCheckedAnswer,
    List<int>? attemptsPerQuestion,
  }) {
    return QuizState(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      canAnswer: canAnswer ?? this.canAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isFinished: isFinished ?? this.isFinished,
      shouldAnimateLottie: shouldAnimateLottie ?? this.shouldAnimateLottie,
      showContinuePrompt: showContinuePrompt ?? this.showContinuePrompt,
      remainingTimer: remainingTimer ?? this.remainingTimer,
      hasCheckedAnswer: hasCheckedAnswer ?? this.hasCheckedAnswer,
      attemptsPerQuestion: attemptsPerQuestion ?? this.attemptsPerQuestion,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(Quiz quiz)
      : super(QuizState(
          quiz: quiz,
          remainingTimer: quiz.questions[0].initialTimer!.toInt(),
          attemptsPerQuestion: List.filled(quiz.questions.length, 0),
        )) {
    _startQuestionTimer();
  }

  void checkAnswer(String answer) {
    final currentQuestion = state.quiz.questions[state.currentQuestionIndex];
    final isCorrect = currentQuestion.checkAnswer(answer);
    int remainingTime = state.remainingTimer;
    int currentAttempts = state.attemptsPerQuestion[state.currentQuestionIndex];

    if (!isCorrect) {
      currentAttempts++;
      remainingTime = (remainingTime - currentQuestion.penaltySeconds)
          .clamp(0, currentQuestion.initialTimer!);
    }

    // if attempts are exhausted, userAnswer should be set to their last answer
    if (currentAttempts >= currentQuestion.maxAttempts) {
      state = state.copyWith(
        canAnswer: false,
        userAnswer: answer,
        quiz: state.quiz
          ..questions[state.currentQuestionIndex].userAnswer = answer
          ..questions[state.currentQuestionIndex].attempts = currentAttempts,
        remainingTimer: remainingTime,
        attemptsPerQuestion: [
          ...state.attemptsPerQuestion
            ..[state.currentQuestionIndex] = currentAttempts,
        ],
      );
      return;
    }

    state = state.copyWith(
      score: isCorrect ? state.score + 1 : state.score,
      canAnswer: false,
      userAnswer: answer,
      quiz: state.quiz
        ..questions[state.currentQuestionIndex].userAnswer = answer
        ..questions[state.currentQuestionIndex].attempts = currentAttempts,
      remainingTimer: remainingTime,
      attemptsPerQuestion: [
        ...state.attemptsPerQuestion
          ..[state.currentQuestionIndex] = currentAttempts,
      ],
    );
  }

  void repeatQuestion() {
    int newRemainingTime = state.remainingTimer -
        state.quiz.questions[state.currentQuestionIndex].penaltySeconds;
    if (newRemainingTime < 0) {
      newRemainingTime = 0;
    }

    state = state.copyWith(
      canAnswer: true,
      userAnswer: '',
      remainingTimer: newRemainingTime,
    );
    _startQuestionTimer();
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.quiz.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        canAnswer: true,
        userAnswer: '',
        remainingTimer:
            state.quiz.questions[state.currentQuestionIndex + 1].initialTimer!,
      );
      _startQuestionTimer();
    } else {
      state = state.copyWith(isFinished: true);
    }
  }

  void _startQuestionTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !state.isFinished && state.canAnswer) {
        final newRemainingTime = state.remainingTimer - 1;
        state = state.copyWith(remainingTimer: newRemainingTime);

        if (newRemainingTime <= 0) {
          state = state.copyWith(
            canAnswer: false,
            userAnswer: 'Time\'s Up!',
            quiz: state.quiz
              ..questions[state.currentQuestionIndex].userAnswer = 'Time\'s Up!'
              ..questions[state.currentQuestionIndex].attempts =
                  state.attemptsPerQuestion[state.currentQuestionIndex],
            shouldAnimateLottie: true,
            showContinuePrompt: true,
          );
        } else {
          _startQuestionTimer();
        }
      }
    });
  }

  void resetQuiz() {
    state = QuizState(
      quiz: state.quiz,
      remainingTimer: state.quiz.questions[0].initialTimer!.toInt(),
      attemptsPerQuestion: List.filled(state.quiz.questions.length, 0),
    );
    _startQuestionTimer();
  }
}

final quizProvider =
    StateNotifierProvider.family<QuizNotifier, QuizState, Quiz>(
  (ref, quiz) => QuizNotifier(quiz),
);
