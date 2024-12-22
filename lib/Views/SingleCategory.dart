import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:intl/intl.dart';

class CategoryTasksPage extends StatelessWidget {
  final String categoryId; // ID of the category
  final String categoryTitle; // Title of the category

  CategoryTasksPage({required this.categoryId, required this.categoryTitle});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Top Row
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    categoryTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Search functionality
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tasks = snapshot.data?.docs ?? [];

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Group tasks by Today, Yesterday, or Date
                  final groupedTasks = _groupTasksByDate(tasks);

                  return ListView.builder(
                    itemCount: groupedTasks.keys.length,
                    itemBuilder: (context, index) {
                      final date = groupedTasks.keys.toList()[index];
                      final taskList = groupedTasks[date]!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Header for grouped tasks
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Task List for that date
                            ...taskList.map((task) {
                              final taskName = task['name'] ?? 'Unnamed Task';

                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5.0, left: 8.0),
                                child: Row(
                                  children: [
                                    RoundCheckBox(
                                      size: 25,
                                      isChecked: task['status'],
                                      onTap: (selected) async {
                                        final userId = _auth.currentUser?.uid;
                                        if (userId != null) {
                                          await FirebaseFirestore.instance
                                              .collection('todos')
                                              .doc(userId)
                                              .collection('tasks')
                                              .doc(categoryId)
                                              .collection('taskList')
                                              .doc(task.id)
                                              .update({
                                            'status': selected,
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Spacing between checkbox and text
                                    Text(
                                      taskName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: task['status']
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        decoration: task['status']
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddTaskDialog(context);
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
          shape: CircleBorder(),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getTasksStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('todos')
        .doc(userId)
        .collection('tasks')
        .doc(categoryId)
        .collection('taskList')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Map<String, List<QueryDocumentSnapshot>> _groupTasksByDate(
      List<QueryDocumentSnapshot> tasks) {
    final Map<String, List<QueryDocumentSnapshot>> groupedTasks = {};
    final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final yesterdayDate = DateFormat('dd/MM/yyyy')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    for (var task in tasks) {
      final timestamp = task['createdAt'] as Timestamp?;
      final taskDate = timestamp != null
          ? DateFormat('dd/MM/yyyy').format(timestamp.toDate())
          : 'Unknown';

      String displayDate;
      if (taskDate == currentDate) {
        displayDate = 'Today';
      } else if (taskDate == yesterdayDate) {
        displayDate = 'Yesterday';
      } else {
        displayDate = taskDate;
      }

      if (groupedTasks.containsKey(displayDate)) {
        groupedTasks[displayDate]!.add(task);
      } else {
        groupedTasks[displayDate] = [task];
      }
    }

    return groupedTasks;
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final String taskName = taskController.text;
                if (taskName.isNotEmpty) {
                  final userId = _auth.currentUser?.uid;
                  if (userId != null) {
                    await FirebaseFirestore.instance
                        .collection('todos')
                        .doc(userId)
                        .collection('tasks')
                        .doc(categoryId)
                        .collection('taskList')
                        .add({
                      'name': taskName,
                      'status': false,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
