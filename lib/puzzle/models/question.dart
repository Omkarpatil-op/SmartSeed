class Question {
  final int id;
  final String text;
  final List<String> options;
  final String correctAnswer;
  final int difficulty;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
  });
}
