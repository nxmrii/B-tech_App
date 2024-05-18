import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooms_btechapp/screens/homepage.dart';

import 'RegisterPage.dart';
import 'forgotPassPage.dart';
import 'profilePage.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    try {
      // Sign in with email and password using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if the user exists in Firebase Authentication
      if (userCredential.user != null) {
        // User exists, navigate to the profile page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => homepage()),
        );
      } else {
        // User does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not found. Please register.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle sign-in errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Row(
                  children: [
                    Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Color(0xff074159),
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 9),

              // Blue area
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(72),
                  topRight: Radius.circular(72),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    color: Theme.of(context).colorScheme.tertiary,
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 40),

                        // Email Text Field
                        TextField(
                          controller: _emailController,
                          style: TextStyle(fontSize: 15, height: 1, color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: Colors.black12,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            fillColor: Theme.of(context).colorScheme.inversePrimary,
                            filled: true,
                          ),
                        ),
                        SizedBox(height: 17),

                        // Password Text field
                        TextField(
                          controller: _passwordController,
                          style: TextStyle(fontSize: 15, height: 1, color: Colors.black),
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.key, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(
                              color: Color(0xffF0F7FA),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            fillColor: Theme.of(context).colorScheme.background,
                            filled: true,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => forgotPassPage()),
                                );
                              },
                              child: Opacity(
                                opacity: 0.7,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: const Color(0xff4270B5),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

                        // Login Button
                        ElevatedButton(
                          onPressed: signIn,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Login',
                                style: TextStyle(fontSize: 24, color: Colors.white),
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.background,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Create new account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create New Account?",
                              style: TextStyle(
                                color: Color(0x6b4270b5),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "  Register",
                                style: TextStyle(
                                  color: Color(0xff4270B5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Ask for a certified volunteer Account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Implement your action here
                              },
                              child: Text(
                                "  Or Ask for a certified volunteer Account",
                                style: TextStyle(
                                  color: Color(0x6b4270b5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

