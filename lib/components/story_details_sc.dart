import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'dart:async'; // For Timer
import 'dart:ui';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Add this import

import '../screen/Main/mainKids.dart'; // For ImageFilter

class StoryDetailScreen2 extends StatefulWidget {
  final Map<String, dynamic> story;
  final Map<String, dynamic> userData;

  const StoryDetailScreen2({
    required this.story,
    required this.userData,
    super.key,
  });

  @override
  _StoryDetailScreen2State createState() => _StoryDetailScreen2State();
}

class _StoryDetailScreen2State extends State<StoryDetailScreen2>
    with SingleTickerProviderStateMixin {
  // Add speech-to-text variables
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _speechText = '';
  double accuracyPercentage = 0.0;

  String? wrongAnswer; // Add this variable to track the wrong answer.
  int score = 0;
  int correctAnswers = 0;
  int totalQuestions = 0;
  int currentContentIndex = 0;
  bool questionAnswered = false;
  int _currentIndex = 1;
  String? selectedAnswer;
  late String kidId;
  late FirebaseFirestore _firestore;
  int userCoins = 0;

  bool isCelebrating = false;
  bool isCoinCollecting = false;
  bool isnotCelebrating = false;
  TextEditingController _controller = TextEditingController();

  String typingText =
      "Well Tried My Dear Friend ..!"; // The text that will be typed out

  // Add variables for word-by-word display
  List<String> contentWords = [];
  int currentWordIndex = 0;
  String displayText = "";

  FlutterTts flutterTts = FlutterTts();
  double volumerange = 0.5;
  double pitchrange = 1;
  double speechrange = 0.5;
  bool isSpeaking = false;

  static const stopWords = {
    "a", "of", "an", "the", "in", "on", "at", "for", "to", "with", "and", "or","day",
    "he", "she", "his", "her", "it", "they", "them", "their"
  };

  String removeStopWords(String text) {
    return text
        .split(" ")
        .where((word) => !stopWords.contains(word.toLowerCase()))
        .join(" ");
  }

  // Function to play only the current word
  void playCurrentWord() async {
    final languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage(languages[23]);
    await flutterTts.setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});

    await flutterTts.speak(displayText); // Play only the current word
    isSpeaking = true;
    setState(() {});
  }

  PlayOnWrongAnswer() async {
    final languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage(languages[23]);
    await flutterTts.setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
    await flutterTts.speak("Well Tried My Dear Friend");
    isSpeaking = true;
    setState(() {});
  }

  PlayOnCorrectAnswer() async {
    final languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage(languages[23]);
    await flutterTts.setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
    await flutterTts.speak("Nice..Keep Going My Friend..");
    isSpeaking = true;
    setState(() {});
  }

  stop() async {
    await flutterTts.stop();
    isSpeaking = false;
    setState(() {});
  }

  pause() async {
    await flutterTts.pause();
    isSpeaking = false;
    setState(() {});
  }

  volume(val) async {
    volumerange = val;
    await flutterTts.setVolume(volumerange);
    setState(() {});
  }

  pitch(val) async {
    pitchrange = val;
    await flutterTts.setPitch(pitchrange);
    setState(() {});
  }

  speech(val) async {
    speechrange = val;
    await flutterTts.setSpeechRate(speechrange);
    setState(() {});
  }

  // Function to initialize word-by-word display
  void _initializeWordDisplay() {
    String contentText = widget.story["content"][currentContentIndex]["text"];
    // Remove stop words from the content text
    contentText = removeStopWords(contentText);
    contentWords = contentText.split(' ');
    currentWordIndex = 0;
    _updateDisplayText();
  }

  // Function to update display text with current word
  void _updateDisplayText() {
    if (currentWordIndex < contentWords.length) {
      setState(() {
        displayText = contentWords[currentWordIndex];
      });
    }
  }

  // Function to show next word
  void _showNextWord() {
    if (currentWordIndex < contentWords.length - 1) {
      setState(() {
        currentWordIndex++;
        _updateDisplayText();
        _speechText = ''; // Reset recognized speech
        accuracyPercentage = 0.0; // Reset accuracy
      });
    }
  }

  // Function to show previous word
  void _showPreviousWord() {
    if (currentWordIndex > 0) {
      setState(() {
        currentWordIndex--;
        _updateDisplayText();
        _speechText = ''; // Reset recognized speech
        accuracyPercentage = 0.0; // Reset accuracy
      });
    }
  }

  @override
  void initState() {
    _speech = stt.SpeechToText(); // Initialize speech-to-text
    startTyping();
    super.initState();
    _controller = TextEditingController();
    print(widget.userData);

    print("2nd bidojo");

    kidId = widget.userData["kid_id"];
    _firestore = FirebaseFirestore.instance;
    _fetchUserCoins();
    flutterTts.setCompletionHandler(() {
      isSpeaking = false;
      setState(() {});
    });

    // Initialize word-by-word display
    _initializeWordDisplay();
  }

  // Function to start speech recognition
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech recognition status: $status");
      },
      onError: (error) {
        print("Speech recognition error: $error");
      },
    );

    print("Speech-to-Text Initialized: $available");

    if (available) {
      setState(() {
        _isListening = true;
      });

      // Determine the language of the current word
      String currentWord = contentWords[currentWordIndex];
      bool isMarathi = _isMarathi(currentWord); // Check if the word is in Marathi

      // Set the language based on the current word
      String localeId = isMarathi ? "mr-IN" : "en-US";

      await _speech.listen(
        onResult: (result) {
          print("Recognized Words: ${result.recognizedWords}");
          setState(() {
            _speechText = result.recognizedWords;
          });
          _stopListening();
          _calculateAccuracy();
        },
        localeId: localeId, // Set language dynamically
      );
    } else {
      print("Speech-to-Text not available.");
    }
  }

  // Function to check if a word is in Marathi
  bool _isMarathi(String text) {
    // Marathi Unicode range: [\u0900-\u097F]
    final marathiRegex = RegExp(r'[\u0900-\u097F]');
    return marathiRegex.hasMatch(text);
  }

  // Function to stop listening
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }



  // Function to calculate accuracy based on comparison of speech and current word
  void _calculateAccuracy() {
    String normalizeText(String text) {
      return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    }

    String currentWord = normalizeText(contentWords[currentWordIndex]);
    String userSpeech = normalizeText(_speechText);

    // Remove stop words from both current word and user speech
    currentWord = removeStopWords(currentWord);
    userSpeech = removeStopWords(userSpeech);

    if (currentWord == userSpeech) {
      setState(() {
        accuracyPercentage = 100.0;
        isCelebrating = true;

        if (isCelebrating) {
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              isCelebrating = false;
              isCoinCollecting = true;
              if (isCoinCollecting) {
                Future.delayed(const Duration(seconds: 4), () {
                  setState(() {
                    score += 25;
                    isCoinCollecting = false; // Stop celebration after animation
                  });
                });
              }
            });
          });
        }

        if (isnotCelebrating) {
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              isnotCelebrating = false; // Stop celebration after animation
            });
          });
        }
      });
    } else {
      setState(() {
        accuracyPercentage = 0.0;
      });
    }
  }

  void startTyping() {
    Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (_controller.text.length < typingText.length) {
        _controller.text = typingText.substring(0, _controller.text.length + 1);
        _controller.selection = TextSelection.fromPosition(TextPosition(
            offset: _controller.text.length)); // Ensure caret stays at the end
        setState(() {}); // Trigger UI update
      } else {
        timer.cancel(); // Stop the timer once the text is complete
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fetch user's coins from Firestore
  Future<void> _fetchUserCoins() async {
    DocumentSnapshot kidSnapshot =
    await _firestore.collection('kids').doc(kidId).get();
    if (kidSnapshot.exists) {
      setState(() {
        userCoins = kidSnapshot["coins"] ?? 0;
      });
    }
  }

  /// Function to handle user's answer
  void _checkAnswer(String selectedAnswer, String correctAnswer) {
    if (!questionAnswered) {
      setState(() {
        totalQuestions++;
        this.selectedAnswer = selectedAnswer;

        if (selectedAnswer == correctAnswer) {
          PlayOnCorrectAnswer();

          correctAnswers++;
          isCelebrating = true;
        }

        if (selectedAnswer != correctAnswer) {
          PlayOnWrongAnswer();
          isnotCelebrating = true;
          _controller.clear(); // Clear the previous text on wrong answer
          startTyping();
        }
        questionAnswered = true;
      });

      _updatePerformance();
      if (isCelebrating) {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            isCelebrating = false;
            isCoinCollecting = true;
            if (isCoinCollecting) {
              Future.delayed(const Duration(seconds: 4), () {
                setState(() {
                  score += 25;
                  isCoinCollecting = false; // Stop celebration after animation
                });
              });
            } // Stop celebration after animation
          });
        });
      }

      if (isnotCelebrating) {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            isnotCelebrating = false; // Stop celebration after animation
          });
        });
      }
    }
  }

  /// Function to move to the next content based on user choice
  void _nextContent(int nextId) {
    if (!questionAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer the question first!")),
      );
      return;
    }

    int newIndex = widget.story["content"]
        .indexWhere((element) => element["id"] == nextId);

    if (newIndex != -1) {
      setState(() {
        currentContentIndex = newIndex;
        questionAnswered = false;
        selectedAnswer = null;
        wrongAnswer = null; // Reset selection for the next question
      });

      // Reset word-by-word display for new content
      _initializeWordDisplay();
      _updateProgress();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("The story has ended!")),
      );

      _checkForBonusCoins();
    }
  }

  /// Check if user answered 80%+ correctly and update coins
  Future<void> _checkForBonusCoins() async {
    double correctPercentage = (correctAnswers / totalQuestions) * 100;
    if (correctPercentage > 80) {
      setState(() {
        userCoins += 15;
      });

      await _firestore.collection('kids').doc(kidId).update({
        "coins": userCoins,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "🎉 Congratulations my Friend You earned 10 bonus coins...!")),
      );
    }
  }

  /// Check and update achievements
  Future<void> _checkAchievements() async {
    DocumentReference kidRef = _firestore.collection('kids').doc(kidId);
    DocumentSnapshot kidSnapshot = await kidRef.get();

    if (kidSnapshot.exists) {
      Map<String, dynamic> progress = kidSnapshot["progress"] ?? {};
      int completedLessons = progress["completed_lessons"] ?? 0;
      List<dynamic> achievements = kidSnapshot["achievements"] ?? [];

      List<Map<String, String>> newAchievements = [];

      if (completedLessons == 1 &&
          !achievements.any((a) => a["title"] == "First Steps")) {
        newAchievements.add({
          "title": "First Steps",
          "description": "Completed the first lesson",
          "earned_at": DateTime.now().toIso8601String(),
        });
      }

      if (completedLessons == 5 &&
          !achievements.any((a) => a["title"] == "Explorer")) {
        newAchievements.add({
          "title": "Explorer",
          "description": "Completed 5 lessons",
          "earned_at": DateTime.now().toIso8601String(),
        });
      }

      if (newAchievements.isNotEmpty) {
        await kidRef.update({
          "achievements": FieldValue.arrayUnion(newAchievements),
        });
      }
    }
  }

  Future<void> _updateIndex(int index) async {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Updates progress in Firestore
  Future<void> _updateProgress() async {
    DocumentReference kidRef = _firestore.collection('kids').doc(kidId);

    await kidRef.update({
      "progress.current_lesson": FieldValue.increment(1),
      "progress.completed_lessons": FieldValue.increment(1),
      "progress.last_activity": FieldValue.serverTimestamp(),
    });

    _checkAchievements();
  }

  /// Updates performance in Firestore
  Future<void> _updatePerformance() async {
    DocumentReference kidRef = _firestore.collection('kids').doc(kidId);

    DocumentSnapshot kidSnapshot = await kidRef.get();
    if (kidSnapshot.exists) {
      Map<String, dynamic> performance = kidSnapshot["performance"] ?? {};
      int quizAttempts = (performance["quiz_attempts"] ?? 0) + 1;
      double lastScore = (correctAnswers / totalQuestions) * 100;
      double avgScore =
          ((performance["average_score"] ?? 0) * (quizAttempts - 1) +
              lastScore) /
              quizAttempts;

      await kidRef.update({
        "performance.quiz_attempts": quizAttempts,
        "performance.correct_answers": correctAnswers,
        "performance.total_questions": totalQuestions,
        "performance.last_quiz_score": lastScore,
        "performance.average_score": avgScore,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentContent = widget.story["content"][currentContentIndex];

    bool isLastContent =
        currentContentIndex == widget.story["content"].length - 1;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.story["title"]),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min, // Keeps row compact
              children: [
                const Icon(Icons.monetization_on,
                    size: 30, color: Colors.amber), // Coins icon
                const SizedBox(width: 8), // Space between icon and text
                Text(
                  "Score: $score",
                  style: const TextStyle(
                    fontSize: 24, // Increased font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                    width: 16), // Space before the edge of the screen
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            // Scrollable content remains unchanged functionality-wise.
            SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word display card with navigation buttons
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.deepPurple.shade400,
                      elevation: 10,
                      shadowColor: Colors.purpleAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                displayText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Kid',
                                  fontSize:
                                  40, // Increased font size for better visibility
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Previous word button
                                ElevatedButton.icon(
                                  onPressed: currentWordIndex > 0
                                      ? _showPreviousWord
                                      : null,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Previous'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                ),
                                // Word counter indicator
                                Text(
                                  '${currentWordIndex + 1}/${contentWords.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                // Next word button (enabled only if accuracy is 100%)
                                ElevatedButton.icon(
                                  onPressed: accuracyPercentage == 100.0
                                      ? _showNextWord
                                      : null,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Next'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accuracyPercentage == 100.0
                                        ? Colors.greenAccent
                                        : Colors.grey, // Disable if not 100%
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Centered microphone, speech, and accuracy
                    Center(
                      child: Column(
                        children: [
                          // Microphone button to start/stop listening
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              size: 70,
                              color: _isListening
                                  ? Colors.green
                                  : Colors.blue, // Green when listening
                            ),
                            onPressed:
                            _isListening ? _stopListening : _startListening,
                          ),
                          const SizedBox(height: 20),
                          // Display speech and accuracy percentage
                          // Text(
                          //   "Your Speech: $_speechText",
                          //   style: const TextStyle(fontSize: 20),
                          // ),
                          const SizedBox(height: 20),
                          Text(
                            "Accuracy: ${accuracyPercentage.toStringAsFixed(2)}%",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Right aligned icon button with extra padding for a cleaner look
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.bar_chart_outlined, size: 32),
                        color: Colors.white70,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlankPage(
                                initialVolume: volumerange,
                                initialPitch: pitchrange,
                                initialSpeechRate: speechrange,
                                onVolumeChanged: volume,
                                onPitchChanged: pitch,
                                onSpeechChanged: speech,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Audio Controls row, kept the functionality same but increased spacing.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: stop,
                          color: Colors.red,
                          splashRadius: 40,
                          iconSize: 60,
                          icon: const Icon(Icons.stop_circle),
                        ),
                        AvatarGlow(
                          animate: isSpeaking,
                          glowColor: Colors.teal,
                          endRadius: 100,
                          duration: const Duration(milliseconds: 2000),
                          repeat: true,
                          showTwoGlows: true,
                          child: Material(
                            elevation: 10,
                            shape: const CircleBorder(),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.teal,
                              child: IconButton(
                                splashRadius: 60,
                                onPressed: playCurrentWord, // Play current word
                                iconSize: 50,
                                icon: const Icon(
                                  Icons.play_arrow,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: pause,
                          color: Colors.amber.shade700,
                          splashRadius: 40,
                          iconSize: 60,
                          icon: const Icon(Icons.pause_circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),
                    // Choices for navigation with improved button styling.

                    const Divider(),
                  ],
                ),
              ),
            ),
            // Celebration animation remains, but with cleaner positioning.
            if (isCelebrating)
              Positioned.fill(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Lottie.asset(
                        'assets/animation/Celebration.json',
                        repeat: true,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            // Blurred background with typing effect (unchanged functionality).
            if (isnotCelebrating)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ),
                      Center(
                        child: Lottie.asset(
                          'assets/animation/robo.json',
                          repeat: true,
                          height: 300,
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Text(
                            _controller.text,
                            style: const TextStyle(
                              fontFamily: 'Robo',
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Coin collecting animation with a subtle layout improvement.
            if (isCoinCollecting)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 450,
                        left: 0,
                        right: 0,
                        child: Lottie.asset(
                          'assets/animation/Coins.json',
                          repeat: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }
}

class BlankPage extends StatefulWidget {
  final double initialVolume;
  final double initialPitch;
  final double initialSpeechRate;

  // Callbacks to return the updated values to the main screen
  final Function(double) onVolumeChanged;
  final Function(double) onPitchChanged;
  final Function(double) onSpeechChanged;

  const BlankPage({
    super.key,
    required this.initialVolume,
    required this.initialPitch,
    required this.initialSpeechRate,
    required this.onVolumeChanged,
    required this.onPitchChanged,
    required this.onSpeechChanged,
  });

  @override
  _BlankPageState createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  late double volumerange;
  late double pitchrange;
  late double speechrange;

  @override
  void initState() {
    super.initState();
    // Initialize the variables with the current values
    volumerange = widget.initialVolume;
    pitchrange = widget.initialPitch;
    speechrange = widget.initialSpeechRate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // Volume Slider (Extreme Thick)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 56.0, // Extremely thick track
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 16.0), // Big thumb
                overlayShape: SliderComponentShape
                    .noOverlay, // Removes default glow effect
              ),
              child: Slider(
                max: 1,
                value: volumerange,
                onChanged: (value) {
                  setState(() {
                    volumerange = value;
                  });
                  widget.onVolumeChanged(value);
                },
                divisions: 10,
                label: "Volume: $volumerange",
                activeColor: Colors.red,
              ),
            ),
            const Text(
              'Set Volume',
              style: TextStyle(
                fontSize: 28, // Increase font size
                fontWeight: FontWeight.bold, // Make it bold
              ),
            ),

            const SizedBox(height: 20),

            // Pitch Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 56.0,
                thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 16.0),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                max: 2,
                value: pitchrange,
                onChanged: (value) {
                  setState(() {
                    pitchrange = value;
                  });
                  widget.onPitchChanged(value);
                },
                divisions: 10,
                label: "Pitch Rate: $pitchrange",
                activeColor: Colors.teal,
              ),
            ),
            const Text(
              'Set Pitch',
              style: TextStyle(
                fontSize: 28, // Increase font size
                fontWeight: FontWeight.bold, // Make it bold
              ),
            ),
            const SizedBox(height: 20),

            // Speech Rate Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 56.0,
                thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 16.0),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                max: 1,
                value: speechrange,
                onChanged: (value) {
                  setState(() {
                    speechrange = value;
                  });
                  widget.onSpeechChanged(value);
                },
                divisions: 10,
                label: "Speech rate: $speechrange",
                activeColor: Colors.amber.shade700,
              ),
            ),
            const Text(
              'Set Speech Rate',
              style: TextStyle(
                fontSize: 30, // Increase font size
                fontWeight: FontWeight.bold, // Make it bold
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}