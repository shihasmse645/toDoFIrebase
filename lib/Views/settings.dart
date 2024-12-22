import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d5ntest/FirebaseHelper/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userName;
  final authController = Get.put(AuthService());

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? uid = sharedPreferences.getString('uid');
      print("User id is $uid");

      if (uid != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        setState(() {
          userName =
              userDoc['fullName']; // Assuming "fullName" is the field name
        });
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Back Arrow
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 48), // Adjust spacing for center alignment
                ],
              ),

              const SizedBox(height: 20),

              // User Info ListTile
              ListTile(
                leading: const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.person, size: 30),
                ),
                title: Text(
                  userName ?? 'Loading...', // Display user name or loading
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Handle edit button action
                  },
                ),
              ),

              const Divider(),

              // Settings List
              Expanded(
                child: ListView(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Notifications'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('General'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text('Account'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('About'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        authController.signout(context: context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
