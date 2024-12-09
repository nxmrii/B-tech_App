import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/widgets.dart';
import '../controller/email_controller.dart';
import 'LoginPage.dart';





class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // for validations
  final _formKey = GlobalKey<FormState>();

  // this is style for the TextFormFields
  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.lightBlue),
        borderRadius: BorderRadius.circular(30),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(30),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(30),
      ),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.black12,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      fillColor: Theme.of(context).colorScheme.inversePrimary,
      filled: true,
    );
  }

  // Initial value for user type radio button
  String _userType = 'user';


  // Register user if authentication is successful
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_userType == 'leader') {
        EmailController.sendEmail(
          email: _emailController.text,
          name: _nameController.text,
        );
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String encryptedPassword = encryptPassword(_passwordController.text);

        await FirebaseFirestore.instance
            .collection(_userType == 'leader' ? 'leader' : 'users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text,
          'name': _nameController.text,
          'password': encryptedPassword,
          'userType': _userType,
          'trust': _userType == 'leader' ? false : true,
        });

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        Navigator.pop(context);
        _showSnackBar('An unexpected error occurred: $e');
      }
    }
  }

  // Function to show snack bar messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Method to encrypt the password
  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 chars
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Row(
                  children: [
                    Text(
                      "Register",
                      style: TextStyle(
                        color: Color(0xff074159),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                //for blue area
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                  child: Form(
                    //A key for form validation.
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: Theme.of(context).colorScheme.tertiary,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            //Name Textformfield
                            IntrinsicHeight(
                              child: SizedBox(
                                width: 350,
                                child: TextFormField(
                                  controller: _nameController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                  decoration:
                                  _inputDecoration("Name", Icons.person),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    if (value.length < 4) {
                                      return 'Name must be at least 4 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            //Email Textformfield
                            IntrinsicHeight(
                              child: SizedBox(
                                width: 350,
                                child: TextFormField(
                                  controller: _emailController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                  decoration:
                                  _inputDecoration("Email", Icons.email),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            //Password Textformfield
                            IntrinsicHeight(
                              child: SizedBox(
                                width: 350,
                                child: TextFormField(
                                  controller: _passwordController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                  obscureText: true,
                                  decoration:
                                  _inputDecoration("Password", Icons.lock),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters long';
                                    }
                                    if (!value.contains(RegExp(r'[A-Z]'))) {
                                      return 'Password must contain at least one capital letter';
                                    }
                                    if (!value.contains(
                                        RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                      return 'Password must contain at least one special character';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            //confirm pass Textformfield
                            IntrinsicHeight(
                              child: SizedBox(
                                width: 350,
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                  obscureText: true,
                                  decoration: _inputDecoration(
                                      "Confirm Password", Icons.lock_outline),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Radio buttons for user type
                            //Steps to Handle Email for Leader
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  value: 'user',
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

                            // Conditional text for leader type


                            const SizedBox(height: 8),

                            // register button
                            ElevatedButton(
                              //
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {

                                  if (_userType == 'leader') {
                                    //This method is responsible for sending the email.
                                    EmailController.sendEmail(
                                        email: _emailController.text,
                                        name: _nameController.text);
                                  }


                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  );
                                  try {
                                    UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );

                                    // Encrypt the password
                                    String encryptedPassword = encryptPassword(_passwordController.text);

                                    await FirebaseFirestore.instance
                                        .collection(_userType == 'leader'? 'leader': 'users')
                                        .doc(userCredential.user!.uid)
                                        .set({
                                      'email': _emailController.text,
                                      'name': _nameController.text,
                                      'password': encryptedPassword,
                                      'userType': _userType,
                                      'trust':_userType == 'leader'?false : true
                                    });

                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return LoginPage();
                                        },
                                      ),
                                    );
                                  } catch (e) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'An unexpected error occurred: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Center(
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                                  child:  Text(
                                    _userType == 'leader'? 'Request for leader ':
                                    'Register',
                                    style: TextStyle(
                                        fontSize: 23, color: Colors.white),
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                backgroundColor:
                                Theme.of(context).colorScheme.background,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // move to login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an Account?",
                                  style: TextStyle(
                                    color: Color(0x6b4270b5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                //GestureDetector > to click in the text
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

                            //for leader

                          ],
                        ),
                      ),
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