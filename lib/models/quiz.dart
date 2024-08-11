class Quiz {
  String? id;
  final String title;
  final List<Question> questions;
  final int timer;
  String duration;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.timer,
    required this.duration,
  });

  bool checkAnswer(Question question, String userAnswer) {
    return question.correctAnswer == userAnswer;
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String?, // Handle potential null value
      title: json['title'] as String? ?? '', // Default to empty string if null
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map(
              (question) => Question.fromJson(question as Map<String, dynamic>))
          .toList(),
      timer: json['timer'] as int? ?? 0, // Default to 0 if null
      duration:
          json['duration'] as String? ?? '', // Default to empty string if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((question) => question.toJson()).toList(),
      'timer': timer,
      'duration': duration,
    };
  }
}

class Question {
  final String questionText;
  final List<String> answerOptions;
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.answerOptions,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'] as String? ?? '',
      answerOptions:
          List<String>.from(json['answerOptions'] as List<dynamic>? ?? []),
      correctAnswer: json['correctAnswer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'answerOptions': answerOptions,
      'correctAnswer': correctAnswer,
    };
  }
}
