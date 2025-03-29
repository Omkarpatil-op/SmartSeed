import 'package:shared_preferences/shared_preferences.dart';

class QuizCompletionHelper {
  static const String _quizCompletionKey = 'quiz_completion';

  // Save quiz completion status for a specific level and sublevel
  static Future<void> markQuizAsCompleted(String levelId, int sublevel) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_quizCompletionKey-$levelId-$sublevel';
    await prefs.setBool(key, true);
  }

  // Check if the quiz is completed for a specific level and sublevel
  static Future<bool> isQuizCompleted(String levelId, int sublevel) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_quizCompletionKey-$levelId-$sublevel';
    return prefs.getBool(key) ?? false;
  }
}
