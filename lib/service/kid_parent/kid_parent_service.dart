import 'package:cloud_firestore/cloud_firestore.dart';

class ParentKidService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all kids of a parent by Parent ID
  Future<List<Map<String, dynamic>>> getKidsByParentID(String parentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('kids')
          .where('parent_id', isEqualTo: parentId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching kids: $e");
      return [];
    }
  }

  // Get specific kid information by Kid ID
  Future<Map<String, dynamic>?> getKidByID(String kidId) async {
    try {
      DocumentSnapshot kidDoc =
          await _firestore.collection('kids').doc(kidId).get();
      return kidDoc.exists ? kidDoc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching kid data: $e");
      return null;
    }
  }

  Future<bool> storeQuizPerformance({
    required String levelId, // e.g., "level_1"
    required String sublevelId, // e.g., "sublevel_1"
    required String kidId, // Unique kid ID
    required int totalScore,
    required int totalQuestions,
    required int questionsAttempted,
    required int correctAnswers,
    required int incorrectAnswers,
    required double accuracy,
    required int timeTaken,
    required int bestScore,
    required double avgTimePerQuestion,
    required List<int> wrongAnswersList,
    required List<String> weakTopics,
    required double quizCompletionRate,
  }) async {
    try {
      DocumentReference kidPerformanceRef = FirebaseFirestore.instance
          .collection('levels')
          .doc(levelId)
          .collection('sublevels')
          .doc(sublevelId)
          .collection('quiz_performance')
          .doc(kidId);

      await kidPerformanceRef.set({
        'kid_id': kidId,
        'total_score': totalScore,
        'total_questions': totalQuestions,
        'questions_attempted': questionsAttempted,
        'correct_answers': correctAnswers,
        'incorrect_answers': incorrectAnswers,
        'accuracy': accuracy,
        'time_taken': timeTaken, // ✅ Added time field
        'best_score': bestScore,
        'average_time_per_question': avgTimePerQuestion,
        'wrong_answers_list': wrongAnswersList,
        'weak_topics': weakTopics,
        'quiz_completion_rate': quizCompletionRate,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print("Error storing quiz performance: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserQuizPerformance(
      String kidId) async {
    List<Map<String, dynamic>> userPerformance = [];

    try {
      // Reference to the 'levels' collection
      QuerySnapshot levelsSnapshot =
          await FirebaseFirestore.instance.collection('levels').get();

      for (var levelDoc in levelsSnapshot.docs) {
        String levelId = levelDoc.id; // e.g., "level_1"

        // Reference to the 'sublevels' collection
        QuerySnapshot sublevelsSnapshot = await FirebaseFirestore.instance
            .collection('levels')
            .doc(levelId)
            .collection('sublevels')
            .get();

        for (var sublevelDoc in sublevelsSnapshot.docs) {
          String sublevelId = sublevelDoc.id; // e.g., "sublevel_1"

          // Reference to the 'quiz_performance' document for the kid
          DocumentSnapshot kidPerformanceSnapshot = await FirebaseFirestore
              .instance
              .collection('levels')
              .doc(levelId)
              .collection('sublevels')
              .doc(sublevelId)
              .collection('quiz_performance')
              .doc(kidId)
              .get();

          if (kidPerformanceSnapshot.exists) {
            Map<String, dynamic> data =
                kidPerformanceSnapshot.data() as Map<String, dynamic>;

            // Add level and sublevel IDs for context
            data['levelId'] = levelId;
            data['sublevelId'] = sublevelId;

            userPerformance.add(data);
          }
        }
      }

      return userPerformance;
    } catch (e) {
      print("Error fetching user quiz performance: $e");
      return [];
    }
  }

  // Update kid's learning preferences
  Future<bool> updateKidLearningPreferences(
      String kidId, String preferences) async {
    try {
      await _firestore
          .collection('kids')
          .doc(kidId)
          .update({'learning_preferences': preferences});
      return true;
    } catch (e) {
      print("Error updating learning preferences: $e");
      return false;
    }
  }

  // Update kid's progress
  Future<bool> updateKidProgress(
      String kidId, int completedLessons, int currentLesson) async {
    try {
      await _firestore.collection('kids').doc(kidId).update({
        'progress.completed_lessons': completedLessons,
        'progress.current_lesson': currentLesson,
        'progress.last_activity': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error updating progress: $e");
      return false;
    }
  }

  // Add a new achievement for the kid
  Future<bool> addKidAchievement(
      String kidId, Map<String, dynamic> achievement) async {
    try {
      await _firestore.collection('kids').doc(kidId).update({
        'achievements': FieldValue.arrayUnion([achievement])
      });
      return true;
    } catch (e) {
      print("Error adding achievement: $e");
      return false;
    }
  }

  // Update kid's performance
  Future<bool> updateKidPerformance(
      String kidId, int avgScore, int quizAttempts, int lastQuizScore) async {
    try {
      await _firestore.collection('kids').doc(kidId).update({
        'performance.average_score': avgScore,
        'performance.quiz_attempts': quizAttempts,
        'performance.last_quiz_score': lastQuizScore,
      });
      return true;
    } catch (e) {
      print("Error updating performance: $e");
      return false;
    }
  }

  // Delete a kid's account by Kid ID
  Future<bool> deleteKid(String kidId) async {
    try {
      await _firestore.collection('kids').doc(kidId).delete();
      return true;
    } catch (e) {
      print("Error deleting kid account: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _getTasksByParentId(
      String parentId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('parentId', isEqualTo: parentId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching tasks by parentId: $e");
      return []; // Return an empty list instead of null
    }
  }

  /// Fetch tasks by `kidId`
  Future<List<Map<String, dynamic>>> _getTasksByKidId(String kidId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('kidId', isEqualTo: kidId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching tasks by kidId: $e");
      return []; // Return an empty list instead of null
    }
  }
}
