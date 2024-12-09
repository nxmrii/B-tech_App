import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:rooms_btechapp/screens/LeaderHomePage.dart';
import 'package:rooms_btechapp/screens/LeaderProfilePage.dart';

class AddMuftiNumberPage extends StatefulWidget {
  const AddMuftiNumberPage({Key? key}) : super(key: key);

  @override
  _AddMuftiNumberPageState createState() => _AddMuftiNumberPageState();
}

class _AddMuftiNumberPageState extends State<AddMuftiNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;
  int currentPageIndex = 1;
  String? _documentId;

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
      await _uploadImageToFirebase();
    }
  }

  // Upload image to Firebase Storage
  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null) return;

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageReference =
      FirebaseStorage.instance.ref().child('MuftisPhoto/$fileName');

      UploadTask uploadTask = storageReference.putFile(_selectedImage!);
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});

      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  // Save data to Firestore
  Future<void> _saveData() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('muftis').add({
          'name': _nameController.text,
          'phone': _phoneNumberController.text,
          'workingHours': _workingHoursController.text,
          'photoUrl': _uploadedImageUrl ?? '',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $e')),
        );
      }
    }
  }

  // Pick start and end working hours using Time Pickers
  Future<void> _selectTimeRange(BuildContext context) async {
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Working Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start Time Picker
              Row(
                children: [
                  const Text('From: '),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) {
                        setState(() {
                          startTime = picked;
                        });
                      }
                    },
                    child: Text(
                      startTime.format(context),
                      style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
              // End Time Picker
              Row(
                children: [
                  const Text('To: '),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) {
                        setState(() {
                          endTime = picked;
                        });
                      }
                    },
                    child: Text(
                      endTime.format(context),
                      style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Set the selected times into the controller
                setState(() {
                  _workingHoursController.text = '${startTime.format(context)} - ${endTime.format(context)}';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Fetch data from Firestore by number and use the function in search icon
  Future<void> _fetchDataByNumber() async {
    final phone = _phoneNumberController.text;
    if (phone.isEmpty) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('muftis')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _documentId = doc.id;
         _nameController.text = doc ['name'];
         _workingHoursController.text = doc ['workingHours'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching document found')),
        );
        _clearFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    }
  }

  // Delete data from Firestore based on number
  Future<void> _deleteDocumentByNumber(String phone) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('muftis')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document(s) deleted successfully')),
        );
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No document found with that number')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete document: $e')),
      );
    }
  }

  void _clearFields() {
    setState(() {
      _nameController.clear();
      _phoneNumberController.clear();
      _workingHoursController.clear();
      _documentId = null;
    });
  }


  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    if (!RegExp(r'^[79]\d{7}$').hasMatch(value)) {
      return 'Enter a valid phone number starting with 9 or 7 and containing exactly 8 digits';
    }
    return null;
  }


  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    return null;
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
                  Colors.white,      // White color
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
                  'Add Mufti Number',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0C4E68),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffC7E2ED),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          IconButton(
                            icon: _selectedImage != null
                                ? Image.file(
                              _selectedImage!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                                : Icon(Icons.person, color: Colors.blueGrey, size: 60,),
                            onPressed: _pickImage,
                          ),
                          const SizedBox(height: 10),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: const TextStyle(
                                color: Colors.blueGrey,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFEEAD4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(
                              color: Color(0xff0C4E68),
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 20),

                          // Phone Number Field with Search Icon
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: const TextStyle(
                                color: Colors.blueGrey,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFEEAD4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search, color: Colors.blueGrey),
                                onPressed: _fetchDataByNumber,
                              ),
                            ),
                            style: const TextStyle(
                              color: Color(0xff0C4E68),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: _validatePhoneNumber,
                          ),
                          const SizedBox(height: 20),

                          // Working Hours Field with Time Picker
                          TextFormField(
                            controller: _workingHoursController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Working Hours',
                              labelStyle: const TextStyle(
                                color: Colors.blueGrey,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFEEAD4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.access_time, color: Colors.blueGrey),
                                onPressed: () {
                                  _selectTimeRange(context);
                                },
                              ),
                            ),
                            style: const TextStyle(
                              color: Color(0xff0C4E68),
                            ),
                          ),

                        ],
                      ),
                    ),
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
                          MaterialPageRoute(builder: (context) => const LeaderHomePage()),
                        );
                        break;
                      case 1:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AddMuftiNumberPage()),
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

          // Save and Delete Buttons
          Positioned(
            bottom: 150,
            right: 15,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final phoneNumber = _phoneNumberController.text;
                    if (phoneNumber.isNotEmpty) {
                      _deleteDocumentByNumber(phoneNumber);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phone number field cannot be empty')),
                      );
                    }
                  },
                  child: const Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF40ADD9),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                  ),
                ),


                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF40ADD9),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
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
