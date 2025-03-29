
import 'package:flutter/material.dart';
import 'package:smartseed/components/kidProfile.dart';
import 'package:smartseed/components/mainPuzzle.dart';
import 'package:smartseed/screen/kids/reading.dart';
import 'package:smartseed/screen/moral/moralStories.dart';

class MainKid extends StatefulWidget {
  final Map<String, dynamic> userData;
  final int currentIndex;  // Ensure that currentIndex is properly defined here

  const MainKid({
    required this.userData,
    required this.currentIndex,  // Correctly pass currentIndex
    super.key,
  });

  @override
  State<MainKid> createState() => _MainKidState();
}

class _MainKidState extends State<MainKid> {
  late int _currentIndex;  // Declare the _currentIndex variable here

  late List<Widget> _pages;  // Declare it here to use userData

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;  // Set _currentIndex to the passed currentIndex value
    _pages = [
      PuzzleScreen(userData: widget.userData),
      ReadingScreen(userData: widget.userData),  // Pass user data
      Moralstories(userData: widget.userData),
      KidProfilePage(kidData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.extension), label: "Puzzle"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "Reading"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Questions"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class GeneralQuestionsScreen extends StatelessWidget {
  const GeneralQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("General Questions Section"));
  }
}
