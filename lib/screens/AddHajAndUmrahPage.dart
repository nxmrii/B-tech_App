import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooms_btechapp/screens/LeaderHomePage.dart';
import 'package:rooms_btechapp/screens/LeaderProfilePage.dart';

class AddHajAndUmrahPage extends StatefulWidget {
  const AddHajAndUmrahPage({Key? key}) : super(key: key);

  @override
  _AddHajAndUmrahPageState createState() => _AddHajAndUmrahPageState();
}

class _AddHajAndUmrahPageState extends State<AddHajAndUmrahPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _campaignsNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  String? _documentId;
  int currentPageIndex = 1;

  // Save data to Firestore
  Future<void> _saveData() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('Hajj_Umrah').add({
          'campaignsName': _campaignsNameController.text,
          'number': _numberController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully')),
        );
        _clearFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $e')),
        );
      }
    }
  }

  // Fetch data from Firestore by number
  Future<void> _fetchDataByNumber() async {
    final number = _numberController.text;
    if (number.isEmpty) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Hajj_Umrah')
          .where('number', isEqualTo: number)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _documentId = doc.id;
          _campaignsNameController.text = doc['campaignsName'];
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
  Future<void> _deleteDocumentByNumber(String number) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Hajj_Umrah')
          .where('number', isEqualTo: number)
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
      _campaignsNameController.clear();
      _numberController.clear();
      _documentId = null;
    });
  }

  String? _validateCampaignsName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campaigns name cannot be empty';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number cannot be empty';
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
                  'Add Haj & Umrah Campaign',
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
                      color: const Color(0xffC7E2ED),
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
                          // Campaign Name Field
                          TextFormField(
                            controller: _campaignsNameController,
                            decoration: InputDecoration(
                              labelText: 'Campaigns Name',
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
                            validator: _validateCampaignsName,
                          ),
                          const SizedBox(height: 20),

                          // Number Field
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _numberController,
                                  decoration: InputDecoration(
                                    labelText: 'Number',
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
                                  keyboardType: TextInputType.number,
                                  validator: _validateNumber,
                                ),
                              ),
                              IconButton(
                                onPressed: _fetchDataByNumber,
                                icon: const Icon(Icons.search),
                                color: Colors.blueGrey,
                              ),
                            ],
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
                          MaterialPageRoute(builder: (context) => const AddHajAndUmrahPage()),
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
                    final number = _numberController.text;
                    if (number.isNotEmpty) {
                      _deleteDocumentByNumber(number);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Number field cannot be empty')),
                      );
                    }
                  },
                  child: const Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: const Color(0xffF1828D),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: const Color(0xffA5C4D4),
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
