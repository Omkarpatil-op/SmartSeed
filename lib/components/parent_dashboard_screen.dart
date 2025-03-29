import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smartseed/components/kid_activity_screen.dart';
import 'package:smartseed/components/kid_detail.dart';
import 'package:smartseed/components/math_report.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/service/kid_parent/kid_parent_service.dart';

import '../screen/Onboard/registerkid_screen.dart';

// Define a custom color theme
const Color kBackgroundColor = Colors.black;
const Color kPrimaryColor = Color(0xFF2962FF); // A vibrant blue
const Color kForegroundColor = Colors.white;
const Color kAccentColor = Color(0xFF82B1FF); // Light blue for accents

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final AuthService auth;

  const DashboardPage({required this.userData, required this.auth, super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ParentKidService _parentKidService = ParentKidService();
  List<Map<String, dynamic>> kids = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKids();
  }

  Future<void> fetchKids() async {
    String parentId = widget.userData['parent_id'];
    print("User Data: ${widget.userData}");

    List<Map<String, dynamic>> fetchedKids =
        await _parentKidService.getKidsByParentID(parentId);

    if (!mounted) return; // Prevent setState() if the widget is disposed

    setState(() {
      kids = fetchedKids;
      isLoading = false;
    });
  }

  void openKidProfile(Map<String, dynamic> kidData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KidProfilePage(kidData: kidData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: kForegroundColor,
        title: const Text(
          "PROFILE",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_rounded,
              color: kForegroundColor,
              size: 28,
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kBackgroundColor,
              Color(0xFF121212), // Slightly lighter black
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile section with glow effect
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          width: 140,
                          height: 140,
                          color: Colors.black,
                          child: Lottie.asset(
                            'assets/animation/pp2.json',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${widget.userData['full_name']}",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kForegroundColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kPrimaryColor, width: 1),
                    ),
                    child: const Text(
                      "Member Since 2024",
                      style: TextStyle(
                        color: kAccentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile completion section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.6),
                border: Border.all(
                  color: kPrimaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Complete your profile",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kForegroundColor,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "(3/3)",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          height: 10,
                          margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: kPrimaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Card section
            Container(
              height: 160,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final card = profileCompletionCards[index];
                  return GestureDetector(
                    onTap: () {
                      if (card.title == "Add Kid") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterKid(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black,
                            kPrimaryColor.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              card.icon,
                              size: 60,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              card.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kForegroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemCount: profileCompletionCards.length,
              ),
            ),
            const SizedBox(height: 30),

            // Menu items
            ...List.generate(
              customListTiles.length,
              (index) {
                final tile = customListTiles[index];
                return GestureDetector(
                  onTap: () {
                    if (tile.title == "Logout") {
                      widget.auth.signOut();
                    } else if (tile.title == "Activity") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KidActivity(
                            userData: widget.userData,
                            auth: widget.auth,
                          ),
                        ),
                      );
                    } else if (tile.title == "Report") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MathReport(
                            userData: widget.userData,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: kPrimaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tile.icon,
                          color: kPrimaryColor,
                        ),
                      ),
                      title: Text(
                        tile.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kForegroundColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: kForegroundColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;
  final VoidCallback? onPressed;

  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
    required this.onPressed,
  });
}

List<ProfileCompletionCard> profileCompletionCards = [
  ProfileCompletionCard(
    title: "Set Up Profile",
    icon: CupertinoIcons.person_circle,
    buttonText: "",
    onPressed: null,
  ),
  ProfileCompletionCard(
    title: "Add Kid",
    icon: CupertinoIcons.square_list,
    buttonText: "",
    onPressed: null,
  ),
  ProfileCompletionCard(
    title: "What's new",
    icon: CupertinoIcons.doc,
    buttonText: "",
    onPressed: null,
  ),
];

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({
    required this.icon,
    required this.title,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    icon: Icons.insights,
    title: "Activity",
  ),
  CustomListTile(
    icon: Icons.location_on_outlined,
    title: "Report",
  ),
  CustomListTile(
    title: "Notifications",
    icon: CupertinoIcons.bell,
  ),
  CustomListTile(
    title: "Logout",
    icon: CupertinoIcons.arrow_right_arrow_left,
  ),
];
