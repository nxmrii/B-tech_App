import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'HomePage.dart';
import 'profilePage.dart';

class HajjAndUmrahPage extends StatefulWidget {
  const HajjAndUmrahPage({Key? key}) : super(key: key);

  @override
  _HajjAndUmrahPageState createState() => _HajjAndUmrahPageState();
}

class _HajjAndUmrahPageState extends State<HajjAndUmrahPage> {
  int currentPageIndex = 1;

  void _makePhoneCall(String number) async{
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE0F7FA), // Light cyan color
                  Color(0xffFDE9D2), // White color
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Hajj & Umrah Campaigns',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0C4E68),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Hajj_Umrah').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No campaign data available.'));
                      }

                      final documents = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          final String campaignsName = doc['campaignsName'] ?? 'No name';
                          final String number = doc['number'] ?? 'No number';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            color: const Color(0xffFDE9D2), // Card color
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              title: Text(
                                campaignsName,
                                style: const TextStyle(
                                  color: Color(0xff0C4E68),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                number,
                                style: const TextStyle(color: Color(0xff0C4E68)),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone, color: Colors.red),
                                onPressed: () {
                                  _makePhoneCall(number); // Function to make a phone call
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: NavigationBar(
                  backgroundColor: const Color(0xff7AC3D9),
                  onDestinationSelected: (int index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                    // Navigate to the corresponding screen
                    switch (index) {
                      case 0:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                        break;
                      case 1:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HajjAndUmrahPage()),
                        );
                        break;
                      case 2:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                        break;
                    }
                  },
                  indicatorColor: const Color(0xffD7EEF8),
                  selectedIndex: currentPageIndex,
                  destinations: const <Widget>[
                    NavigationDestination(
                      selectedIcon: Icon(Icons.home),
                      icon: Icon(Icons.home_outlined, size: 30),
                      label: '',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.blur_circular),
                      icon: Icon(Icons.blur_circular, size: 30),
                      label: '',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.person),
                      icon: Icon(Icons.person_outline, size: 30),
                      label: '',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
