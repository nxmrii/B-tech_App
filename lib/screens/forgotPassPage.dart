import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RegisterPage.dart';

class forgotPassPage extends StatefulWidget {
  const forgotPassPage({Key? key}) : super(key: key);

  @override
  State<forgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<forgotPassPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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
                          'Enter your Email or Phone Number and we will send you a link to change your password',
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
                          onPressed: _resetPassword,
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Next',
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
                                    builder: (context) {
                                      return  RegisterPage();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
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
    );
  }
}
