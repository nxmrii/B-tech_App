import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rooms_btechapp/screens/LoginPage.dart';
import 'package:rooms_btechapp/thems/mytheme.dart';


void main() async{

  //ensures that Flutter binding is initialized before using any plugins.
  WidgetsFlutterBinding.ensureInitialized();
  //initializes the Firebase app with specific options
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAJCQpMU8CVk2Q91N-xZ9gJ13P9_FEVQJ0',
          appId: '1:646444349414:android:e76b442891d221fe538827',
          messagingSenderId: '646444349414',
          projectId: 'roomsoflight-ec608',
          storageBucket: "roomsoflight-ec608.appspot.com", ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme, // Applying lightMode theme
      home: const HomePage(), // Set HomePage as the initial screen

    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                padding: EdgeInsets.symmetric(vertical:30),
                child: Column(
                  children: [
                    // Welcome message
                    Text(
                      "Welcome!",
                      style: TextStyle(
                        color: Color(0xff074159),
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // this is for blue area
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(72),
                  topRight: Radius.circular(72),
                ),

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight : MediaQuery.of(context).size.height * 0.9,
                    //maxWidth: double.infinity,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    color: Theme.of(context).colorScheme.tertiary,
                    child: Column(children: [
                      Image.asset("assets/logox.png",
                        height: 250,
                        width: 330,),

                      const SizedBox(height: 10),
                      // Continue Button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to login page or perform desired action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child:  Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 70),
                            child: Text(
                              'Continue',
                              style: TextStyle(fontSize: 20,
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

                      SizedBox(height: 10), // Adding some space

                    ],),
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
