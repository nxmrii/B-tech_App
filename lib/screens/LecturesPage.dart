import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooms_btechapp/screens/HomePage.dart';
import 'package:rooms_btechapp/screens/profilePage.dart';
import 'package:rooms_btechapp/widget/map_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class LecturesPage extends StatefulWidget {
  const LecturesPage({Key? key}) : super(key: key);

  @override
  _LecturesPageState createState() => _LecturesPageState();
}

class _LecturesPageState extends State<LecturesPage>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 1;
  late TabController _tabController;
  String searchQuery = '';
  String? lecture;

  // Method to check if device is online
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false; // If no internet connection
    }
  }






  Future<void> _handleJoin(String link, String location) async {
    bool online = await isOnline();

      // Open the online link as before
        try {
          final Uri url = Uri.parse(link);
          if (await canLaunch(url.toString())) {
            await launch(url.toString());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not open the Google Meet link")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }




  void _showLocation(String location, String link) {
    if (location == "Offline") {
      final regex = RegExp(r"Lat:\s*([\d\.\-]+),\s*Lng:\s*([\d\.\-]+)");
      final match = regex.firstMatch(link);
      if (match != null) {
        final double latitude = double.parse(match.group(1)!);
        final double longitude = double.parse(match.group(2)!);

        // Navigate to the map screen with the selected coordinates
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              initialLocation: LatLng(latitude, longitude),
              onLocationSelected: (selectedLocation) {
                // Handle the selected location here
                print("Selected location: $selectedLocation");
              },
            ),
          ),
        );
      }
    } else {
      print("Location: $location");
    }
  }


// Function to add or update a user's rating for a lecture
  void _saveRating(double rating, String lectureDocId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to rate.')),
      );
      return;
    }

    final lectureRef = FirebaseFirestore.instance.collection('Lectures').doc(lectureDocId);

    // Fetch the existing ratings
    final snapshot = await lectureRef.get();

    // Check if the document exists and if the 'ratings' field exists
    if (!snapshot.exists || !snapshot.data()!.containsKey('ratings')) {
      // If the 'ratings' field does not exist, create it with the initial rating
      await lectureRef.set({
        'ratings': [{'rating': rating, 'uid': userId}]
      }, SetOptions(merge: true));
    } else {
      // If the 'ratings' field exists, proceed with the logic to update or add a new rating
      final List<dynamic> ratings = snapshot['ratings'];

      // Check if the user has already rated this lecture
      bool userHasRated = false;
      for (var ratingEntry in ratings) {
        if (ratingEntry['uid'] == userId) {
          ratingEntry['rating'] = rating; // Update the existing rating
          userHasRated = true;
          break;
        }
      }

      // If the user has already rated, update the ratings list
      if (userHasRated) {
        await lectureRef.update({
          'ratings': ratings,
        });
      } else {
        // If the user hasn't rated yet, add a new rating entry
        await lectureRef.update({
          'ratings': FieldValue.arrayUnion([{'rating': rating, 'uid': userId}]),
        });
      }
    }
  }




// Function to calculate the average rating
  Future<double> _calculateAverageRating(String lectureId) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('Lectures').doc(lectureId).get();

    if (docSnapshot.exists && docSnapshot.data()!.containsKey('ratings')) {
      List<dynamic> ratings = docSnapshot['ratings'];
      if (ratings.isNotEmpty) {
        double sum = ratings.fold(0, (previousValue, rating) => previousValue + rating);
        return (sum / ratings.length) * 4;
      }
    }

    // Return 0 if there are no ratings or if the field does not exist
    return 0.0;
  }



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // To update UI when a tab is selected
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button, title, and search bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFF7EE),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Lectures',
                        style: TextStyle(
                          color: Color(0xff0C4E68),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Search bar
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by subject',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          prefixIconColor: Colors.cyan,
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          ) : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TabBar(
                controller: _tabController,
                labelPadding: const EdgeInsets.symmetric(horizontal: 1),
                labelColor: const Color(0xff0C4E68),
                unselectedLabelColor: const Color(0xff0C4E68),
                tabs: [
                  _buildTabButton('Duaa', 0),
                  _buildTabButton('Tilawah', 1),
                  _buildTabButton('Tadabor', 2),
                  _buildTabButton('Hifd', 3),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab bar view for displaying content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLectureList('Duaa'), // Duaa Tab
                  _buildLectureList('Tilawah'), // Tilawah Tab
                  _buildLectureList('Tadabor'), // Tadabor Tab
                  _buildLectureList('Hifd'), // Hifd Tab
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
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
                    MaterialPageRoute(builder: (context) => const LecturesPage()),
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
                icon: Icon(Icons.blur_circular_outlined, size: 30),
                label: '',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person_2_rounded),
                icon: Icon(Icons.person_2_outlined, size: 30),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a tab as a button
  Widget _buildTabButton(String title, int index) {
    bool isSelected = _tabController.index == index;
    return Tab(
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isSelected ? const Color(0xff1B93C5) : const Color(0xff0C4E68),
        ),
      ),
    );
  }

  // method for list of lectures
  Widget _buildLectureList(String lectureType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Lectures')
          .where('type', isEqualTo: lectureType)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lectureDocs = snapshot.data!.docs.where((doc) {
          final subject = doc['subject'].toString().toLowerCase();
          return subject.contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: lectureDocs.length,
          itemBuilder: (context, index) {
            final lecture = lectureDocs[index];

            return FutureBuilder<double>(
              future: _calculateAverageRating(lecture.id),
              builder: (context, ratingSnapshot) {
                double initialRating = ratingSnapshot.data ?? 0.0;

                return _buildLectureCard(
                  subject: lecture['subject'],
                  lecturer: lecture['lecturer_Name'],
                  time: lecture['lecture_time'],
                  date: lecture['Lecture_date'],
                  location: lecture['location'],
                  link: lecture['link'],
                  backgroundColor: _getCardColor(lectureType),
                  initialRating: initialRating,
                  lectureId: lecture.id,
                );
              },
            );
          },
        );
      },
    );
  }


// method for lecture card with dynamic color
  Widget _buildLectureCard({
    required String subject,
    required String lecturer,
    required String time,
    required String date,
    required String location,
    required String link,
    required Color backgroundColor,
    double? initialRating,
    required String lectureId, // Add this parameter
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subject: $subject",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0C4E68),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Lecturer: $lecturer",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xff0C4E68),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "$time\n$date",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xff0D7FAE),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            location,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xff0D7FAE),
            ),
          ),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: initialRating ?? 0.0,  // Replace with the initial rating
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Color(0xff0C4E68),
            ),
            onRatingUpdate: (rating) {
              _saveRating(rating, lectureId);  // Use lecture's document ID to save the rating
            },
          ),





          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _handleJoin(link, location);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0C4E68),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Join',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

//method to get card color based on lecture type
  Color _getCardColor(String lectureType) {
    switch (lectureType) {
      case 'Duaa':
        return const Color(0xffAEDAC4);
      case 'Tilawah':
        return const Color(0xffE2E2FF);
      case 'Tadabor':
        return const Color(0xffF4D2D7);
      case 'Hifd':
        return const Color(0xffBBDEFB);
      default:
        return const Color(0xffE0F7FA);
    }
  }
}