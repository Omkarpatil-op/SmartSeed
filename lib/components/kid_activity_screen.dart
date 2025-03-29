import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smartseed/components/activity_report_screen.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/service/kid_parent/kid_parent_service.dart';

class KidActivity extends StatefulWidget {
  final Map<String, dynamic> userData;
  final AuthService auth;

  const KidActivity({required this.userData, required this.auth, super.key});

  @override
  _KidActivityState createState() => _KidActivityState();
}

class _KidActivityState extends State<KidActivity>
    with SingleTickerProviderStateMixin {
  final ParentKidService _parentKidService = ParentKidService();
  List<Map<String, dynamic>> kids = [];
  bool isLoading = true;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  int _currentTappedCardIndex = -1; // Keeps track of the tapped card index

  @override
  void initState() {
    super.initState();
    fetchKids();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> fetchKids() async {
    String parentId = widget.userData['parent_id'];
    List<Map<String, dynamic>> fetchedKids =
        await _parentKidService.getKidsByParentID(parentId);

    setState(() {
      kids = fetchedKids;
      isLoading = false;
    });
  }

  void openKidProfile(Map<String, dynamic> kidData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityReport(kidData: kidData),
      ),
    );
  }

  // Function to trigger animation when card is tapped
  _onCardTap(int index, Map<String, dynamic> kidData) {
    setState(() {
      _currentTappedCardIndex = index; // Set the tapped card index
    });

    _controller.forward().then((_) {
      // After the animation is complete, navigate to the profile page
      _controller.reverse().then((_) {
        openKidProfile(kidData);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for futuristic look
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "Kids of ${widget.userData['full_name']}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded, size: 28),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Kids List 👶🏻 ",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    //letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                isLoading
                    ? Center(
                        child: Lottie.asset(
                          'assets/animation/loading.json',
                          width: 150,
                          height: 150,
                        ),
                      )
                    : kids.isEmpty
                        ? const Center(
                            child: Text(
                              "No kids added yet.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 cards per row
                                crossAxisSpacing:
                                    20, // Horizontal space between cards
                                mainAxisSpacing:
                                    20, // Vertical space between cards
                                childAspectRatio: 0.9, // Card aspect ratio
                              ),
                              itemCount: kids.length,
                              itemBuilder: (context, index) {
                                final kid = kids[index];
                                return GestureDetector(
                                  onTap: () => _onCardTap(index, kid),
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _currentTappedCardIndex == index
                                            ? _scaleAnimation.value
                                            : 1.0,
                                        child: TweenAnimationBuilder(
                                          tween: Tween<double>(
                                              begin: 0.2, end: 1.0),
                                          duration: const Duration(seconds: 2),
                                          curve: Curves.easeInOut,
                                          builder:
                                              (context, double value, child) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: Colors.grey[900],
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(
                                                      value), // Glowing border effect
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center, // Centering content
                                                    children: [
                                                      // Lottie Animation
                                                      SizedBox(
                                                        width: 70,
                                                        height: 70,
                                                        child: Lottie.asset(
                                                          'assets/animation/pp1.json',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      // Kid's Name
                                                      Text(
                                                        kid['first_name'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 35,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      // Kid's Age and Grade
                                                      Text(
                                                        "Age: ${kid['age']}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
