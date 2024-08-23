class DebuggingChallenge {
  final String id;
  final String instructions;
  final String initialCode;
  final int correctLine;
  final String solution;
  int attemptsLeft;
  final int timeLimit;

  DebuggingChallenge({
    required this.id,
    required this.instructions,
    required this.initialCode,
    required this.correctLine,
    required this.solution,
    required this.attemptsLeft,
    required this.timeLimit,
  });

  factory DebuggingChallenge.fromJson(Map<String, dynamic> data) {
    return DebuggingChallenge(
      id: data['id'],
      instructions: data['instructions'],
      initialCode: data['initialCode'],
      correctLine: data['correctLine'],
      solution: data['solution'],
      attemptsLeft: data['attemptsLeft'],
      timeLimit: data['timeLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructions': instructions,
      'initialCode': initialCode,
      'correctLine': correctLine,
      'solution': solution,
      'attemptsLeft': attemptsLeft,
      'timeLimit': timeLimit,
    };
  }

  void decrementAttempts() {
    if (attemptsLeft > 0) {
      attemptsLeft--;
    }
  }
}
