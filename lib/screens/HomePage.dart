import 'package:flutter/material.dart';


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
              height: double.infinity,
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
                        height: 250,
                        width: 330,
                        decoration: BoxDecoration(

                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 220),

                  // Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCategoryItem(
                              context,
                              icon: Icons.volunteer_activism,
                              label: 'Voluntary\ninitiatives',
                              onTap: () {
                                // Handle navigation to Voluntary initiatives
                              },
                            ),
                            _buildCategoryItem(
                              context,
                              icon: Icons.person,
                              label: 'Muftis',
                              onTap: () {
                                // Handle navigation to Muftis
                              },
                            ),
                            _buildCategoryItem(
                              context,
                              icon: Icons.hail,
                              label: 'Hajj and Umrah\ncampaigns',
                              onTap: () {
                                // Handle navigation to Hajj and Umrah campaigns
                              },
                            ),
                            _buildCategoryItem(
                              context,
                              icon: Icons.book,
                              label: 'Lectures',
                              onTap: () {
                                // Handle navigation to Lectures
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

  Widget _buildCategoryItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
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

