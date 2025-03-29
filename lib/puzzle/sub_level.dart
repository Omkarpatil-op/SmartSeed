// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:smartseed/puzzle/provider/quiz_provider.dart';
// import 'package:smartseed/puzzle/models/level.dart';
// import 'package:smartseed/puzzle/quiz_screen.dart';
// import 'package:smartseed/screen/Main/mainKids.dart';

// class SublevelScreen extends StatelessWidget {
//   final Map<String, dynamic> userData;
//   const SublevelScreen({required this.userData, super.key});

//   @override
//   Widget build(BuildContext context) {
//     final quizProvider = Provider.of<QuizProvider>(context);
//     final levels = quizProvider.levels;

//     // Assuming that each level has 3 sublevels
//     int currentLevelIndex = 1; // Adjust based on the level you are in

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//             'Level ${currentLevelIndex + 1} Sublevels'), // Display current level
//         leading: IconButton(
//           icon: const Icon(Icons.home),
//           onPressed: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MainKid(
//                   userData: userData,
//                   currentIndex: 0,
//                 ),
//               ),
//               (route) => false,
//             );
//           },
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/map_background.jpg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Stack(
//           children: [
//             CustomPaint(
//               painter: SublevelPathPainter(levels),
//               size: Size.infinite,
//             ),
//             // Display the 3 sublevel nodes for this level
//             _buildSublevelNodes(context, levels, currentLevelIndex),
//           ],
//         ),
//       ),
//     );
//   }

//   // Function to create the sublevel nodes for each level
//   Widget _buildSublevelNodes(
//       BuildContext context, List<Level> levels, int currentLevelIndex) {
//     final level = levels[currentLevelIndex]; // Get the current level

//     return Positioned(
//       top: MediaQuery.of(context).size.height *
//           0.3, // Adjust based on your design
//       left: MediaQuery.of(context).size.width *
//           0.1, // Adjust based on your design
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: List.generate(3, (index) {
//           final sublevel =
//               index + 1; // Assuming there are 3 sublevels per level

//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: GestureDetector(
//               onTap: () {
//                 if (level.isUnlocked) {
//                   // Navigate to the QuizScreen for the selected sublevel
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => QuizScreen(userData: userData),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Complete previous levels first!'),
//                     ),
//                   );
//                 }
//               },
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: level.isUnlocked ? Colors.blue : Colors.grey,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 3),
//                 ),
//                 child: Center(
//                   child: Text(
//                     sublevel.toString(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// class SublevelPathPainter extends CustomPainter {
//   final List<Level> levels;

//   SublevelPathPainter(this.levels);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.yellow
//       ..strokeWidth = 5
//       ..style = PaintingStyle.stroke;

//     final path = Path();

//     if (levels.isNotEmpty) {
//       final firstLevel = levels[0];
//       path.moveTo(
//         size.width * (firstLevel.position?.dx ?? 0.0) + 30,
//         size.height * (firstLevel.position?.dy ?? 0.0) + 30,
//       );

//       for (int i = 1; i < levels.length; i++) {
//         final level = levels[i];
//         path.lineTo(
//           size.width * (level.position?.dx ?? 0.0) + 30,
//           size.height * (level.position?.dy ?? 0.0) + 30,
//         );
//       }
//     }

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
