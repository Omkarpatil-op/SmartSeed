import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartseed/service/auth/authService.dart';
import 'package:smartseed/service/kid_parent/kid_parent_service.dart';

class GoalScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final AuthService auth;

  const GoalScreen({
    required this.userData,
    required this.auth,
    super.key,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> kids = [];
  String? selectedKidId;
  bool isLoading = true;

  // Enhanced color palette
  final Color primaryBlue = const Color(0xFF2962FF);
  final Color darkBackground = Colors.black;
  final Color cardBackground = const Color(0xFF121212);
  final Color textColor = Colors.white;
  final Color accentColor = const Color(0xFF82B1FF);
  final Color successColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    fetchKids();
  }

  Future<void> fetchKids() async {
    String? parentId = widget.userData['parent_id'];
    if (parentId == null) return;

    List<Map<String, dynamic>> fetchedKids =
        await ParentKidService().getKidsByParentID(parentId);

    setState(() {
      kids = fetchedKids;
      if (kids.isNotEmpty) selectedKidId = kids.first['kid_id'];
      isLoading = false;
    });
  }

  /// **Updated Function to Add Task with Proper Timestamp**
  Future<void> _addTask() async {
    if (_taskController.text.isEmpty || selectedKidId == null) return;

    final task = {
      'taskName': _taskController.text.trim(),
      'parent_id': widget.userData['parent_id'],
      'kid_id': selectedKidId,
      'isCompleted': false,
      'timestamp':
          Timestamp.now(), // ✅ Explicit Timestamp.now() for consistency
    };

    try {
      await FirebaseFirestore.instance.collection('tasks').add(task);
      _taskController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: textColor),
              const SizedBox(width: 8),
              const Text('Goal added successfully!'),
            ],
          ),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
      setState(() {}); // Force UI refresh
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  Stream<QuerySnapshot> getTaskStream() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('parent_id', isEqualTo: widget.userData['parent_id'])
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Kid Goals",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 3,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    darkBackground,
                    const Color(0xFF121212),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildAddTaskSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.list_alt,
                            color: primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "All Goals",
                          style: TextStyle(
                            fontSize: 20,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: getTaskStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print("Stream Error: ${snapshot.error}");
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[300],
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Couldn't load goals",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                            ),
                          );
                        }

                        final taskData = snapshot.data?.docs ?? [];

                        if (taskData.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  color: Colors.white54,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No goals found",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Add a new goal to get started",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                            itemCount: taskData.length,
                            itemBuilder: (context, index) {
                              final doc = taskData[index];
                              final task = doc.data() as Map<String, dynamic>;

                              return FutureBuilder<String>(
                                future: _getKidName(task['kid_id'] ?? ''),
                                builder: (context, kidSnapshot) {
                                  if (kidSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _buildTaskShimmer();
                                  }

                                  return TaskItem(
                                    task: task,
                                    kidName: kidSnapshot.data ?? 'Unassigned',
                                    onToggle: (isCompleted) {
                                      FirebaseFirestore.instance
                                          .collection('tasks')
                                          .doc(doc.id)
                                          .update({'isCompleted': isCompleted});
                                    },
                                    primaryColor: primaryBlue,
                                    cardColor: cardBackground,
                                    textColor: textColor,
                                  );
                                },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: cardBackground,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            isScrollControlled: true,
            builder: (context) => _buildQuickAddTaskModal(),
          );
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickAddTaskModal() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: accentColor),
              const SizedBox(width: 8),
              Text(
                "Quick Add Goal",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedKidId,
            dropdownColor: cardBackground,
            decoration: InputDecoration(
              labelText: "Select Child",
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryBlue),
              ),
              filled: true,
              fillColor: Colors.black54,
              prefixIcon: Icon(Icons.person, color: accentColor),
            ),
            style: TextStyle(color: textColor),
            items: kids
                .map((kid) => DropdownMenuItem<String>(
                      value: kid['kid_id'],
                      child: Text(kid['first_name']),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedKidId = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _taskController,
            decoration: InputDecoration(
              labelText: "New Goal",
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryBlue),
              ),
              filled: true,
              fillColor: Colors.black54,
              prefixIcon: Icon(Icons.flag, color: accentColor),
            ),
            style: TextStyle(color: textColor),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _addTask();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_task),
                  SizedBox(width: 8),
                  Text(
                    "Add Goal",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddTaskSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: cardBackground,
      elevation: 8,
      shadowColor: primaryBlue.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: accentColor,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  "Create New Goal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedKidId,
              dropdownColor: cardBackground,
              decoration: InputDecoration(
                labelText: "Select Child",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryBlue),
                ),
                filled: true,
                fillColor: Colors.black54,
                prefixIcon: Icon(Icons.person, color: accentColor),
              ),
              style: TextStyle(color: textColor),
              items: kids
                  .map((kid) => DropdownMenuItem<String>(
                        value: kid['kid_id'],
                        child: Text(kid['first_name']),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedKidId = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: "New Goal",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryBlue),
                ),
                filled: true,
                fillColor: Colors.black54,
                prefixIcon: Icon(Icons.flag, color: accentColor),
              ),
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_task),
                    SizedBox(width: 8),
                    Text(
                      "Add Goal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getKidName(String? kidId) async {
    if (kidId == null || kidId.isEmpty) {
      return 'Unassigned Child';
    }

    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('kids').doc(kidId).get();

      if (!doc.exists || doc['first_name'] == null) {
        return 'Unknown Child';
      }

      return doc['first_name'] as String;
    } catch (e) {
      print("Error fetching kid name: $e");
      return 'Error Loading Name';
    }
  }
}

class TaskItem extends StatelessWidget {
  final Map<String, dynamic> task;
  final String kidName;
  final Function(bool) onToggle;
  final Color primaryColor;
  final Color cardColor;
  final Color textColor;

  const TaskItem({
    required this.task,
    required this.kidName,
    required this.onToggle,
    required this.primaryColor,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = task['isCompleted'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          task['taskName'] ?? 'Unnamed Task',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: const Color(0xFF4CAF50),
            decorationThickness: 2,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: primaryColor.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                "Assigned to: $kidName",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.flag_outlined,
            color: isCompleted ? const Color(0xFF4CAF50) : primaryColor,
          ),
        ),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: isCompleted,
            onChanged: (value) => onToggle(value ?? false),
            activeColor: const Color(0xFF4CAF50),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
