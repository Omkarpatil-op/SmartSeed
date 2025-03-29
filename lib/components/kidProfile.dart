import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smartseed/components/kid_goal_screen.dart';
import 'package:smartseed/service/auth/authService.dart';

class KidProfilePage extends StatelessWidget {
  final Map<String, dynamic> kidData;

  const KidProfilePage({required this.kidData, super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.black87,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blue.shade300,
        surface: Colors.grey.shade900,
        background: Colors.black,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
    );

    return Theme(
      data: darkTheme,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.grey.shade900],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar & Username Section
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade700,
                                          Colors.blue.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.transparent,
                                    child: Lottie.asset(
                                      "assets/lottie/kidreading.json",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                kidData['first_name'] ?? "Kid Name",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Level ${kidData['skill_level'] ?? "Beginner"}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Goals Section
                        _buildSectionTitle("Goals"),
                        _buildGoalsList(context),

                        // Achievements & Badges
                        _buildSectionTitle("Achievements & Badges"),
                        _buildBadgeList(kidData['achievements'] ?? []),

                        // Learning Progress
                        _buildSectionTitle("Learning Progress"),
                        _buildProgressBar(
                            "Math", kidData['math_progress'] ?? 50),
                        _buildProgressBar(
                            "Reading", kidData['reading_progress'] ?? 70),
                        _buildProgressBar("Problem-Solving",
                            kidData['problem_solving_progress'] ?? 40),

                        // Recent Activities
                        _buildSectionTitle("Recent Activities"),
                        _buildRecentActivities(
                            kidData['recent_activities'] ?? []),

                        // Daily/Weekly Streak
                        _buildSectionTitle("Daily Streak"),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade700,
                                Colors.blue.shade500
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.orange, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                "${kidData['streak'] ?? 0} days",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Rewards & Virtual Items
                        _buildSectionTitle("Rewards & Virtual Items"),
                        _buildRewardsList(kidData['rewards'] ?? []),

                        // Favorite Games & Stories
                        _buildSectionTitle("Favorite Games & Stories"),
                        _buildFavoriteGamesList(
                            kidData['favorite_games'] ?? []),

                        // Personalized Recommendations
                        _buildSectionTitle("Recommended for You"),
                        _buildRecommendationsList(
                            kidData['recommendations'] ?? []),
                      ],
                    ),
                  ),
                ),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        auth.signOut();
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: Colors.red.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for Section Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Goals Button
  Widget _buildGoalsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KidGoalScreen(kidData: kidData),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.4),
        ),
        child: const Text("View Goals"),
      ),
    );
  }

  // Widget for Badge List
  Widget _buildBadgeList(List<dynamic> badges) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: badges.map((badge) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade800, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Chip(
            label: Text(
              badge['title'] ?? "Unknown Badge",
              style: const TextStyle(color: Colors.white),
            ),
            avatar: const Icon(Icons.star, color: Colors.amber),
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  // Widget for Progress Bar
  Widget _buildProgressBar(String subject, int progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "$progress%",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.grey.shade800,
                ),
                FractionallySizedBox(
                  widthFactor: progress / 100,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.blue.shade600],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Widget for Recent Activities
  Widget _buildRecentActivities(List<dynamic> activities) {
    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            title: Text(
              activity['description'] ?? "Unknown Activity",
              style: const TextStyle(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget for Rewards List
  Widget _buildRewardsList(List<dynamic> rewards) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: rewards.map((reward) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade800.withOpacity(0.6),
                Colors.orange.shade900.withOpacity(0.6)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Chip(
            label: Text(
              reward['name'] ?? "Unknown Reward",
              style: const TextStyle(color: Colors.white),
            ),
            avatar: const Icon(Icons.emoji_events, color: Colors.amber),
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  // Widget for Favorite Games
  Widget _buildFavoriteGamesList(List<dynamic> games) {
    return Column(
      children: games.map((game) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videogame_asset, color: Colors.purple),
            ),
            title: Text(
              game['title'] ?? "Unknown Game",
              style: const TextStyle(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget for Recommendations
  Widget _buildRecommendationsList(List<dynamic> recommendations) {
    return Column(
      children: recommendations.map((rec) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb, color: Colors.amber),
            ),
            title: Text(
              rec['name'] ?? "Unknown Recommendation",
              style: const TextStyle(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        );
      }).toList(),
    );
  }
}
