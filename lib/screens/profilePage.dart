import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class profilePage extends StatefulWidget {
  const profilePage({Key? key}) : super(key: key);

  @override
  State<profilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<profilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> userDocument;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      userDocument = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: FutureBuilder<DocumentSnapshot>(
          future: userDocument,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }

            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            String userName = userData['name'] ?? 'No name';

            return Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                              'https://www.seekpng.com/png/detail/245-2454602_tanni-chand-default-user-image-png.png'),
                        ),
                        Positioned(
                          bottom: -8,
                          left: 70,
                          child: IconButton(
                            onPressed: () {
                              // Implement photo change functionality here
                            },
                            icon: const Icon(Icons.add_a_photo),
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0C4E68),
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              // Implement edit profile functionality here
                            },
                            child: const Text(
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

