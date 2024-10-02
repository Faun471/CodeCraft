class DebuggingChallenge {
  final String id;
  final String title;
  final String instructions;
  final String initialCode;
  final int correctLine;
  final String expectedOutput;
  int attemptsLeft;
  final String duration;

  DebuggingChallenge({
    required this.id,
    required this.title,
    required this.instructions,
    required this.initialCode,
    required this.correctLine,
    required this.expectedOutput,
    required this.attemptsLeft,
    required this.duration,
  });

  factory DebuggingChallenge.fromJson(Map<String, dynamic> data) {
    return DebuggingChallenge(
      id: data['id'],
      title: data['title'] ?? '',
      instructions: data['instructions'] ?? '',
      initialCode: data['initialCode'] ?? '',
      correctLine: data['correctLine'] ?? 0,
      expectedOutput: data['expectedOutput'] ?? '',
      attemptsLeft: data['attemptsLeft'] ?? 0,
      duration: data['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructions': instructions,
      'initialCode': initialCode,
      'correctLine': correctLine,
      'expectedOutput': expectedOutput,
      'attemptsLeft': attemptsLeft,
      'duration': duration,
    };
  }
}
