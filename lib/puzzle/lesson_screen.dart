import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:smartseed/puzzle/models/level.dart';
import 'package:smartseed/puzzle/quiz_screen.dart';
import 'package:smartseed/puzzle/ai/ai_service.dart';
import 'package:smartseed/puzzle/helper/quiz_completion_helper.dart';

class LessonsScreen extends StatefulWidget {
  final Level level;
  final int sublevel;
  final Map<String, dynamic> userData;

  const LessonsScreen(
      {required this.level, this.sublevel = 1, required this.userData});

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final List<Map<String, String>> _chatMessages = [];
  final AIService _aiService = AIService();
  int _currentStepIndex = 0;
  List<Map<String, dynamic>> _lessonContent = [];
  bool _isLoading = false;
  bool _isLessonCompleted = false;
  String _currentQuestion = '';
  String _correctAnswer = '';
  int _questionCount = 0; // Track the number of questions asked
  final int _maxQuestions = 3; // Set a limit for the number of questions
  final Set<String> _usedQuestions =
      {}; // Track used questions to avoid repetition

  // Colors for the new UI
  final Color _backgroundColor = Colors.black;
  final Color _primaryColor = Colors.blue;
  final Color _foregroundColor = Colors.white;
  final Color _botBubbleColor = Color(0xFF1E3A8A); // Dark blue
  final Color _userBubbleColor = Color(0xFF0D47A1); // Slightly lighter blue

  @override
  void initState() {
    super.initState();
    _initializeLesson();
  }

  void _initializeLesson() async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      _isLoading = true;
      _lessonContent.clear(); // Clear previous lesson content
      _usedQuestions.clear(); // Clear used questions
    });

    // Generate introduction
    final introduction =
        await _aiService.generateIntroduction(widget.level.name,widget.userData["birth_year"]);

    if (!mounted) return; // Check again after the async operation

    setState(() {
      _lessonContent.add({"type": "introduction", "text": introduction});
      _isLoading = false;
    });

    _startLesson();
  }

  void _startLesson() async {
    if (!mounted || _lessonContent.isEmpty) return;

    // Display the introduction in the chat messages immediately
    if (mounted) {
      setState(() {
        _chatMessages.add({
          "sender": "bot",
          "message": _lessonContent[_currentStepIndex]["text"],
        });
      });
    }

    // Speak the introduction and wait for it to complete
    await _speakAndWait(_lessonContent[_currentStepIndex]["text"]);

    if (!mounted) return; // Check again after the async operation

    // Increment the step index after speech is complete
    setState(() {
      _currentStepIndex++;
    });

    // Generate and ask the first question
    _generateAndAskQuestion();
  }

  void _generateAndAskQuestion() async {
    if (!mounted) return; // Check if the widget is still mounted

    // Check if the maximum number of questions has been reached
    if (_questionCount >= _maxQuestions) {
      if (mounted) {
        setState(() {
          _isLessonCompleted = true;
        });
      }
      _endLesson();
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    // Generate a unique question
    String question;
    do {
      question = await _aiService.generateQuestion(widget.level.name);
    } while (
        _usedQuestions.contains(question)); // Ensure the question is unique

    // Parse the question and correct answer
    final parts = question.split('||');
    if (parts.length >= 3) {
      if (mounted) {
        setState(() {
          _currentQuestion = parts[0].trim();
          _correctAnswer = parts[2].trim().toLowerCase();
          _lessonContent.add({
            "type": "question",
            "text": _currentQuestion,
            "correctAnswer": _correctAnswer,
          });
          _isLoading = false;
        });
      }

      // Add the question to used questions
      _usedQuestions.add(question);

      // Display the question in the chat messages immediately
      if (mounted) {
        setState(() {
          _chatMessages.add({
            "sender": "bot",
            "message": _currentQuestion,
          });
        });
      }

      // Speak the question and wait for it to complete
      await _speakAndWait(_currentQuestion);

      if (!mounted) return; // Check again after the async operation

      // Increment the question count
      setState(() {
        _questionCount++;
      });
    }
  }

  void _endLesson() async {
    if (!mounted) return; // Check if the widget is still mounted

    // Display a message indicating the lesson is complete
    if (mounted) {
      setState(() {
        _chatMessages.add({
          "sender": "bot",
          "message": "You've answered $_maxQuestions questions! Great job!",
        });
      });
    }

    // Speak the completion message
    await _speakAndWait("You've answered $_maxQuestions questions! Great job!");

    // Check if the quiz is already completed
    final isQuizCompleted = await QuizCompletionHelper.isQuizCompleted(
      widget.level.id.toString(), // Convert int to String
      widget.sublevel,
    );

    if (isQuizCompleted) {
      // Quiz is already completed, skip to the next sublevel
      _navigateToNextSublevel();
    } else {
      // Quiz is not completed, navigate to the QuizScreen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
                level: widget.level,
                sublevel: widget.sublevel,
                userData: widget.userData),
          ),
        );
      }
    }
  }

  void _navigateToNextSublevel() {
    if (!mounted) return; // Check if the widget is still mounted

    // Example: Increment sublevel and navigate
    final nextSublevel = widget.sublevel + 1;

    // Check if there are more sublevels
    if (nextSublevel <= widget.level.totalSublevels) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonsScreen(
              level: widget.level,
              sublevel: nextSublevel,
              userData: widget.userData,
            ),
          ),
        );
      }
    } else {
      // Show a completion message or navigate to a completion screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseCompletionScreen(),
          ),
        );
      }
    }
  }

  Future<void> _speakAndWait(String text) async {
    await flutterTts.awaitSpeakCompletion(true); // Wait for speech to complete
    await flutterTts.speak(text);
  }

  void _handleUserResponse(String response) async {
    if (!mounted) return; // Check if the widget is still mounted

    // Add user response to chat messages immediately
    if (mounted) {
      setState(() {
        _chatMessages.add({"sender": "user", "message": response});
      });
    }

    // Evaluate the response
    final evaluation = await _aiService.evaluateResponse(
      widget.level.name,
      _currentQuestion,
      response,
    );

    // Display the evaluation in the chat messages immediately
    if (mounted) {
      setState(() {
        _chatMessages.add({"sender": "bot", "message": evaluation});
      });
    }

    // Speak the evaluation and wait for it to complete
    await _speakAndWait(evaluation);

    // Generate and ask the next question (if the lesson is not completed)
    if (!_isLessonCompleted && mounted) {
      _generateAndAskQuestion();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: Text(
          '${widget.level.name} - Lesson ${widget.sublevel}',
          style: TextStyle(
            color: _foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _foregroundColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          // Subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF121212),
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: _foregroundColor.withOpacity(0.7),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Question $_questionCount of $_maxQuestions',
                    style: TextStyle(
                      color: _foregroundColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 120,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _foregroundColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 120 * (_questionCount / _maxQuestions),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: _foregroundColor.withOpacity(0.1), height: 1),

            // Chat messages
            Expanded(
              child: _chatMessages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: _foregroundColor.withOpacity(0.3),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading your lesson...',
                            style: TextStyle(
                              color: _foregroundColor.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _chatMessages.length,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemBuilder: (context, index) {
                        final message = _chatMessages[index];
                        return _buildChatBubble(message);
                      },
                    ),
            ),

            // Loading indicator
            if (_isLoading)
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_primaryColor),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Thinking...',
                      style: TextStyle(
                        color: _foregroundColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Yes/No buttons
            if (_currentStepIndex < _lessonContent.length &&
                _lessonContent[_currentStepIndex]["type"] == "question" &&
                !_isLessonCompleted)
              _buildYesNoButtons(),

            // Padding at the bottom for better appearance
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, String> message) {
    final bool isBot = message["sender"] == "bot";

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            CircleAvatar(
              backgroundColor: _primaryColor,
              radius: 16,
              child: Icon(
                Icons.school,
                size: 18,
                color: _foregroundColor,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isBot ? _botBubbleColor : _userBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isBot ? 0 : 16),
                  topRight: Radius.circular(isBot ? 16 : 0),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBot ? "Clash Tutor" : "You",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _foregroundColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message["message"]!,
                    style: TextStyle(
                      color: _foregroundColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isBot) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _userBubbleColor,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 18,
                color: _foregroundColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildYesNoButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border(
          top: BorderSide(
            color: _foregroundColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleUserResponse("Yes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: _foregroundColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Yes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleUserResponse("No"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: _foregroundColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "No",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Define the CourseCompletionScreen widget in the same file
class CourseCompletionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Course Completed",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          // Subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF121212),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: 32),
              Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "You've completed all sublevels!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
