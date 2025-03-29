import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smartseed/components/kid_detail.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/service/kid_parent/kid_parent_service.dart';

class ReportPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final AuthService auth;

  const ReportPage({required this.userData, required this.auth, super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  final ParentKidService _parentKidService = ParentKidService();
  List<Map<String, dynamic>> kids = [];
  bool isLoading = true;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  int _currentTappedCardIndex = -1;

  // Define color scheme
  final Color backgroundColor = Colors.black;
  final Color primaryColor = Colors.blue.shade600;
  final Color secondaryColor = Colors.blue.shade300;
  final Color foregroundColor = Colors.white;
  final Color cardColor = Color(0xFF121212);

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
        builder: (context) => KidProfilePage(kidData: kidData),
      ),
    );
  }

  // Function to trigger animation when card is tapped
  _onCardTap(int index, Map<String, dynamic> kidData) {
    setState(() {
      _currentTappedCardIndex = index;
    });

    _controller.forward().then((_) {
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
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: foregroundColor,
        title: Text(
          "Family Dashboard",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings_rounded, size: 24, color: secondaryColor),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Color(0xFF051428),
              Color(0xFF0A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parent name with decorative elements
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(
                        color: primaryColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: TextStyle(
                                fontSize: 12,
                                color: foregroundColor.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              widget.userData['full_name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: foregroundColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Dashboard Title with subtle glow effect
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [secondaryColor, primaryColor],
                    ).createShader(bounds);
                  },
                  child: Text(
                    "Kids Dashboard",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: foregroundColor,
                    ),
                  ),
                ),

                SizedBox(height: 4),

                // Subtitle
                Text(
                  "Track your child's progress",
                  style: TextStyle(
                    fontSize: 14,
                    color: foregroundColor.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: 16),

                // Main content area
                Expanded(
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/animation/loading.json',
                                width: 120,
                                height: 120,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Loading your family data...",
                                style: TextStyle(
                                  color: foregroundColor.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : kids.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.child_care_rounded,
                                    size: 60,
                                    color: primaryColor.withOpacity(0.5),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No children profiles found",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: foregroundColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Add your children to start tracking",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: foregroundColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.only(top: 8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8,
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
                                                    BorderRadius.circular(20),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    cardColor,
                                                    cardColor.withBlue(50),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: primaryColor
                                                        .withOpacity(
                                                            0.1 * value),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: primaryColor
                                                      .withOpacity(0.3 * value),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Lottie animation
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: primaryColor
                                                              .withOpacity(0.6),
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: SizedBox(
                                                        width: 60,
                                                        height: 60,
                                                        child: Lottie.asset(
                                                          'assets/animation/pp1.json',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(height: 12),

                                                    // Kid's Name
                                                    ShaderMask(
                                                      shaderCallback:
                                                          (Rect bounds) {
                                                        return LinearGradient(
                                                          colors: [
                                                            foregroundColor,
                                                            secondaryColor
                                                          ],
                                                        ).createShader(bounds);
                                                      },
                                                      child: Text(
                                                        kid['first_name'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              foregroundColor,
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(height: 4),

                                                    // Age with icon
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.cake_rounded,
                                                          size: 14,
                                                          color: secondaryColor,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "Age: ${2025 - kid['birth_year']}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                foregroundColor
                                                                    .withOpacity(
                                                                        0.8),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 12),

                                                    // "View Profile" indicator
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 10,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: primaryColor
                                                            .withOpacity(0.2),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .visibility_rounded,
                                                            size: 14,
                                                            color:
                                                                secondaryColor,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            "View Profile",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: foregroundColor
                                                                  .withOpacity(
                                                                      0.9),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
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
          ),
        ),
      ),
    );
  }
}
