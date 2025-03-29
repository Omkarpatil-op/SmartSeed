import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartseed/puzzle/provider/quiz_provider.dart';
import 'package:smartseed/puzzle/models/level.dart';
import 'package:smartseed/puzzle/models/question.dart';
import 'package:smartseed/puzzle/map_screen.dart';
import 'package:smartseed/puzzle/user_progress_service.dart';

class QuizScreen extends StatefulWidget {
  final Level level;
  final int sublevel;
  final Map<String, dynamic> userData;

  const QuizScreen(
      {required this.level, required this.sublevel, required this.userData});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  final Map<int, String?> _selectedAnswers = {};
  int _timeRemaining = 20; // Reduced time to 20 seconds
  late Timer _timer;
  List<int> _timeTakenPerQuestion = []; // Store time taken per question
  UserProgressService usp = UserProgressService();
  late AnimationController _timerAnimationController;

  // Colors
  final Color _backgroundColor = Colors.black;
  final Color _primaryColor = Colors.blue;
  final Color _foregroundColor = Colors.white;
  final Color _correctColor = const Color(0xFF43A047);
  final Color _incorrectColor = const Color(0xFFE53935);
  final Color _neutralColor = const Color(0xFF2C2C2C);

  @override
  void initState() {
    super.initState();

    // Setup timer animation
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _timerAnimationController.reverse(from: 1.0);

    // Load questions for the current level and sublevel
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.loadQuestionsForSublevel(widget.level.id, widget.sublevel);

    // Start the timer
    _startTimer();
  }

  void _startTimer() {
    _timerAnimationController.reverse(from: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer.cancel();
          _handleQuizCompletion();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = Provider.of<QuizProvider>(context).currentQuestions;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _neutralColor,
        title: Text(
          '${widget.level.name} - Sublevel ${widget.sublevel}',
          style: TextStyle(
            color: _foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Timer bar
          Container(
            height: 8,
            child: AnimatedBuilder(
              animation: _timerAnimationController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _timeRemaining / 20,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeRemaining > 5 ? _primaryColor : _incorrectColor,
                  ),
                );
              },
            ),
          ),
          // Timer display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: _foregroundColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  color: _timeRemaining > 5
                      ? _foregroundColor.withOpacity(0.7)
                      : _incorrectColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time Remaining: $_timeRemaining seconds',
                  style: TextStyle(
                    color: _timeRemaining > 5
                        ? _foregroundColor.withOpacity(0.7)
                        : _incorrectColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Main quiz content
          Expanded(
            child: _buildQuizBody(questions),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBody(List<Question> questions) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: _foregroundColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No questions available',
              style: TextStyle(
                fontSize: 18,
                color: _foregroundColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Color(0xFF121212),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Question progress indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  questions.length,
                      (index) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentQuestionIndex
                          ? _primaryColor
                          : _selectedAnswers.containsKey(index)
                          ? _foregroundColor.withOpacity(0.7)
                          : _foregroundColor.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),

            // Question card
            SizedBox(
              height: 150,
              width: 800,// Set a fixed height for the card
              child: Card(
                color: Colors.grey[900],
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // Reduced padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Prevents the column from expanding
                    children: [
                      // Question number
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40, // Reduced horizontal padding
                          vertical: 6,    // Reduced vertical padding
                        ),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Question ${_currentQuestionIndex + 1}',
                          style: TextStyle(
                            color: _foregroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Reduced font size
                          ),
                        ),
                      ),
                      const SizedBox(height: 21), // Reduced spacing

                      // Question text
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            currentQuestion.text,
                            style: TextStyle(
                              fontSize: 50, // Reduced font size
                              fontWeight: FontWeight.bold,
                              color: _foregroundColor,
                              height: 1.2,   // Adjusted line height
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Options
            ...currentQuestion.options
                .map((option) => _buildOptionButton(option, currentQuestion)),

            const SizedBox(height: 16),

            // Question counter
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _foregroundColor.withOpacity(0.7),
                    ),
                  ),
                  if (isLastQuestion) _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, Question currentQuestion) {
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];
    final isSelected = selectedAnswer == option;
    final isCorrect = option == currentQuestion.correctAnswer;

    Color buttonColor;
    if (selectedAnswer != null && isSelected) {
      buttonColor = isCorrect ? _correctColor : _incorrectColor;
    } else {
      buttonColor = _neutralColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            backgroundColor: buttonColor,
            foregroundColor: _foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            elevation: isSelected ? 8 : 2,
          ),
          onPressed:
          selectedAnswer != null ? null : () => _handleAnswer(option),
          child: Row(
            children: [
              if (selectedAnswer != null && isSelected)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: _foregroundColor,
                ),
              if (selectedAnswer != null && isSelected) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    color: _foregroundColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final allQuestionsAnswered =
        _selectedAnswers.length == currentQuestions.length;

    return ElevatedButton(
      onPressed: allQuestionsAnswered ? _handleQuizCompletion : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Icon(Icons.send, size: 16),
        ],
      ),
    );
  }

  void _handleAnswer(String answer) {
    final currentQuestion = currentQuestions[_currentQuestionIndex];

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
      _timeTakenPerQuestion
          .add(20 - _timeRemaining); // Store time taken for this question
      _timeRemaining = 20; // Reset timer for the next question
    });

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.answerQuestion(answer, currentQuestion.id);

    // Show feedback briefly before moving to next question
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_currentQuestionIndex < currentQuestions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _timerAnimationController.reset();
          _timerAnimationController.reverse(from: 1.0);
        });
      } else {
        _handleQuizCompletion();
      }
    });
  }

  Future<void> _handleQuizCompletion() async {
    _timer.cancel(); // Stop the timer

    final correctAnswers = _selectedAnswers.entries
        .where(
            (entry) => currentQuestions[entry.key].correctAnswer == entry.value)
        .length;

    final incorrectAnswers = currentQuestions.length - correctAnswers;

    final accuracy = (correctAnswers / currentQuestions.length) * 100;

    var averageTimeTaken = _timeTakenPerQuestion.isEmpty
        ? 0
        : _timeTakenPerQuestion.reduce((a, b) => a + b) /
        _timeTakenPerQuestion.length;

    // Example scoring logic
    final score = accuracy >= 70 ? 50 : 0;

    await usp.updateUserProgress(
      kidId: widget.userData["kid_id"], // Replace with actual kidId
      score: score,
      totalQuestions: currentQuestions.length,
      questionsAttempted: currentQuestions.length,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      accuracy: accuracy,
      timeTaken: averageTimeTaken.toInt(),
      bestScore: score, // Update this logic based on your requirements
    );

    if (accuracy >= 70) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.unlockNextSublevel(widget.level.id);

      final nextSublevel = widget.sublevel + 1;

      if (nextSublevel <= 3) {
        _showSuccessDialog(
          'Sublevel Completed!',
          'Congratulations! You have unlocked Sublevel $nextSublevel.',
          nextSublevel: nextSublevel,
        );
      } else {
        _showSuccessDialog(
          'Level Completed!',
          'Congratulations! You have completed all sublevels.',
          navigateToMap: true,
        );
      }
    } else {
      _showFailureDialog('Try Again', 'Your accuracy is less than 70%.');
    }
  }

  void _showSuccessDialog(String title, String content,
      {bool navigateToMap = false, int? nextSublevel}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: _foregroundColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: TextStyle(color: _foregroundColor.withOpacity(0.9)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Show stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                      'Questions',
                      '${_selectedAnswers.length}/${currentQuestions.length}',
                      Icons.question_answer),
                  Divider(color: Colors.grey[800]),
                  _buildStatRow(
                      'Correct',
                      '${_selectedAnswers.entries.where((entry) => currentQuestions[entry.key].correctAnswer == entry.value).length}',
                      Icons.check_circle_outline),
                  Divider(color: Colors.grey[800]),
                  _buildStatRow(
                      'Time',
                      '${_timeTakenPerQuestion.isEmpty ? 0 : (_timeTakenPerQuestion.reduce((a, b) => a + b) / _timeTakenPerQuestion.length).toStringAsFixed(1)}s avg',
                      Icons.timer),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog

              if (navigateToMap) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LevelMapScreen(
                        userData: widget.userData,
                      )),
                      (route) => false, // Remove all previous routes
                );
              } else if (nextSublevel != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      level: widget.level,
                      sublevel: nextSublevel,
                      userData: widget.userData,
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: _foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: _foregroundColor.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: _foregroundColor.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: _foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: _foregroundColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(color: _foregroundColor.withOpacity(0.9)),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _resetQuiz();
            },
            style: TextButton.styleFrom(
              backgroundColor: _incorrectColor,
              foregroundColor: _foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      _timeRemaining = 20;
      _timeTakenPerQuestion.clear();
      _timerAnimationController.reset();
      _timerAnimationController.reverse(from: 1.0);
    });

    _startTimer();
  }

  List<Question> get currentQuestions =>
      Provider.of<QuizProvider>(context, listen: false).currentQuestions;
}