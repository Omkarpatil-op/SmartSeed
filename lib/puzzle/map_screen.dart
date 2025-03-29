import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartseed/puzzle/provider/quiz_provider.dart';
import 'package:smartseed/puzzle/models/level.dart';
import 'package:smartseed/puzzle/lesson_screen.dart';
import 'dart:math';

class LevelMapScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const LevelMapScreen({required this.userData, super.key});
  @override
  _LevelMapScreenState createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  // Define our color scheme
  final Color backgroundColor = Colors.black;
  final Color primaryColor = Colors.blue;
  final Color accentColor = Colors.blue.shade700;
  final Color foregroundColor = Colors.white;
  final Color completedColor = Colors.green.shade400;
  final Color lockedColor = Colors.grey.shade800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Math Levels',
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background with star-like particles
          Positioned.fill(
            child: CustomPaint(
              painter: StarfieldPainter(),
            ),
          ),
          // Main content
          Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              return _buildLevelPath(context, quizProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPath(BuildContext context, QuizProvider quizProvider) {
    // Create a predefined path layout to match the image
    final List<Offset> pathPositions = [
      Offset(0.3, 0.15), // Top row, first node
      Offset(0.5, 0.15), // Top row, second node
      Offset(0.7, 0.15), // Top row, third node
      Offset(0.5, 0.3), // Second row, center node
      Offset(0.5, 0.45), // Third row, center node
      Offset(0.3, 0.6), // Fourth row, left node
      Offset(0.7, 0.6), // Fourth row, right node
      Offset(0.5, 0.8), // Character position at the bottom
    ];

    return Stack(
      children: [
        // Draw connecting dotted lines
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          painter: PathPainter(pathPositions, primaryColor),
        ),

        // Place level nodes along the path
        ...List.generate(
            min(quizProvider.levels.length, pathPositions.length - 1), (index) {
          final level = quizProvider.levels[index];
          return Positioned(
            left: MediaQuery.of(context).size.width * pathPositions[index].dx -
                35,
            top: MediaQuery.of(context).size.height * pathPositions[index].dy -
                35,
            child: GestureDetector(
              onTap: () {
                if (level.isUnlocked) {
                  _handleLevelTap(context, level, quizProvider);
                } else {
                  _showLockedLevelAlert(context);
                }
              },
              child: _buildLevelNode(level, index + 1),
            ),
          );
        }),

        // Character at the bottom
        Positioned(
          left: MediaQuery.of(context).size.width * pathPositions.last.dx - 40,
          top: MediaQuery.of(context).size.height * pathPositions.last.dy - 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                // Avatar container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor,
                        primaryColor,
                      ],
                    ),
                    border: Border.all(
                      color: foregroundColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelNode(Level level, int levelNumber) {
    // Determine if level is completed (has all sublevels completed)
    bool isCompleted = level.isUnlocked && level.sublevel > 3;

    Color backgroundColor;
    Color borderColor;
    double opacity;

    if (isCompleted) {
      backgroundColor = completedColor;
      borderColor = Colors.greenAccent;
      opacity = 1.0;
    } else if (level.isUnlocked) {
      backgroundColor = primaryColor;
      borderColor = Colors.lightBlue.shade300;
      opacity = 1.0;
    } else {
      backgroundColor = lockedColor;
      borderColor = Colors.grey.shade600;
      opacity = 0.7;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow for unlocked levels
        if (level.isUnlocked)
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
          ),

        // Main level button
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                backgroundColor.withOpacity(0.7),
              ],
            ),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Opacity(
            opacity: opacity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$levelNumber',
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!level.isUnlocked)
                    Icon(
                      Icons.lock,
                      color: foregroundColor.withOpacity(0.7),
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ),

        // Completion indicator
        if (isCompleted)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showLockedLevelAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: primaryColor, width: 2),
          ),
          title: Text(
            'Level Locked',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please complete previous levels to unlock this level.',
            style: TextStyle(
              color: foregroundColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleLevelTap(
      BuildContext context, Level level, QuizProvider quizProvider) {
    if (!level.isUnlocked) return;

    // Navigate to the LessonsScreen for the selected level
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonsScreen(
          level: level,
          userData: widget.userData,
        ),
      ),
    );
  }
}

// Custom painter to draw the connecting dotted lines between level nodes
class PathPainter extends CustomPainter {
  final List<Offset> positions;
  final Color lineColor;

  PathPainter(this.positions, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create a path that follows the positions
    for (int i = 0; i < positions.length - 1; i++) {
      final start = Offset(
        size.width * positions[i].dx,
        size.height * positions[i].dy,
      );
      final end = Offset(
        size.width * positions[i + 1].dx,
        size.height * positions[i + 1].dy,
      );

      // Draw a dotted line between points
      drawDottedLine(canvas, start, end, paint);
    }
  }

  void drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8;
    const dashSpace = 8;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);

    final steps = distance / (dashWidth + dashSpace);
    final stepX = dx / steps;
    final stepY = dy / steps;

    var currentX = start.dx;
    var currentY = start.dy;

    for (int i = 0; i < steps.floor(); i++) {
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(currentX + stepX * dashWidth / (dashWidth + dashSpace),
            currentY + stepY * dashWidth / (dashWidth + dashSpace)),
        paint,
      );

      currentX += stepX;
      currentY += stepY;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for a starfield background
class StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(42); // Fixed seed for consistent stars
    final Paint starPaint = Paint()..color = Colors.white;

    // Create 100 stars with different sizes
    for (int i = 0; i < 100; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius =
          random.nextDouble() * 1.5 + 0.5; // Stars between 0.5-2.0 pixels

      // Add some brighter stars occasionally
      if (i % 10 == 0) {
        starPaint.color = Colors.white.withOpacity(0.8);
        canvas.drawCircle(Offset(x, y), radius * 1.5, starPaint);

        // Add a subtle glow to brighter stars
        final Paint glowPaint = Paint()
          ..color = Colors.blue.withOpacity(0.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);
        canvas.drawCircle(Offset(x, y), radius * 3, glowPaint);
      } else {
        starPaint.color =
            Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.3);
        canvas.drawCircle(Offset(x, y), radius, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
