import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class profilePage extends StatefulWidget{
  const profilePage({Key? key}) : super(key: key);
  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage>{
  //to retreive data from firestore
  //instance => getter that return an instance of a single firebase app
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance.collection("users").snapshots();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () async{
            await FirebaseAuth.instance.signOut();
            Navigator.pop(context);
          },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
    );
  }
}