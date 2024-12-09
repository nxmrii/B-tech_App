import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooms_btechapp/screens/HomePage.dart';
import 'package:rooms_btechapp/screens/LeaderHomePage.dart';
import 'package:local_auth/local_auth.dart';

import 'RegisterPage.dart';
import 'forgotPassPage.dart';
import 'profilePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}//_LoginPageState >> state class for LoginPage.
class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication _localAuth = LocalAuthentication();


  @override

  //Releases resources used by the controllers when they are no longer needed.
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  String _userType = 'users';

  //    ${name} Want trust from U
  // ${email} bla bla blaa


// 1- signIn
  //2-   _usertype = "leader" >fetch col "$_usertype"  > bool trust > true? login: !login
  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Sign in with email and password using Firebase Authentication
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Check if the user exists in Firebase Authentication
        if (userCredential.user != null) {
          // Fetch user data from Firestore based on user type
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection(_userType)
              .doc(userCredential.user!.uid)
              .get();

          if (userDoc.exists) {
            // Check the 'trust' field
            bool trust = userDoc['trust'] ?? false;
            // Check the 'userType' field
            String userType = userDoc['userType'] ?? 'user'; // Default to 'user' if not set

            if (trust) {
              // Navigate to the appropriate homepage based on userType
              if (userType == 'leader') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderHomePage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            } else {
              // User is not trusted, show an error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Your account is not trusted. Please contact support.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // User document does not exist in Firestore
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User data not found. Please contact support.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'User not found. Please register.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password. Please try again.';
        } else {
          message = 'An error occurred: ${e.message}';
        }
        // Display error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> authenticateWithFingerprint() async {
    bool canAuthenticate = await _localAuth.canCheckBiometrics;
    if (canAuthenticate) {
      try {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to log in',

        );

        if (authenticated) {
          // Call signIn function after successful biometric authentication
          signIn();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error with biometric authentication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric authentication not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue),
        borderRadius: BorderRadius.circular(30),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(30),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(30),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.black12,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      fillColor: Theme.of(context).colorScheme.inversePrimary,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(fontSize: 15, height: 1, color: Colors.black),
                            decoration: _inputDecoration("Email", Icons.email),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 17),

                          // Password Text field
                          TextFormField(
                            controller: _passwordController,
                            style: TextStyle(fontSize: 15, height: 1, color: Colors.black),
                            obscureText: true,
                            decoration: _inputDecoration("Password", Icons.key),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
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

                          SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio(
                                value: 'users',
                                groupValue: _userType,
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value.toString();
                                  });
                                },
                              ),
                              Text('User'),
                              Radio(
                                value: 'leader',
                                groupValue: _userType,
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value.toString();
                                  });
                                },
                              ),
                              Text('Leader'),
                            ],
                          ),

                          SizedBox(height: 15),

                          GestureDetector(
                            onTap: authenticateWithFingerprint,  // Trigger fingerprint authentication when tapped
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Login with Fingerprint!",
                                  style: TextStyle(
                                    color: Color(0xff4270B5),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "or with Face ID!",
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),


                          SizedBox(height: 15),

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
                        ],
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
}
