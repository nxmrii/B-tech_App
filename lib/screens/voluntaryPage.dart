import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooms_btechapp/screens/profilePage.dart';
import 'HomePage.dart';

class VoluntaryInitiativesPage extends StatefulWidget {
  const VoluntaryInitiativesPage({Key? key}) : super(key: key);

  @override
  _VoluntaryInitiativesPageState createState() => _VoluntaryInitiativesPageState();
}

class _VoluntaryInitiativesPageState extends State<VoluntaryInitiativesPage> {
  int currentPageIndex = 1;

  Future<void> _launchUrl(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color(0xffFDE9D2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Voluntary Initiatives',
                    style: TextStyle(
                      color: Color(0xff0C4E68),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal list of cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('volunteer').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No initiatives available.'));
                    }

                    final initiatives = snapshot.data!.docs;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (initiatives.length / 3).ceil(), // Number of rows
                      itemBuilder: (context, rowIndex) {
                        return Row(
                          children: List.generate(3, (columnIndex) {
                            final index = rowIndex * 3 + columnIndex;
                            if (index >= initiatives.length) {
                              return SizedBox(width: 16); // Space for empty cards
                            }
                            final initiative = initiatives[index].data() as Map<String, dynamic>;
                            return _buildInitiativeCard(
                              context,
                              imagePath: initiative['imageUrl'],
                              label: initiative['name'],
                              link: initiative['link'],
                            );
                          }),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(70),
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
                    MaterialPageRoute(builder: (context) => const VoluntaryInitiativesPage()),
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
                icon: Icon(Icons.home_outlined, size: 30,),
                label: '',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.blur_circular),
                icon: Icon(Icons.blur_circular_outlined, size: 30,),
                label: '',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person_2_rounded),
                icon: Icon(Icons.person_2_outlined, size: 30,),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitiativeCard(BuildContext context, {required String imagePath, required String label, required String link}) {
    return GestureDetector(
      onTap: () {
        _launchUrl(link);
      },

        child: Container(
        width: (MediaQuery.of(context).size.width) / 1.9,
       height: MediaQuery.of(context).size.height / 3,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          color: Colors.white,
          elevation: 1.5,

          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 200,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      imagePath.isNotEmpty
                          ? Image.network(
                        imagePath,
                        height: 90,
                      )
                          : Icon(Icons.image, size: 120, color: Colors.grey),
                      const SizedBox(height: 40),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xff0C4E68),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
