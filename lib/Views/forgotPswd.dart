import 'package:d5ntest/Views/createAccount.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../FirebaseHelper/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final authController = Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                        'Forgot Password',
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
              ),
              const Text(
                'Enter your email to receive a password reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: () async {
                        if (_emailController.text.isNotEmpty) {
                          AuthService().resetPassword(
                            email: _emailController.text,
                            context: context,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Please enter an email address.',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.SNACKBAR,
                          );
                        }
                        // if (_formKey.currentState!.validate()) {
                        //   String email = emailController.text.trim();
                        //   String password = passwordController.text.trim();

                        //   try {
                        //     // Call the signin method from the AuthController
                        //     await authController.signin(
                        //         email: email,
                        //         password: password,
                        //         context: context);
                        //   } catch (e) {
                        //     // Display error message in case of failure
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         content: Text(e.toString()),
                        //       ),
                        //     );
                        //   }
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 22, 101, 165),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: AuthService().loading.value
                          ? const CircularProgressIndicator()
                          : const Text('CONTINUE',
                              style: TextStyle(color: Colors.white)),
                    );
                  })),

              // ElevatedButton(
              //   onPressed: _isLoading ? null : _resetPassword,
              //   child: _isLoading
              //       ? const CircularProgressIndicator()
              //       : const Text('Reset Password'),
              // ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to register page
                      Get.to(() => CreateAccount());
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
