import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rooms_btechapp/screens/profilePage.dart';
import '../controller/email_controller.dart';
import 'LoginPage.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            content: Text('New password and confirm password do not match'),
          );
        },
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        String userId = user.uid;

        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: _currentPasswordController.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(_newPasswordController.text.trim());

        // Fetch the user name from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        String userName = userDoc['name'] ?? 'User';

        // Send email notification to the user's email
        await ResetEmailController.sendPasswordResetEmail(
          email: email,
          userName: userName,
        );

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.green,
              content: Text('Password has been successfully updated!'),
            );
          },
        );

        // Sign out the user
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            content: Text(e.message.toString()),
          );
        },
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Row(
                  children: [
                    Text(
                      "Reset Password!",
                      style: TextStyle(
                        color: Color(0xff074159),
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 9),

              // this is for blue area
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
                        const SizedBox(height: 80),
                        Text(
                          'Enter your current password and new password to reset it',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Current Password Text Field
                        SizedBox(
                          width: 350,
                          height: 60,
                          child: TextField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              hintText: "Current Password",
                              hintStyle: const TextStyle(
                                color: Colors.black12,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              fillColor: Theme.of(context).colorScheme.inversePrimary,
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),

                        // New Password Text Field
                        SizedBox(
                          width: 350,
                          height: 60,
                          child: TextField(
                            controller: _newPasswordController,
                            obscureText: true,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              hintText: "New Password",
                              hintStyle: const TextStyle(
                                color: Colors.black12,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              fillColor: Theme.of(context).colorScheme.inversePrimary,
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),

                        // Confirm Password Text Field
                        SizedBox(
                          width: 350,
                          height: 60,
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              hintText: "Confirm Password",
                              hintStyle: const TextStyle(
                                color: Colors.black12,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              fillColor: Theme.of(context).colorScheme.inversePrimary,
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),

                        // Reset Password Button
                        ElevatedButton(
                          onPressed: resetPassword,
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
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
                        const SizedBox(height: 20),

                        // Back to login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Back to ",
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
                                    builder: (context) {
                                      return LoginPage();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                ' Login',
                                style: TextStyle(
                                  color: Color(0xff074159),
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
    );
  }
}
