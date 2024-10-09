import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  String? id;
  final String title;
  final List<Question> questions;
  final String duration;
  int experienceToEarn;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.duration,
    this.experienceToEarn = 0,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map(
              (question) => Question.fromJson(question as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] as String? ?? '',
      experienceToEarn: json['experienceToEarn'] as int? ?? 0,
    );
  }

  bool get isPerfect => questions
      .every((question) => question.userAnswer == question.correctAnswer);

  bool get isPassingScore =>
      questions
          .where((question) => question.userAnswer == question.correctAnswer)
          .length >=
      passingGrade;

  num get passingGrade => (questions.length * 0.7).ceil();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((question) => question.toJson()).toList(),
      'duration': duration,
      'experienceToEarn': experienceToEarn,
    };
  }
}

class Question {
  final String questionText;
  final List<String> answerOptions;
  final String correctAnswer;
  String? userAnswer;
  int? initialTimer;
  int remainingTimer;
  final int penaltySeconds;
  int maxAttempts;
  int attempts;

  Question({
    required this.questionText,
    required this.answerOptions,
    required this.correctAnswer,
    required this.initialTimer,
    required this.penaltySeconds,
    this.userAnswer,
    this.maxAttempts = 3,
    this.attempts = 0,
  }) : remainingTimer = initialTimer ?? 15;

  bool checkAnswer(String answer) {
    if (answer == correctAnswer) {
      userAnswer = answer;
      return true;
    } else {
      remainingTimer =
          (remainingTimer - penaltySeconds).clamp(0, initialTimer ?? 15);
      return false;
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'] as String? ?? '',
      answerOptions:
          List<String>.from(json['answerOptions'] as List<dynamic>? ?? []),
      correctAnswer: json['correctAnswer'] as String? ?? '',
      initialTimer: json['initialTimer'] as int? ?? 30,
      penaltySeconds: json['penaltySeconds'] as int? ?? 5,
      userAnswer: json['userAnswer'] as String?,
      maxAttempts: json['maxAttempts'] as int? ?? 0,
      attempts: json['attempts'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'answerOptions': answerOptions,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'initialTimer': initialTimer,
      'remainingTimer': remainingTimer,
      'penaltySeconds': penaltySeconds,
      'maxAttempts': maxAttempts,
      'attempts': attempts,
    };
  }
}

class QuizResult {
  String id;
  final int score;
  final Map<String, String?> answers;
  final DateTime completedAt;
  final List<int> attempts;

  QuizResult({
    required this.id,
    required this.score,
    required this.answers,
    required this.completedAt,
    required this.attempts,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] ?? '',
      score: json['score'],
      answers: Map<String, String?>.from(json['answers']),
      completedAt: (json['completedAt'] as Timestamp).toDate(),
      attempts: List<int>.from(json['attempts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'answers': answers,
      'completedAt': completedAt,
      'attempts': attempts,
    };
  }

  factory QuizResult.empty() {
    return QuizResult(
      id: '',
      score: 0,
      answers: {},
      completedAt: DateTime.now(),
      attempts: [],
    );
  }
}
