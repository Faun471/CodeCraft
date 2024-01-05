import 'package:codecraft/models/question.dart';
import 'package:yaml/yaml.dart';

class Quiz {
  final List<Question> questions;
  final int timer;
  final int level;

  Quiz({required this.questions, required this.timer, required this.level});

  bool checkAnswer(Question question, String userAnswer) {
    return question.correctAnswer == userAnswer;
  }

  static Quiz parseQuiz(String yamlString) {
    var yamlMap = loadYaml(yamlString);

    List<Question> questions = [];
    for (var questionData in yamlMap['questions']) {
      var question = questionData['Question'];
      var questionOptions = List<String>.from(question['options']);
      questions.add(Question(
        questionText: question['text'],
        answerOptions: questionOptions,
        correctAnswer: question['answer'],
      ));
    }

    return Quiz(
        questions: questions,
        timer: yamlMap['timer'] as int,
        level: yamlMap['level'] as int);
  }
}
