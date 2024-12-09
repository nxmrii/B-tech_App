import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rooms_btechapp/screens/LoginPage.dart';
import 'RegisterPage.dart';

//stateful >> overall structure for the page.
class forgotPassPage extends StatefulWidget {
  const forgotPassPage({Key? key}) : super(key: key);

  @override
  State<forgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<forgotPassPage> {
  final TextEditingController _emailController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  //This method sends a password reset email using FirebaseAuth.
  Future<void> forgetpassword() async {
    try {
      // Check if the user exists in Firestore
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();
      if (userSnapshot.docs.isNotEmpty) {
        // User exists, send password reset email
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.green,
                content: Text('Password reset link sent! Check your email.'),
              );
            }
        );
      } else {
        // User not found
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.red,
                content: Text('No user found for that email!'),
              );
            }
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          }
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
                      "Forget Password!",
                      style: TextStyle(
                        color: Color(0xff074159),
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                          'Enter your Email and we will send you a link to change your password',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Email Text Field
                        SizedBox(
                          width: 350,
                          height: 60,
                          child: TextField(
                            controller: _emailController,
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
                              hintText: "Email",
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

                        // Next Button
                        ElevatedButton(
                          onPressed: forgetpassword,
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'sent',
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

                        // Create new account >> Move to Register Page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Back to login",
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
                                      return  LoginPage();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                "  Login",
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
    );
  }
}
