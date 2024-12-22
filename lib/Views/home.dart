import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d5ntest/Views/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'SingleCategory.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 35, left: 10, right: 10, bottom: 10),
        child: Column(
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 24),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Action for search
                      },
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()));
                      },
                      icon: const Icon(Icons.settings),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // StreamBuilder to fetch tasks from Firestore
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

                  return GridView.builder(
                    itemCount: tasks.length +
                        1, // Add one extra item for the plus card
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of cards per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: () {
                            _showAddCategoryDialog(context);
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final task =
                          tasks[index - 1]; // Adjust index for the tasks list
                      final title = task['title'] ?? 'Untitled';
                      final categoryId = task.id;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoryTasksPage(
                                        categoryTitle: title,
                                        categoryId: categoryId,
                                      )));
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                StreamBuilder<int>(
                                  stream: _getTaskCount(categoryId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(
                                        'Loading...',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      );
                                    }

                                    final taskCount = snapshot.data ?? 0;
                                    return Text(
                                      '$taskCount tasks',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> _getTaskCount(String categoryId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return FirebaseFirestore.instance
        .collection('todos')
        .doc(userId)
        .collection('tasks')
        .doc(categoryId)
        .collection('taskList')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<QuerySnapshot> _getTasksStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Stream
          .empty(); // Return an empty stream if no user is logged in
    }
    return FirebaseFirestore.instance
        .collection('todos')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt',
            descending: true) // Optional: Order by creation date
        .snapshots();
  }

  // Show dialog for adding a new category
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final String title = titleController.text;
                if (title.isNotEmpty) {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    await FirebaseFirestore.instance
                        .collection('todos')
                        .doc(userId)
                        .collection('tasks')
                        .add({
                      'title': title,
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
