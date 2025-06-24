// lib/models/question_model.dart
class Question {
  final String text;
  final String audioPath; // We will store audio locally in assets for now
  final List<Answer> answers;

  Question({required this.text, required this.audioPath, required this.answers});
}

class Answer {
  final String text;
  final String vibe; // e.g., 'Explorer', 'Creator'

  Answer({required this.text, required this.vibe});
}