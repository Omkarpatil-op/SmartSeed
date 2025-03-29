import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:smartseed/components/card_translator.dart';
import 'dart:async'; // For Timer
import 'dart:ui';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../screen/Main/mainKids.dart'; // For ImageFilter
import '../ai_chatbot/controller/translate_controller.dart';

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> story;
  final Map<String, dynamic> userData;

  const StoryDetailScreen({
    required this.story,
    required this.userData,
    super.key,
  });

  @override
  _StoryDetailScreenState createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen>
    with SingleTickerProviderStateMixin {
  final TranslateController _c = Get.put(TranslateController()); // Initialize the controller

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

  FlutterTts flutterTts = FlutterTts();
  double volumerange = 0.5;
  double pitchrange = 1;
  double speechrange = 0.5;
  bool isSpeaking = false;

  play() async {
    final languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage(languages[23]);
    await flutterTts.setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});

    String contentText = widget.story["content"][currentContentIndex]["text"];

    await flutterTts.speak(contentText);
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

  @override
  void initState() {
    _c.resetTranslation();
    _speech = stt.SpeechToText();
    startTyping();
    super.initState();
    _controller = TextEditingController();

    kidId = widget.userData["kid_id"];
    _firestore = FirebaseFirestore.instance;
    _fetchUserCoins();
    flutterTts.setCompletionHandler(() {
      isSpeaking = false;
      setState(() {});
    });
  }

  // Function to start speech recognition
  void _startListening() async {
    bool available = await _speech.initialize();
    print("Speech-to-Text Initialized: $available");

    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        print("Recognized Words: ${result.recognizedWords}");
        setState(() {
          _speechText = result.recognizedWords;
        });

        _calculateAccuracy();
        //  _stopListening();
      });
    } else {
      print("Speech-to-Text not available.");
    }
  }

  // Function to stop listening
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Function to calculate accuracy based on comparison of speech and story content
  void _calculateAccuracy() {
    String normalizeText(String text) {
      return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    }

    String storyText =
    normalizeText(widget.story["content"][currentContentIndex]["text"]);
    String userSpeech = normalizeText(_speechText);

    List<String> storyWords = storyText.split(RegExp(r'\s+'));
    List<String> userWords = userSpeech.split(RegExp(r'\s+'));

    int matchingWords = 0;
    for (var word in userWords) {
      if (storyWords.contains(word)) {
        matchingWords++;
      }
    }

    double accuracy = (matchingWords / storyWords.length) * 100;
    print("Story Text: $storyText");
    print("User Speech: $userSpeech");
    print("Matching Words: $matchingWords");
    print("Accuracy: $accuracy%");

    setState(() {
      accuracyPercentage = accuracy;
    });
  }

  void startTyping() {
    if (!mounted) return; // Prevent updates if the widget is disposed

    Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (!mounted) {
        timer.cancel(); // Stop the timer if the widget is no longer in the tree
        return;
      }

      if (_controller.text.length < typingText.length) {
        _controller.text = typingText.substring(0, _controller.text.length + 1);
        _controller.selection = TextSelection.fromPosition(TextPosition(
            offset: _controller.text.length)); // Keep caret at the end
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
    }
  }

  /// Function to move to the next content based on user choice
  void _nextContent(int nextId) {
    _c.resetTranslation();
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
        _speechText = '';
        accuracyPercentage = 0.0;
      });
      // Reset the translation state
      _c.resetTranslation();

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
    bool isLastContent = currentContentIndex ==
        widget.story["content"].length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story["title"]),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min, // Keeps row compact
            children: [
              const Icon(Icons.monetization_on, size: 30, color: Colors.amber),
              // Coins icon
              const SizedBox(width: 8),
              // Space between icon and text
              Text(
                "Score: $score",
                style: const TextStyle(
                  fontSize: 24, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              // Space before the edge of the screen
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable content remains unchanged functionality-wise.
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Improved Card styling
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.deepPurple.shade400,
                    elevation: 10,
                    shadowColor: Colors.purpleAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          currentContent["text"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Kid',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Microphone button to start/stop listening
                  Center(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Mic Icon (Centered)
                            Expanded(
                              child: Center(
                                child: IconButton(
                                  icon: AvatarGlow(
                                    glowColor: _isListening ? Colors.green : Colors.blue,
                                    endRadius: 60.0,
                                    duration: const Duration(milliseconds: 2000),
                                    repeat: true,
                                    showTwoGlows: true,
                                    child: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      size: 100,
                                      color: _isListening ? Colors.green : Colors.blue,
                                    ),
                                  ),
                                  onPressed: _isListening ? _stopListening : _startListening,
                                ),
                              ),
                            ),

                            // AI Icon (Extreme Right)
                            IconButton(
                              icon: const Icon(Icons.adb_outlined, size: 40, color: Colors.blue), // AI icon
                              onPressed: () {
                                print("AI icon pressed"); // Debugging
                                _c.textC.text = currentContent["text"];
                                _c.to.value = 'mr'; // Set the target language to Marathi
                                _c.googleTranslate(); // Call the translation function
                              },
                            ),
                          ],
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight
                              .bold),
                        ),

                        // Add the translation card below
                        CardTranslator(), // Include the translation card widget
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
                            builder: (context) =>
                                BlankPage(
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
                              onPressed: play,
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

                  if (accuracyPercentage > 75 &&
                      currentContent.containsKey("question"))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gradient Text for the title.
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.purpleAccent
                                ],
                              ).createShader(bounds),
                          child: const Text(
                            "❓ Questions:",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .white, // Important for the gradient effect.
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Question text styling.
                        Text(
                          currentContent["question"]["question"],
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Options Buttons using Wrap for better responsiveness.
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: currentContent["question"]["options"]
                              .map<Widget>((option) {
                            bool isSelected = selectedAnswer == option;
                            bool isCorrect = option ==
                                currentContent["question"]["answer"];
                            bool isWrong = wrongAnswer == option;
                            return SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.45,
                              child: ElevatedButton(
                                onPressed: () {
                                  stop();
                                  _checkAnswer(option,
                                      currentContent["question"]["answer"]);
                                  setState(() {
                                    selectedAnswer = option;
                                    wrongAnswer = !isCorrect ? option : null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  backgroundColor: isSelected
                                      ? (isCorrect ? Colors.green : Colors.red)
                                      : (wrongAnswer != null && isCorrect
                                      ? Colors.green
                                      : Colors.blueAccent),
                                ),
                                child: Text(
                                  option,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 40),

                        // Subtle divider for a clean separation.
                        const Divider(
                          color: Colors.white54,
                          thickness: 1.2,
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Choices for navigation with improved button styling.
                  if (!isLastContent)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: currentContent["choices"].map<Widget>((
                            choice) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: questionAnswered
                                  ? () => _nextContent(choice["next"])
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0, vertical: 20.0),
                                minimumSize: const Size(double.infinity, 60),
                              ),
                              child: Text(
                                choice["option"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  if (isLastContent)
                    Center(
                      child: ElevatedButton(
                        onPressed: questionAnswered
                            ? () async {
                          await _checkForBonusCoins();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MainKid(
                                    userData: widget.userData,
                                    currentIndex: 1,
                                  ),
                            ),
                                (Route<dynamic> route) => false,
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 20.0),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: const Text(
                          "Complete",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),

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
      ),
    );
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