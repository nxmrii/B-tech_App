import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rooms_btechapp/screens/LeaderHomePage.dart';
import 'package:rooms_btechapp/screens/LeaderProfilePage.dart';

class AddVoluntaryPage extends StatefulWidget {
  const AddVoluntaryPage({super.key});

  @override
  State<AddVoluntaryPage> createState() => _AddVoluntaryPageState();
}

class _AddVoluntaryPageState extends State<AddVoluntaryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  File? _image;
  int currentPageIndex = 1;
  String? _documentId;
  String? _imageUrl;

// pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {  //checks if the form is valid , it ensure that all fields are filled
      String? imageUrl;

      // Check if an image has been selected
      if (_image != null) {
        try {
          final userId = "Ofb0VIxmpDan1BbpljhfpS3qO9t1";
          final storageRef = FirebaseStorage.instance.ref();
          final fileName = _image!.path.split("/").last;
          final timestamp = DateTime.now().microsecondsSinceEpoch;
          final uploadRef = storageRef.child("$userId/volunteerImage/$timestamp-$fileName");

          // Upload the file to Firebase Storage
          await uploadRef.putFile(_image!);

          // Get the image URL from Firebase Storage
          imageUrl = await uploadRef.getDownloadURL();
          print('Image uploaded successfully: $imageUrl');
        } catch (e) {
          print('Failed to upload image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
          return; // Exit early if upload fails
        }
      } else {
        print('No image selected');
      }

      try {
        // Add the document to Firestore
        await FirebaseFirestore.instance.collection('volunteer').add({
          'name': _nameController.text,
          'link': _linkController.text,
          'imageUrl': imageUrl ?? '', // Provide an empty string if imageUrl is null
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voluntary initiative added successfully!')),
        );

        // Clear the form after submission
        _nameController.clear();
        _linkController.clear();
        setState(() {
          _image = null;
        });

      } catch (e) {
        print('Failed to add initiative: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add initiative: $e')),
        );
      }
    }
  }


  Future<String?> _uploadImage() async {
    if (_image != null) {
      try {
        final userId = "Ofb0VIxmpDan1BbpljhfpS3qO9t1";
        final storageRef = FirebaseStorage.instance.ref();
        final fileName = _image!.path.split("/").last;
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final uploadRef = storageRef.child("$userId/volunteerImage/$timestamp-$fileName");

        await uploadRef.putFile(_image!);
        return await uploadRef.getDownloadURL();
      } catch (e) {
        print('Failed to upload image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
    return null;
  }

  Future<void> _deleteRecord() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('volunteer')
            .where('name', isEqualTo: name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final document = querySnapshot.docs.first;

          // Delete the document from Firestore
          await document.reference.delete();

          // Clear the form fields after successful deletion
          _nameController.clear();
          _linkController.clear();
          setState(() {
            _image = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Record deleted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Record not found!')),
          );
        }
      } catch (e) {
        print('Failed to delete record: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete record: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name to delete')),
      );
    }
  }

  Future<void> _searchRecord() async {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('volunteer')
            .where('name', isEqualTo: name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final document = querySnapshot.docs.first;
          _documentId = document.id; // Store the document ID

          _linkController.text = document['link'] ?? '';
          setState(() {
            _imageUrl = document['imageUrl'];
            _image = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Record found! You can now update the fields.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No record found with that name.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retrieve record: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name to search')),
      );
    }
  }

  Future<void> _updateRecord() async {
    if (_documentId != null) {
      try {
        final docRef = FirebaseFirestore.instance.collection('volunteer').doc(_documentId);

        Map<String, dynamic> updatedData = {
          'name': _nameController.text.trim(),
          'link': _linkController.text.trim(),
        };

        if (_image != null) {
          final imageUrl = await _uploadImage();
          updatedData['imageUrl'] = imageUrl;
        }

        await docRef.update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record updated successfully!')),
        );

        _nameController.clear();
        _linkController.clear();
        setState(() {
          _image = null;
          _imageUrl = null;
          _documentId = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update record: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No record selected to update')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFA5CCDB), // Blue color
                  Colors.white,      // White color
                  Color(0xFFFF5E2D2), // Orange color
                ],
                stops: [0.0, 0.6, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Text(
                  'Add Voluntary Initiatives',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0C4E68),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Color(0xFFC7E2ED),
                                backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                                child: _image == null
                                    ? Icon(Icons.add_photo_alternate, size: 50, color: Color(0xff8CBCD6),)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Name of Voluntary Initiatives',
                                labelStyle: TextStyle(
                                  color: Color(0xff7AA0D8),
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Color(0xffFFFEAD4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  color: Color(0xff40ADD9),
                                  onPressed: _searchRecord,
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the name of the initiative';
                                }
                                return null;
                              },
                            ),


                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _linkController,
                              decoration: InputDecoration(
                                labelText: 'Link of Website Or App',
                                labelStyle: TextStyle(
                                  color: Color(0xff7AA0D8),
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Color(0xffFFFEAD4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the link';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _submitForm,
                                  child: Icon(Icons.send),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Color(0xff40ADD9),
                                    backgroundColor: Colors.white,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              height: 80, // Set the desired height
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
                          MaterialPageRoute(builder: (context) => const LeaderHomePage()),
                        );
                        break;
                      case 1:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AddVoluntaryPage()),
                        );
                        break;
                      case 2:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LeaderProfilePage()),
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
          ),

          //  (delete and update)
          Positioned(
            bottom: 150, // Adjust this value to fit your design
            right: 15,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _deleteRecord,
                  child: Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFF40ADD9),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateRecord,
                  child: Icon(Icons.update),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF40ADD9),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}