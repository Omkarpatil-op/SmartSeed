import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:smartseed/service/stories/moral_behaviour.dart';

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<dynamic> stories;
  final int initialIndex;

  const StoryDetailScreen({
    required this.userData,
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  _StoryDetailScreenState createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  MoralBehaviour moralBehaviour = MoralBehaviour();

  int _currentIndex = 0;
  Map<String, String> selectedAnswers = {}; // Stores selected answers
  String? selectedOption; // Stores current answer selection

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _goToNextStory() {
    print("_currentIndex: $_currentIndex");
    print("Total stories - 1: ${widget.stories.length - 1}");

    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        selectedOption = null; // Reset selection for the next question
      });
    }

    // Ensure _showResults() runs when the last question is answered
    if (_currentIndex >= widget.stories.length - 1) {
      print("📢 Last question reached, showing results...");
      _showResults();
    }
  }

  void _showResults() {
    print("📢 _showResults() called!");

    String resultJson = jsonEncode(selectedAnswers);
    print("📝 Selected Answers JSON: $resultJson");

    moralBehaviour.analyzeAndStoreBehaviour(
      widget.userData['kid_id'],
      widget.userData['parent_id'],
      selectedAnswers,
    );

    showDialog(
      context: context,
      builder: (context) {
        print("✅ Showing results dialog...");
        return AlertDialog(
          title: const Text("Your Answers"),
          content: SingleChildScrollView(
            child: Text(resultJson),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("❌ Closing results dialog...");
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showAnswerDialog(String selected, String? correctAnswer) {
    print("object $selected");
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing until button is clicked
      builder: (context) => AlertDialog(
        title: Text(selected == correctAnswer ? "Correct!" : "Wrong Answer"),
        content: Text(
          selected == correctAnswer
              ? "Good job! You got it right."
              : "You have to choose $correctAnswer",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _goToNextStory(); // Always go to the next question
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(story['title'] ?? "Untitled Story"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story['story'] ?? "No story available",
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display Situations
            if (story['situations'] != null)
              ...story['situations'].asMap().entries.map<Widget>((entry) {
                int index = entry.key;
                var situation = entry.value;

                return Card(
                  color: index == 0
                      ? Colors.green // First one green
                      : index == 1
                          ? Colors.redAccent // Second one red
                          : Colors.blueAccent, // Default blue for others
                  child: ListTile(
                    title: Text(
                      situation['description'] ?? "No description",
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      situation['outcome'] ?? "No outcome",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 20),

            // Display Questions
            if (story['questions'] != null &&
                story['questions'].isNotEmpty &&
                story['questions'][0] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['questions'][0]['question'] ??
                        "No question available",
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...?story['questions'][0]['options']?.map<Widget>((option) {
                    return ListTile(
                      title: Text(option ?? "No option"),
                      leading: Radio<String>(
                        value: option,
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                            selectedAnswers[story['questions'][0]['question'] ??
                                "Unknown question"] = value;
                          });

                          // Fetch the correct answer safely
                          String? correctAnswer =
                              story['questions'][0]['correct'] as String?;

                          // Show answer feedback
                          _showAnswerDialog(value!, correctAnswer);
                        },
                      ),
                    );
                  })?.toList(),
                ],
              ),

            const Spacer(),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex--;
                        selectedOption = selectedAnswers[
                            widget.stories[_currentIndex]['title'] ??
                                "Unknown"];
                      });
                    },
                    child: const Text("Previous"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
