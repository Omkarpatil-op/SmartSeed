import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KidGoalScreen extends StatefulWidget {
  final Map<String, dynamic> kidData;

  const KidGoalScreen({super.key, required this.kidData});

  @override
  State<KidGoalScreen> createState() => _KidGoalScreenState();
}

class _KidGoalScreenState extends State<KidGoalScreen> {
  @override
  Widget build(BuildContext context) {
    var kidId = widget.kidData['kid_id'];

    // Define our theme colors
    const backgroundColor = Color(0xFF121212);
    const primaryColor = Color(0xFF2196F3);
    const foregroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Kid's Goals",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: foregroundColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.tips_and_updates, color: primaryColor),
            onPressed: () {
              // Show tips or help information
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Complete tasks to earn rewards!"),
                  backgroundColor: primaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('kid_id', isEqualTo: kidId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.task_alt,
                    size: 80,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No Tasks Available",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Goals will appear here when assigned",
                    style: TextStyle(
                      fontSize: 16,
                      color: foregroundColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          var tasks = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "My Tasks",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: foregroundColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor, width: 1),
                      ),
                      child: Text(
                        "${tasks.length} Tasks",
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Complete your tasks to achieve your goals!",
                  style: TextStyle(
                    fontSize: 14,
                    color: foregroundColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      var task = tasks[index];
                      bool isCompleted = task['isCompleted'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: backgroundColor.withOpacity(0.8),
                          border: Border.all(
                            color: isCompleted
                                ? primaryColor.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Toggle completion status on tap
                                FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(task.id)
                                    .update({'isCompleted': !isCompleted});
                              },
                              splashColor: primaryColor.withOpacity(0.1),
                              highlightColor: primaryColor.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Custom checkbox
                                    Container(
                                      height: 28,
                                      width: 28,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isCompleted
                                              ? primaryColor
                                              : primaryColor.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: isCompleted
                                          ? const Icon(
                                              Icons.check,
                                              size: 18,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task['taskName'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: foregroundColor,
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              decorationColor: primaryColor,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isCompleted
                                                ? "Completed! Great job! 🎉"
                                                : "Not completed yet",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isCompleted
                                                  ? primaryColor
                                                  : foregroundColor
                                                      .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Status indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? primaryColor.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isCompleted ? "Done" : "To Do",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted
                                              ? primaryColor
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
