import 'package:flutter/material.dart';
import 'package:smartseed/components/goal_screen.dart';
import 'package:smartseed/components/parent_dashboard_screen.dart';
import 'package:smartseed/components/kid_list_report_screen.dart';
import 'package:smartseed/service/auth/authService.dart';

class MainParent extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MainParent({required this.userData, super.key});

  @override
  State<MainParent> createState() => _MainParentState();
}

class _MainParentState extends State<MainParent> {
  final AuthService _auth = AuthService();
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  final List<Widget> _pages = []; // Store pages here

  @override
  void initState() {
    super.initState();
    // Initialize pages once
    _pages.addAll([
      GoalScreen(userData: widget.userData, auth: _auth),
      DashboardPage(userData: widget.userData, auth: _auth),
      ReportPage(userData: widget.userData, auth: _auth),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index); // No animation to prevent rebuilds
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages, // Use pre-built pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Goals"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Reports"),
        ],
      ),
    );
  }
}
