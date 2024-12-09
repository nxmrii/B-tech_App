import 'package:flutter/material.dart';
import 'package:rooms_btechapp/screens/HajjAndUmrahPage.dart';
import 'package:rooms_btechapp/screens/LecturesPage.dart';
import 'package:rooms_btechapp/screens/MuftisPage.dart';
import 'package:rooms_btechapp/screens/profilePage.dart';
import 'package:rooms_btechapp/screens/voluntaryPage.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff011C27),
      body: Stack(
        children: [
          // Background Image
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Image.asset(
              "assets/home.jpg",
              height: 606,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Image Section
                  Stack(
                    children: [
                      Container(
                        height: 260,
                        width: 360,
                        decoration: BoxDecoration(

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
                    ],
                  ),

                  SizedBox(height: 200),


                  // Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 140.0, horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCategoryItem(
                              context,
                              imagePath: 'assets/volunteer.png',
                              label: 'Voluntary\ninitiatives',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VoluntaryInitiativesPage(),
                                  ),
                                );
                              },
                            ),
                            _buildCategoryItem(
                              context,
                              imagePath: 'assets/mufties.png',
                              label: 'Muftis',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MuftisPage()),
                                );
                              },
                            ),
                            _buildCategoryItem(
                              context,
                              imagePath: 'assets/hajj.png',
                              label: 'Hajj and Umrah\ncampaigns',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HajjAndUmrahPage()),
                                );
                              },
                            ),
                            _buildCategoryItem(
                              context,
                              imagePath: 'assets/lectures.png', // Replace with your image path
                              label: 'Lectures',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LecturesPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, {required String imagePath, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 37,
            backgroundColor: Color(0xffFDE9D2),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: 70,
                height: 70,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}