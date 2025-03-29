import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartseed/service/auth/authService.dart';

class MathReport extends StatefulWidget {
  final Map<String, dynamic> userData; // Parent data
  const MathReport({super.key, required this.userData});

  @override
  State<MathReport> createState() => _MathReportState();
}

class _MathReportState extends State<MathReport>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userProgressData;
  String? selectedKidId; // To store the selected kid's ID
  bool isLoading = false; // To show loading state when fetching data
  late List<Map<String, dynamic>> kids = []; // List of kids
  AuthService authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Make sure the animation is initialized before continuing
    _animationController.value = 0.0;

    // Then fetch kids
    fetchKids();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fetch kids for the parent
  Future<void> fetchKids() async {
    setState(() {
      isLoading = true;
    });

    String parentId = widget.userData['parent_id'];
    List<Map<String, dynamic>> fetchedKids =
        await authService.getKidsByParentID(parentId);

    setState(() {
      kids = fetchedKids;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Math Report',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Custom kid selector
              GestureDetector(
                onTap: () => _showKidSelectionDialog(context),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.child_care,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedKidId == null
                              ? 'Select a Kid'
                              : 'Selected: ${kids.firstWhere((kid) => kid['kid_id'] == selectedKidId)['first_name']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Display the math report or loading indicator
              if (isLoading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator(
                          color: Colors.blue.shade600,
                          strokeWidth: 6,
                          backgroundColor:
                              Colors.blue.shade900.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading report...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              else if (userProgressData != null)
                Expanded(
                  child: FadeTransition(
                    opacity: _animation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Speedometer gauge for performance
                          SpeedometerGauge(
                            value: (userProgressData!['correctAnswers'] /
                                userProgressData!['questionsAttempted'] *
                                100),
                            label: 'Performance compared to peer group',
                            minLabel: 'Newcomer',
                            maxLabel: 'Expert',
                            indicatorColor: Colors.blue,
                          ),

                          const SizedBox(height: 25),

                          // Two metrics side by side in a row
                          Row(
                            children: [
                              // Accuracy card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Accuracy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${userProgressData!['accuracy']}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.arrow_upward,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Reaction time card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Reaction Time',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${(userProgressData!['timeTaken'] / userProgressData!['questionsAttempted']).toStringAsFixed(2)}s',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.arrow_upward,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Report items
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              children: [
                                _buildReportCard(
                                    'Best Score',
                                    '${userProgressData!['bestScore']}',
                                    Icons.emoji_events,
                                    Colors.amber),
                                _buildReportCard(
                                    'Total Score',
                                    '${userProgressData!['totalScore']}',
                                    Icons.score,
                                    Colors.green),
                                _buildReportCard(
                                    'Correct Answers',
                                    '${userProgressData!['correctAnswers']}',
                                    Icons.check_circle,
                                    Colors.teal),
                                _buildReportCard(
                                    'Incorrect Answers',
                                    '${userProgressData!['incorrectAnswers']}',
                                    Icons.cancel,
                                    Colors.redAccent),
                                _buildReportCard(
                                    'Questions Attempted',
                                    '${userProgressData!['questionsAttempted']}',
                                    Icons.question_answer,
                                    Colors.orange),
                                _buildReportCard(
                                    'Total Questions',
                                    '${userProgressData!['totalQuestions']}',
                                    Icons.list_alt,
                                    Colors.purpleAccent),
                                _buildReportCard(
                                    'Time Taken',
                                    '${userProgressData!['timeTaken']} seconds',
                                    Icons.timer,
                                    Colors.blueAccent),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (selectedKidId != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No data found for the selected kid.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _showKidSelectionDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Select Another Kid',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                // No selection yet
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_search,
                          size: 80,
                          color: Colors.blue.shade400,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Select a kid to view their math report',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a report card item
  Widget _buildReportCard(
      String label, String value, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Show a dialog to select a kid
  void _showKidSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 26,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Select a Kid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Kid list
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: kids.length,
                    itemBuilder: (context, index) {
                      final kid = kids[index];
                      final isSelected = selectedKidId == kid['kid_id'];

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedKidId = kid['kid_id'];
                            });
                            fetchUserProgressData();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade700,
                                  radius: 20,
                                  child: Text(
                                    kid['first_name'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  kid['first_name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Cancel button
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade300,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fetch user progress data for the selected kid
  Future<void> fetchUserProgressData() async {
    if (selectedKidId == null) return;

    setState(() {
      isLoading = true;
      userProgressData = null; // Reset previous data
    });

    final firestore = FirebaseFirestore.instance;
    final doc =
        await firestore.collection('user_progress').doc(selectedKidId).get();

    setState(() {
      isLoading = false;
      if (doc.exists) {
        userProgressData = doc.data();
        _animationController.reset();
        _animationController.forward();
      }
    });
  }
}

// Speedometer Gauge Widget
class SpeedometerGauge extends StatelessWidget {
  final double value; // Value from 0 to 100
  final String label;
  final String minLabel;
  final String maxLabel;
  final Color indicatorColor;
  final bool showPercentage;
  final String unit;
  final IconData? iconData;

  const SpeedometerGauge({
    Key? key,
    required this.value,
    this.label = '',
    this.minLabel = 'Newcomer',
    this.maxLabel = 'Expert',
    this.indicatorColor = Colors.blue,
    this.showPercentage = true,
    this.unit = '%',
    this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title text
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Value display with arrow icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                showPercentage
                    ? "${value.toInt()}$unit"
                    : value.toStringAsFixed(2) + unit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Speedometer gauge
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: SpeedometerPainter(
                value: value,
                indicatorColor: indicatorColor,
              ),
            ),
          ),

          // Min and Max labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  maxLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double value; // Value between 0 and 100
  final Color indicatorColor;

  SpeedometerPainter({
    required this.value,
    required this.indicatorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = min(size.width / 2, size.height) - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Define the gauge arc angles (in radians)
    const startAngle = pi + 0.3; // slightly right of bottom
    const sweepAngle = pi - 0.6; // less than 180 degrees

    // Calculate the position for the indicator
    final normalizedValue = value / 100; // Convert to 0-1 range
    final indicatorAngle = startAngle + (sweepAngle * normalizedValue);

    // Draw the background track (segments)
    final segmentCount = 12;
    final segmentAngle = sweepAngle / segmentCount;
    final segmentGap = 0.02; // Gap between segments

    // Define segment colors (red to green gradient)
    final colors = [
      const Color(0xFFFF4D4D), // Red
      const Color(0xFFFF6E4D), // Red-Orange
      const Color(0xFFFF9E4D), // Orange
      const Color(0xFFFFD24D), // Yellow-Orange
      const Color(0xFFFFE74D), // Yellow
      const Color(0xFFE5F54D), // Yellow-Green
      const Color(0xFFBCF54D), // Light Green
      const Color(0xFF8BF04D), // Green
    ];

    // Draw each segment with its color
    for (int i = 0; i < segmentCount; i++) {
      final segmentStart = startAngle + (i * segmentAngle);
      final segmentSweep = segmentAngle - segmentGap;
      final colorIndex =
          min((i * colors.length) ~/ segmentCount, colors.length - 1);

      final paint = Paint()
        ..color = colors[colorIndex]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        segmentStart,
        segmentSweep,
        false,
        paint,
      );
    }

    // Background circle
    canvas.drawCircle(
      center,
      radius - 25,
      Paint()..color = Colors.black,
    );

    // Draw the indicator needle
    final needleLength = radius - 15;
    final needleEndPoint = Offset(
      center.dx + needleLength * cos(indicatorAngle),
      center.dy + needleLength * sin(indicatorAngle),
    );

    // Draw needle line
    final needlePaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEndPoint, needlePaint);

    // Draw center circle (needle pivot)
    canvas.drawCircle(
      center,
      10,
      Paint()..color = indicatorColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
