import 'package:flutter/material.dart';
import 'RegisterPage.dart';

class forgotPassPage extends StatelessWidget {
  const forgotPassPage({Key? key});

  @override
  Widget build(BuildContext context){
    var mediaquery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical:30, horizontal: 30),
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
              SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(72),
                    topRight: Radius.circular(72),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight : MediaQuery.of(context).size.height * 0.9,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Column(children: [
                        SizedBox(height:80 ),
                        Text(
                          'Enter your Email or Phone Number and we will'
                              '  send you a link to change new password',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 40),

                        // Email Text Field
                        SizedBox(
                          width: 350,
                          height: 60,
                          child: TextField(
                            style: const TextStyle(fontSize: 15 , height: 1,
                                color: Colors.black),
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
                              hintStyle: TextStyle(color: Colors.black12,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                              fillColor: Theme.of(context).colorScheme.inversePrimary,
                              filled: true,
                            ),
                          ),
                        ),
                        SizedBox(height: 17),

                        // Next Button
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to Home page
                            //Navigator.push(
                            //context,
                            //MaterialPageRoute(builder: (context) => const HomePage()),
                            //);
                          },
                          child:  Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Next',
                                style: TextStyle(fontSize: 24,
                                    color: Colors.white),
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

                        // Create new account >> Move to Register Page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Create New Account?" ,
                              style: TextStyle(
                                  color: Color(0x6b4270b5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RegisterPage();
                                    },
                                  ),
                                );
                              },
                              child: const Text("  Register" ,
                                style: TextStyle(
                                    color: Color(0xff4270B5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),


                      ],),
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