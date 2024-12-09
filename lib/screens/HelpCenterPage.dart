import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  bool isAboutExpanded = false;
  bool isPrivacyExpanded = false;
  bool isQuestionExpanded = false;
  TextEditingController _questionController = TextEditingController();

  void _saveQuestion() {
    final questionText = _questionController.text.trim();
    if (questionText.isNotEmpty) {
      FirebaseFirestore.instance.collection('question').add({
        'askQuestion': questionText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _questionController.clear();
      setState(() {
        isQuestionExpanded = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your question has been submitted.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1B93C5),
        title: Text(
          'Help Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color(0xFFE0F7FA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpSection(
              title: "About Us",
              content:
              "Rooms of Light is an integrated platform for learning and development, enhancing the religious aspect, and participating in volunteer initiatives and Umrah and Hajj campaigns. Our app provides various categories to meet the religious needs of all users, including Fatwa, Voluntary Initiatives, Umrah Campaigns, and Holy Qur’an Episodes.",
              isExpanded: isAboutExpanded,
              onTap: () {
                setState(() {
                  isAboutExpanded = !isAboutExpanded;
                });
              },
            ),
            SizedBox(height: 20),
            _buildHelpSection(
              title: "Privacy and Security Help",
              content:
              "We prioritize your privacy and security. Rooms of Light ensures that your data is protected, using industry-standard security measures to keep your information safe and secure.",
              isExpanded: isPrivacyExpanded,
              onTap: () {
                setState(() {
                  isPrivacyExpanded = !isPrivacyExpanded;
                });
              },
            ),
            SizedBox(height: 20),
            _buildAskQuestionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required String title,
    required String content,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0C4E68),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Color(0xff1B93C5),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  content,
                  style: TextStyle(fontSize: 15, color: Color(0xff4A6572)),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskQuestionSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isQuestionExpanded = !isQuestionExpanded;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ask a Question",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0C4E68),
                  ),
                ),
                Icon(
                  isQuestionExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Color(0xff1B93C5),
                ),
              ],
            ),
            if (isQuestionExpanded)
              Column(
                children: [
                  SizedBox(height: 10),
                  TextField(
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    controller: _questionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Type your question here...",
                      hintStyle: TextStyle(color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xff0C4E68),
                          width: 5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xff1B93C5), // Focused border color
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                    ),
                  ),


                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff1B93C5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: Text("Submit Question"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
