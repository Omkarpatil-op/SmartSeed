import 'package:flutter/material.dart';
import '../ai_chatbot/screen/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartseed/puzzle/map_screen.dart';

class PuzzleScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  late final List<Map<String, dynamic>> puzzleCategories;

  PuzzleScreen({super.key, required this.userData}) {
    // Initialize puzzleCategories in the constructor
    puzzleCategories = [
      {
        "title": "Math Puzzles 🔢",
        "subtitle": "Solve fun math challenges!",
        "gifUrl":
        "https://i.pinimg.com/736x/fb/11/12/fb11124caf40fd2bf227a1cbe5dadd5e.jpg",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelMapScreen(
                userData: userData,
              ),
            ),
          );
        },
      },
      {
        "title": "Yoga",
        "subtitle": "Mindful movement for wellness..!",
        "gifUrl":
        "https://i.pinimg.com/736x/b9/cb/ca/b9cbca2eca5d8369840b651f032ec522.jpg",
        "onTap": (BuildContext context) async {
          final Uri url = Uri.parse("https://yogaweb-nine.vercel.app");
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            throw Exception('Could not launch $url');
          }
        },
      },
      {
        "title": "Homework Questions ✏️",
        "subtitle": "Turn your homework into a fun puzzle!",
        "gifUrl": "https://media.giphy.com/media/3o7qE1YN7aBOFPRw8E/giphy.gif",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelMapScreen(
                userData: userData,
              ),
            ),
          );
        },
      },
      {
        "title": "Logic Puzzles 🤔",
        "subtitle": "Boost your brainpower with tricky puzzles!",
        "gifUrl": "https://media.giphy.com/media/l0HlNaQ6gWfllcjDO/giphy.gif",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelMapScreen(
                userData: userData,
              ),
            ),
          );
        },
      },
      {
        "title": "Memory Games 🧠",
        "subtitle": "Train your memory with fun challenges!",
        "gifUrl":
        "https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExanl0Z3lmdzVseDBqbDlpOWFzbHp5NXppZDdvdDNlNjQ4YXltMHoyMiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/8BS2RgwTl9Z7O/giphy.gif",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelMapScreen(
                userData: userData,
              ),
            ),
          );
        },
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Define our theme colors
    const backgroundColor = Color(0xFF121212);
    const primaryColor = Color(0xFF2196F3);
    const foregroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        title: Text(
          "Welcome, ${userData['first_name']}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: primaryColor.withOpacity(0.3), width: 1),
                ),
                child: const Text(
                  "🧠 Let's Solve Some Puzzles! 🚀",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    "https://media.giphy.com/media/l0HlNQ03J5JxX6lva/giphy.gif",
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Row(
              //   children: [
              //     Expanded(
              //       child: ElevatedButton(
              //         onPressed: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => const HomeScreen()),
              //           );
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: primaryColor,
              //           foregroundColor: foregroundColor,
              //           elevation: 5,
              //           padding: const EdgeInsets.symmetric(vertical: 15),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //         child: const Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Icon(Icons.home),
              //             SizedBox(width: 8),
              //             Text(
              //               'Home',
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: ElevatedButton(
              //         onPressed: () async {
              //           final Uri url =
              //           Uri.parse("https://yogaweb-nine.vercel.app");
              //           if (!await launchUrl(url,
              //               mode: LaunchMode.externalApplication)) {
              //             throw Exception('Could not launch $url');
              //           }
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: backgroundColor,
              //           foregroundColor: foregroundColor,
              //           elevation: 5,
              //           padding: const EdgeInsets.symmetric(vertical: 15),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //             side: BorderSide(color: primaryColor, width: 1.5),
              //           ),
              //         ),
              //         child: const Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Icon(Icons.open_in_browser),
              //             SizedBox(width: 8),
              //             Text(
              //               'Browser',
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: foregroundColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: puzzleCategories.length,
                itemBuilder: (context, index) {
                  return _buildPuzzleButton(
                    context,
                    puzzleCategories[index]["title"]!,
                    puzzleCategories[index]["subtitle"]!,
                    puzzleCategories[index]["gifUrl"]!,
                    primaryColor,
                    puzzleCategories[index]["onTap"]!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleButton(
      BuildContext context,
      String title,
      String subtitle,
      String gifUrl,
      Color primaryColor,
      Function(BuildContext) onTap,
      ) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                gifUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Container(
              height: 170,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videogame_asset,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}