import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smartseed/screen/moral/moral_story_details.dart';
import 'package:smartseed/service/stories/story_service.dart';

class Moralstories extends StatefulWidget {
  final Map<String, dynamic> userData;
  const Moralstories({required this.userData, super.key});

  @override
  State<Moralstories> createState() => _MoralstoriesState();
}

class _MoralstoriesState extends State<Moralstories> {
  final StoryService _storyService = StoryService();
  List<dynamic> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    List<dynamic> stories = await _storyService.loadStories();
    setState(() {
      _stories = stories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Moral Stories",
          style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? const Center(child: Text("No stories available"))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Lottie.asset("assets/lottie/kidreading.json", height: 250),
                    const SizedBox(height: 30),
                    Expanded(
                      child: StoryCard(
                        userData: widget.userData,
                        story: _stories[0], // Show only the first story
                        allStories: _stories,
                        index: 0,
                      ),
                    ),
                  ],
                ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final dynamic story;
  final List<dynamic> allStories;
  final int index;

  const StoryCard({
    required this.userData,
    super.key,
    required this.story,
    required this.allStories,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Lottie.asset("assets/lottie/kidreading.json", height: 100),
            const SizedBox(height: 10),
            Text(
              story['title'],
              style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              story['story'],
              style: const TextStyle(fontSize: 25, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryDetailScreen(
                        userData: userData,
                        stories: allStories, // Pass full story list
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: const Text("Continue",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
