import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooms_btechapp/screens/%D9%90AddMuftiNumbPage.dart';
import 'package:rooms_btechapp/screens/AddHajAndUmrahPage.dart';
import 'package:rooms_btechapp/screens/AddLecturesPage.dart';
import 'package:rooms_btechapp/screens/AddVoluntaryPage.dart';
import 'package:rooms_btechapp/screens/LeaderProfilePage.dart';

class LeaderHomePage extends StatefulWidget {
  const LeaderHomePage({super.key});

  @override
  State<LeaderHomePage> createState() => _LeaderHomePageState();
}

class _LeaderHomePageState extends State<LeaderHomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String? leaderName;
  bool isLoading = true;
  int currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchLeaderName();
  }

  Future<void> fetchLeaderName() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('leader')
            .doc(currentUser!.uid)
            .get();
        setState(() {
          leaderName = documentSnapshot.get('name');
          isLoading = false;
        });
      } catch (e) {
        // Handle the error here
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFA5CCDB), // Blue color
            Colors.white,      // White color
            Color(0xFFFF5E2D2), // Orange color
          ],
          stops: [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.center,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LeaderProfilePage()),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Add space above the greeting text
              if (isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  'Good Day, ${leaderName ?? 'Leader'}!',
                  style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0C4E68)
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildGridItem(
                      imagePath: 'assets/volunt.png',
                      label: 'Add Voluntary initiatives',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AddVoluntaryPage()),
                        );
                      },
                    ),
                    _buildGridItem(
                      imagePath: 'assets/muft.png',
                      label: 'Add Muftis Numbers',
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AddMuftiNumberPage()),
                        );
                      },
                    ),
                    _buildGridItem(
                      imagePath: 'assets/hajandumr.png',
                      label: 'Add Hajj and Umrah Campaigns',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AddHajAndUmrahPage()),
                        );
                      },
                    ),
                    _buildGridItem(
                      imagePath: 'assets/lect.png',
                      label: 'Add Lectures',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AddLecturesPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({required String imagePath, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF7EC3D9), // Blue color
            radius: 50,
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: 90,
                height: 90,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff3E6FBE),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
