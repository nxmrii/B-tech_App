import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rooms_btechapp/screens/LeaderHomePage.dart';
import 'package:rooms_btechapp/screens/LeaderProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rooms_btechapp/widget/map_screen.dart';
import 'package:url_launcher/url_launcher.dart';


class AddLecturesPage extends StatefulWidget {
  @override
  _AddLecturesPageState createState() => _AddLecturesPageState();
}

class _AddLecturesPageState extends State<AddLecturesPage> {
  String? selectedLectureType;
  bool isOnline = false;
  int currentPageIndex = 1;
  late String selectedLectureId;
  LatLng? selectedLocation;

  TextEditingController locationController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController lecturerNameController = TextEditingController();
  Future<String> convert_to_link(String lat, String lan) async {
    String googleMapsUrl = "https://www.google.com/maps?q=$lat,$lan";

    return googleMapsUrl;
  }

  // Function to search for lecture by subject
  Future<void> _searchLectureBySubject(String subject) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Lectures')
          .where('subject', isEqualTo: subject)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final lectureData = snapshot.docs.first.data();
        selectedLectureId = snapshot.docs.first.id;

        selectedLectureType = lectureData['type'];
        subjectController.text = lectureData['subject'];
        isOnline = lectureData['location'] == 'Online';
        locationController.text = isOnline ? lectureData['link'] : '';
        lecturerNameController.text = lectureData['lecturer_Name'];
        timeController.text = lectureData['lecture_time'];
        dateController.text = lectureData['Lecture_date'];

        print("Lecture found and fields populated.");
      } else {
        print("No lecture found for the specified subject.");
      }
    } catch (e) {
      print("Error fetching lecture: $e");
    }
  }

  //function to select location
  Future<void> _selectLocationOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          onLocationSelected: (location) => Navigator.of(context).pop(location),
        ),
      ),
    );

    if (selectedLocation != null) {
      final linkLocation = await convert_to_link(selectedLocation.latitude.toString(), selectedLocation.longitude.toString());

      setState(() {
        locationController.text = linkLocation;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Add Lectures',
            style: TextStyle(color: Color(0xff0C4E68), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Lecture Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedLectureType,
              hint: const Text('Select Lecture Type', style: TextStyle(color: Colors.grey)),
              items: ['Duaa', 'Tilawah', 'Tadabor', 'Hifd'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Builder(
                    builder: (BuildContext context) {
                      bool isSelected = selectedLectureType == value;
                      return Text(
                        value,
                        style: TextStyle(
                          color: isSelected ? Color(0xff0C4E68) : Colors.black,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedLectureType = newValue;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xffFFEAD4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 10),

            // Subject Field
            _buildTextField('Subject', controller: subjectController),
            const SizedBox(height: 10),

            // Lecturer Name Field
            _buildTextField('Lecturer Name', controller: lecturerNameController),
            const SizedBox(height: 10),

            // Time Field
            _buildTextField('Time', controller: timeController, icon: Icons.access_time, iconColor: Color(0xff0C4E68), onTap: () => _selectTime(context)),
            const SizedBox(height: 10),

            // Date Field
            _buildTextField('Date', controller: dateController, icon: Icons.calendar_today, iconColor: Color(0xff0C4E68), onTap: () => _selectDate(context)),
            const SizedBox(height: 10),

            // Choose Location Section
            const Text('Choose Location:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff3E6FBE))),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isOnline,
                  onChanged: (bool? value) {
                    setState(() {
                      isOnline = value!;
                      if (isOnline){
                        locationController.clear();
                        selectedLocation = null;
                      }else{
                        locationController.clear();
                      }
                    });
                  },
                ),
                const Text('Online', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                Radio(
                  value: false,
                  groupValue: isOnline,
                  onChanged: (bool? value) {
                    setState(() {
                      isOnline = value!;
                      if (isOnline){
                        locationController.clear();
                        selectedLocation = null;
                      }else{
                        locationController.clear();
                      }
                    });
                  },
                ),
                const Text('Offline', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),


            // Conditionally show the link field for online or location button for offline
            Visibility(
              visible: isOnline,
              child: _buildTextField('Lecture Link', controller: locationController),
            ),
            Visibility(
              visible: !isOnline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First show the button
                  ElevatedButton(
                    onPressed: _selectLocationOnMap,
                    child: const Text(
                      'Click to Choose Location on Map',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFF7EE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display the selected location label after the button
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: locationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Selected Location',
                        labelStyle: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12, // Adjust font size here
                        ),
                        fillColor: const Color(0xffFFEAD4),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, // Adjust vertical padding to control field height
                          horizontal: 9, // Adjust horizontal padding as needed
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      style: const TextStyle(color: Color(0xff0C4E68), fontSize: 14,),

                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 22),

            //Buttons for Update, Delete, and Submit
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.update, color: Colors.blue),
                  iconSize: 30,
                  onPressed: () {
                    _updateLecture();
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 30,
                  onPressed: () {
                    _deleteLecture();
                  },
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _submitLectureData,
                  child: const Text(
                    'sent',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0C4E68),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  iconSize: 30,
                  onPressed: () {
                    _searchLectureBySubject(subjectController.text);
                  },
                ),
                const SizedBox(width: 20),
              ],
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
                    MaterialPageRoute(builder: (context) => const LeaderHomePage()),
                  );
                  break;
                case 1:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AddLecturesPage()),
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
    );
  }

  // Helper method to build optional controller and icon
  Widget _buildTextField(String label, {TextEditingController? controller, IconData? icon, Color iconColor = const Color(0xff0C4E68), void Function()? onTap}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xff0C4E68)),
      readOnly: onTap != null, // Make the field read-only if onTap is provided
      onTap: onTap, // Trigger the tap function if provided
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xffFFEAD4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        prefixIcon: icon != null ? Icon(icon, color: iconColor) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Future<void> _submitLectureData() async {
    if (selectedLectureType == null || subjectController.text.isEmpty || lecturerNameController.text.isEmpty) {
      print('Please fill all required fields.');
      return;
    }
    // Check if the lecture is online and URL is valid
    if (isOnline && locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a valid Google Meet link for the online lecture.')),
      );
      return;
    }

    if (isOnline && !locationController.text.startsWith('https://meet.google.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a valid Google Meet URL.')),
      );
      return;
    }

    Map<String, dynamic> lectureData = {
      'type': selectedLectureType,
      'subject': subjectController.text,
      'lecturer_Name': lecturerNameController.text,
      'lecture_time': timeController.text,
      'Lecture_date': dateController.text,
      'location': isOnline ? 'Online' : 'Offline',
      'link':  locationController.text
    };

    try {
      await FirebaseFirestore.instance.collection('Lectures').add(lectureData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lecture added successfully!')));

      // Clear the text fields after submission
      setState(() {
        selectedLectureType = null;
        subjectController.clear();
        lecturerNameController.clear();
        timeController.clear();
        dateController.clear();
        locationController.clear();
        isOnline = false;
      });
    } catch (e) {
      print("Error adding lecture: $e");
    }
  }



  Future<void> _updateLecture() async {
    try {
      await FirebaseFirestore.instance.collection('Lectures').doc(selectedLectureId).update({
        'type': selectedLectureType,
        'subject': subjectController.text,
        'lecturer_Name': lecturerNameController.text,
        'lecture_time': timeController.text,
        'Lecture_date': dateController.text,
        'location': isOnline ? 'Online' : 'Offline',
        'link': isOnline ? locationController.text : 'Lat: ${selectedLocation?.latitude}, Lng: ${selectedLocation?.longitude}',
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lecture updated successfully!')));
      print("Lecture updated successfully.");
    } catch (e) {
      print("Error updating lecture: $e");
    }
  }

  Future<void> _deleteLecture() async {
    try {
      await FirebaseFirestore.instance.collection('Lectures').doc(selectedLectureId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lecture deleted successfully!')));
      print("Lecture deleted successfully.");

      // Clear the text fields after deletion
      setState(() {
        selectedLectureType = null;
        subjectController.clear();
        lecturerNameController.clear();
        timeController.clear();
        dateController.clear();
        locationController.clear();
        isOnline = false;
      });

    } catch (e) {
      print("Error deleting lecture: $e");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        timeController.text = selectedTime.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }
}
