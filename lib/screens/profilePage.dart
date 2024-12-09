import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:local_auth/local_auth.dart';
import 'package:rooms_btechapp/screens/HelpCenterPage.dart';
import '../widget/faceId.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'resetPassPage.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> userDocument;
  String selectedPage = '';
  String userName = 'No name'; // Default value for userName
  String userPhotoUrl = ''; // Default value for user photo URL
  final LocalAuthentication _localAuth = LocalAuthentication(); // LocalAuth instance
  late CameraDescription camera;



  @override
  void initState() {
    super.initState();
    _initializeCamera();
    if (currentUser != null) {
      userDocument = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        setState(() {
          camera = cameras.first;
        });
      } else {
        // Handle the case where no cameras are available
        _showError('No cameras available');
      }
    } catch (e) {
      // Handle any errors during initialization
      _showError('Error initializing camera: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  void _showEditProfileDialog() {
    final _nameController = TextEditingController(text: userName); // Pre-fill with current userName

    Future<void> requestCameraPermission() async {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        // Handle permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera permission is required to use this feature.')),
        );
      }
    }

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
                  await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
                    'name': _nameController.text,
                  });

                  setState(() {
                    userName = _nameController.text; // Update local state
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

        // Update user's profile photo URL in Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
          'photoUrl': downloadUrl,
        });

        setState(() {
          userPhotoUrl = downloadUrl; // Update local state
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

  Future<void> _authenticateWithFingerprint() async {
    try {
      // Check if the device supports fingerprint authentication
      bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fingerprint authentication not available on this device')),
        );
        return;
      }

      // Check if any biometrics are enrolled
      List<BiometricType> biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No biometrics enrolled on this device')),
        );
        return;
      }

      // Authenticate with the enrolled fingerprint
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable fingerprint login',
      );

      if (authenticated) {
        // Update the Firestore document to indicate that fingerprint authentication is enabled
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
          'fingerprintEnabled': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fingerprint authentication enabled')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fingerprint authentication failed')),
        );
      }
    } catch (e) {
      print('Error during fingerprint authentication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during fingerprint authentication')),
      );
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
              MaterialPageRoute(builder: (context) => HomePage()),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpCenterPage()),
                );
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
            ListTile(
              leading: Icon(Icons.fingerprint, size: 30),
              title: Text(
                'Activate Fingerpint',
                style: TextStyle(
                  color: Color(0xff0C4E68),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _authenticateWithFingerprint,
            ),
    ListTile(
    leading: Icon(Icons.face, size: 30),
    title: Text(
    'Activate Face ID',
    style: TextStyle(
    color: Color(0xff0C4E68),
    fontSize: 19,
    fontWeight: FontWeight.bold,
    ),
    ),
    onTap: () async {
    if (camera == null) {
    // Show a message if no camera is available
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('No camera available.')),
    );
    return;
    }

    try {
    // Navigate to FaceIDScreen
    final result = await Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => FaceIDScreen(camera: camera),
    ),
    );

    // Handle the result if necessary
    if (result == true) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Face ID activated successfully!')),
    );
    } else if (result == false) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Face ID activation failed.')),
    );
    }
    } catch (e) {
    // Handle unexpected errors
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An error occurred: $e')),
    );
    }
    },
    ),


    ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: FutureBuilder<DocumentSnapshot>(
          future: userDocument,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error fetching user data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('User data not found'));
            }

            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            userName = userData['name'] ?? 'No name';
            userPhotoUrl = userData['photoUrl'] ?? 'https://www.seekpng.com/png/detail/245-2454602_tanni-chand-default-user-image-png.png'; // Default photo URL

            return Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(userPhotoUrl), // Use the userPhotoUrl
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
                            userName,
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
