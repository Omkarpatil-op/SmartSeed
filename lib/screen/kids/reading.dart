import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartseed/components/story_details_sc.dart';
import 'package:smartseed/components/story_details_screen.dart';

class ReadingScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ReadingScreen({super.key, required this.userData});

  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  List<Map<String, dynamic>> stories = [];
  int userCoins = 10;
  List<String> unlockedStories = [];
  int age = 6;

  @override
  void initState() {
    super.initState();

    int currentYear = DateTime.now().year;
    int birthYear =
        widget.userData["birth_year"]; // Fetch birth year from user data
    age = currentYear - birthYear; // Calculate age

    if (age > 8) {
      _loadStories();
    } else if (age >= 7 && age <= 8) {
      _loadStories2();
    } else {
      _loadStories2();
    }
    _fetchUserCoins();
    _fetchUnlockedStories();
  }

  // Fetch the user's coins from Firebase
  Future<void> _fetchUserCoins() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('kids')
        .doc(widget.userData["kid_id"])
        .get();

    if (userSnapshot.exists) {
      // Check if coins are 0, if so, set it to 30
      int currentCoins = userSnapshot["coins"] ?? 0;

      if (currentCoins == 0) {
        // If coins are 0, add 30 coins
        await FirebaseFirestore.instance
            .collection('kids')
            .doc(widget.userData["kid_id"])
            .update({
          'coins': 20, // Add 30 coins to the existing value
        });
        setState(() {
          userCoins = 20; // Update the state with 30 coins
        });
      } else {
        setState(() {
          userCoins = currentCoins; // Use the current coins value
        });
      }
    }
  }

  // Fetch the list of unlocked stories for the user
  Future<void> _fetchUnlockedStories() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('kids')
        .doc(widget.userData["kid_id"])
        .get();
    if (userSnapshot.exists) {
      setState(() {
        unlockedStories =
            List<String>.from(userSnapshot["unlocked_stories"] ?? []);
      });
    }
  }

  // Load stories from local JSON files
  Future<void> _loadStories() async {
    List<String> storyFiles = [
      "assets/stories/1.Rise_Of_Warrior.json",
      "assets/stories/2.छत्रपती शिवाजी महाराजांची कथा.json",
      "assets/stories/3.The Rise of Chhatrapati Sambhaji Maharaj.json",
      "assets/stories/4.The Valor of Rani Durgavati.json",
      "assets/stories/5.The Life of Maharana Pratap.json",
      "assets/stories/6.The Bravery of Laxmi Bai.json",
      "assets/stories/7. The Leadership of Sardar Vallabhbhai Patel.json",
      "assets/stories/8.Gandhi's Nonviolent Struggle.json",
      "assets/stories/9.The Vision of Jawaharlal Nehru.json",
      "assets/stories/10.Subhas Chandra Bose The Forgotten Hero.json",
      "assets/stories/11.The Contributions of Dr. B.R. Ambedkar.json",
      "assets/stories/12.Indira Gandhi India’s First Female Prime Minister.json",
    ];

    for (String filePath in storyFiles) {
      String jsonData = await rootBundle.loadString(filePath);
      stories.add(json.decode(jsonData));
    }

    setState(() {}); // Trigger UI rebuild once stories are loaded
  }

  Future<void> _loadStories2() async {
    List<String> storyFiles = [
      "assets/stories/The Brave Young Warrior.json",
      "assets/stories/2.Shivaji Maharaj.json",
      "assets/stories/3.Chhatrapati Sambhaji Maharaj.json",
      "assets/stories/4.The Valor of Rani Durgavati.json",
      "assets/stories/5.The Life of Maharana Pratap.json",
      "assets/stories/6.The Bravery of Laxmi Bai.json",
      "assets/stories/7. The Leadership of Sardar Vallabhbhai Patel.json",
      "assets/stories/8.Gandhi's Nonviolent Struggle.json",
      "assets/stories/9.The Vision of Jawaharlal Nehru.json",
    ];

    for (String filePath in storyFiles) {
      String jsonData = await rootBundle.loadString(filePath);
      stories.add(json.decode(jsonData));
    }

    setState(() {}); // Trigger UI rebuildc once stories are loaded
  }

  // Show the unlock confirmation dialog

  Future<void> _showUnlockDialog(int index, int age) async {
    if (userCoins >= 5) {
      // Show confirmation dialog if not unlocked
      bool unlockConfirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Unlock Story: ${stories[index]["title"]}"),
          content: const Text(
              "Are you sure you want to use 20 coins to unlock this story?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes
              },
              child: const Text("Unlock"),
            ),
          ],
        ),
      );

      if (unlockConfirmed) {
        // Deduct 20 coins and navigate to the story details screen
        setState(() {
          userCoins -= 20;
          unlockedStories.add(
              stories[index]["title"]); // Add the unlocked story to the list
        });

        // Update coins and unlocked stories in Firebase
        await FirebaseFirestore.instance
            .collection('kids')
            .doc(widget.userData["kid_id"])
            .update({
          'coins': userCoins,
          'unlocked_stories': unlockedStories,
        });

        // Navigate to the story detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => age >= 6
                ? StoryDetailScreen(
                    story: stories[index],
                    userData: widget.userData,
                  )
                : StoryDetailScreen2(
                    story: stories[index], userData: widget.userData),
          ),
        );
      }
    } else {
      // Show Snackbar if not enough coins
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You do not have enough coins!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData["age"]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Story Library"),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, size: 30, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                "Super Coins: $userCoins",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          bool isUnlocked = unlockedStories.contains(stories[index]["title"]);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 26),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                stories[index]["title"],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: isUnlocked
                  ? const Icon(Icons.arrow_forward)
                  : const Icon(Icons.lock,
                      color: Colors.red), // Lock icon if not unlocked
              onTap: () {
                if (isUnlocked) {
                  // Navigate to the story if unlocked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => age > 6
                          ? StoryDetailScreen(
                              story: stories[index],
                              userData: widget.userData,
                            )
                          : StoryDetailScreen2(
                              story: stories[index], userData: widget.userData),
                    ),
                  );
                } else {
                  // Show the unlock dialog if not unlocked
                  _showUnlockDialog(index, age);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
