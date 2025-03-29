import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProgress({
    required String kidId,
    required int score,
    required int totalQuestions,
    required int questionsAttempted,
    required int correctAnswers,
    required int incorrectAnswers,
    required double accuracy,
    required int timeTaken,
    required int bestScore,
  }) async {
    final userProgressRef = _firestore.collection('user_progress').doc(kidId);

    // Get the current progress
    final doc = await userProgressRef.get();
    if (doc.exists) {
      // Update existing progress
      final currentTotalScore = doc['totalScore'] ?? 0;
      final currentBestScore = doc['bestScore'] ?? 0;

      await userProgressRef.update({
        'totalScore': currentTotalScore + score,
        'totalQuestions': FieldValue.increment(totalQuestions),
        'questionsAttempted': FieldValue.increment(questionsAttempted),
        'correctAnswers': FieldValue.increment(correctAnswers),
        'incorrectAnswers': FieldValue.increment(incorrectAnswers),
        'accuracy': ((correctAnswers / questionsAttempted) * 100),
        'timeTaken': FieldValue.increment(timeTaken),
        'bestScore': score > currentBestScore ? score : currentBestScore,
      });
    } else {
      // Create new progress document
      await userProgressRef.set({
        'kidId': kidId,
        'totalScore': score,
        'totalQuestions': totalQuestions,
        'questionsAttempted': questionsAttempted,
        'correctAnswers': correctAnswers,
        'incorrectAnswers': incorrectAnswers,
        'accuracy': accuracy,
        'timeTaken': timeTaken,
        'bestScore': bestScore,
      });
    }
  }
}
