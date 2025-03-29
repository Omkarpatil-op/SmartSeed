import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class KidProfilePage extends StatelessWidget {
  final Map<String, dynamic> kidData;

  const KidProfilePage({required this.kidData, super.key});

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    return timestamp.toString(); // If already a string, return as is
  }

  @override
  Widget build(BuildContext context) {
    // Define theme colors
    const backgroundColor = Colors.black;
    const primaryColor = Colors.blue;
    const foregroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Back to Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Animation
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Lottie.asset(
                  "assets/lottie/twokids.json",
                  animate: true,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Name Header
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    "${kidData['first_name']}'s Full Report",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Personal Info Card
              _buildCard(
                "Personal Info",
                Icons.person_outline,
                [
                  _infoRow(Icons.person, "First Name", kidData['first_name']),
                  _infoRow(Icons.cake, "Age",
                      (2025 - kidData['birth_year']).toString()),
                  _infoRow(Icons.school, "Grade Level",
                      kidData['grade_level'].toString()),
                  _infoRow(Icons.speed, "Learning Pace",
                      kidData['preferred_learning_pace']),
                  _infoRow(
                      Icons.star_border, "Skill Level", kidData['skill_level']),
                ],
              ),

              const SizedBox(height: 20),

              // Progress Section
              _buildCard(
                "Progress",
                Icons.trending_up,
                [
                  _infoRow(Icons.check_circle_outline, "Completed Lessons",
                      kidData['progress']['completed_lessons'].toString()),
                  _infoRow(Icons.book_outlined, "Current Lesson",
                      kidData['progress']['current_lesson'].toString()),
                  _infoRow(
                      Icons.history,
                      "Last Activity",
                      kidData['progress']['last_activity'] != null
                          ? _formatTimestamp(
                              kidData['progress']['last_activity'])
                          : "No recent activity"),
                ],
              ),

              const SizedBox(height: 20),

              // Achievements Section
              _buildCard(
                "Achievements",
                Icons.emoji_events_outlined,
                kidData['achievements'].isEmpty
                    ? [Center(child: _emptyState("No achievements yet."))]
                    : _buildAchievementsList(),
              ),

              const SizedBox(height: 20),

              // Performance Section
              _buildCard(
                "Performance",
                Icons.insert_chart_outlined,
                [
                  _infoRow(Icons.emoji_events, "Average Score",
                      "${kidData['performance']['average_score']}%"),
                  _infoRow(Icons.quiz, "Quiz Attempts",
                      kidData['performance']['quiz_attempts'].toString()),
                  _infoRow(Icons.stars, "Last Quiz Score",
                      "${kidData['performance']['last_quiz_score']}%"),
                  const SizedBox(height: 8),
                  _buildPerformanceIndicator(
                      kidData['performance']['average_score']),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // Title Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// Creates an info row with an icon
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Text("$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.7),
                )),
          ),
        ],
      ),
    );
  }

  /// Empty State Widget
  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  /// Build achievements list items
  List<Widget> _buildAchievementsList() {
    List<Widget> achievements = [];

    for (var i = 0; i < kidData['achievements'].length; i++) {
      var achievement = kidData['achievements'][i];

      achievements.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimestamp(achievement['earned_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // Add a divider except after the last item
      if (i < kidData['achievements'].length - 1) {
        achievements.add(const SizedBox(height: 6));
      }
    }

    return achievements;
  }

  /// Performance Indicator
  Widget _buildPerformanceIndicator(dynamic score) {
    int numericScore = int.tryParse(score.toString()) ?? 0;

    Color indicatorColor;
    if (numericScore >= 80) {
      indicatorColor = Colors.green;
    } else if (numericScore >= 60) {
      indicatorColor = Colors.amber;
    } else {
      indicatorColor = Colors.redAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Overall Performance",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              "$numericScore%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: indicatorColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: numericScore / 100,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
