import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

import 'LeaderHomePage.dart';
import 'LoginPage.dart';
import 'ResetPassPage.dart';

class LeaderProfilePage extends StatefulWidget {
  const LeaderProfilePage({Key? key}) : super(key: key);

  @override
  State<LeaderProfilePage> createState() => _LeaderProfilePageState();
}

class _LeaderProfilePageState extends State<LeaderProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> leaderDocument;
  String selectedPage = '';
  String leaderName = 'No name'; // Default value for leaderName
  String leaderPhotoUrl = ''; // Default value for leader photo URL

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      leaderDocument = FirebaseFirestore.instance.collection('leader').doc(currentUser!.uid).get();
    }
  }

  void _showEditProfileDialog() {
    final _nameController = TextEditingController(text: leaderName); // Pre-fill with current leaderName

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff7EC3D9),
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: Color(0xff0C4E68),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(
                color: Color(0xff0C4E68),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('leader').doc(currentUser!.uid).update({
                    'name': _nameController.text,
                  });

                  setState(() {
                    leaderName = _nameController.text; // Update local state
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated')),
                  );

                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name cannot be empty')),
                  );
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Use gallery for photo selection

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload image to Firebase Storage
      try {
        final storageRef = FirebaseStorage.instance.ref().child('profile_photos/${currentUser!.uid}');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update leader's profile photo URL in Firestore
        await FirebaseFirestore.instance.collection('leader').doc(currentUser!.uid).update({
          'photoUrl': downloadUrl,
        });

        setState(() {
          leaderPhotoUrl = downloadUrl; // Update local state
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile photo updated')),
        );
      } catch (e) {
        print('Error uploading photo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile photo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LeaderHomePage()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.black38, size: 30),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer(); // Open the drawer
              },
            ),
          ],
          centerTitle: true,
        ),
        drawer: Drawer(
          backgroundColor: Color(0xff63D2FE),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xffB0E7FD),
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Color(0xff4270B5),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.language, size: 30),
                title: Text(
                  'Language',
                  style: TextStyle(
                    color: Color(0xff0C4E68),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedPage = 'changeLanguage';
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.help, size: 30),
                title: Text(
                  'Help',
                  style: TextStyle(
                    color: Color(0xff0C4E68),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedPage = 'help';
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.key, size: 30),
                title: Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Color(0xff0C4E68),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout_outlined, size: 30),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xff0C4E68),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    child: FutureBuilder<DocumentSnapshot>(
    future: leaderDocument,
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
    return Center(child: Text('Error fetching leader data'));
    }
    if (!snapshot.hasData || !snapshot.data!.exists) {
    return Center(child: Text('Leader data not found'));
    }

    Map<String, dynamic> leaderData = snapshot.data!.data() as Map<String, dynamic>;
    leaderName = leaderData['name'] ?? 'No name';
    leaderPhotoUrl = leaderData['photoUrl'] ?? 'https://www.seekpng.com/png/detail/245-2454602_tanni-chand-default-user-image-png.png'; // Default photo URL

    return Column(
    children: [
    Row(
    children: [
    Stack(
    children: [
    CircleAvatar(
    radius: 60,
    backgroundImage: NetworkImage(leaderPhotoUrl), // Use the leaderPhotoUrl
    ),
    Positioned(
    bottom: -8,
    left: 70,
    child: IconButton(
    onPressed: () {
    _changeProfilePhoto(); // Change profile photo
    },
    icon: Icon(Icons.add_a_photo),
    color: Colors.black,
    ),
    ),
    ],
    ),
    Expanded(
    child: Column(
    children: [
    Text(
    leaderName,
    style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xff0C4E68),
    ),
    ),
    ElevatedButton(
    onPressed: () {
    _showEditProfileDialog();
    },
    child: Text(
    'Edit Profile',
      style: TextStyle(fontSize: 20, color: Color(0xff4270B5)),
    ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        backgroundColor: Colors.white,
      ),
    ),
    ],
    ),
    ),
    ],
    ),
    ],
    );
    },
    ),
        ),
    );
  }
}
