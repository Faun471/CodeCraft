class Question {
  final String questionText;
  final List<String> answerOptions; 
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.answerOptions,
    required this.correctAnswer
  });
}