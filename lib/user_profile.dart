import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _picker = ImagePicker();
  String _profileImageURL = ''; // This variable stores the profile image URL.

  // Function to update the user's profile picture.
  Future<void> _updateProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = Provider.of<AuthProvider>(context).user;
      final userID = user?.uid;

      if (userID != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('profileImages/$userID.jpg');
        final uploadTask = storageRef.putFile(File(pickedFile.path));

        // Listen for the completion of the upload task.
        uploadTask.then((snapshot) async {
          final imageURL = await snapshot.ref.getDownloadURL();

          // Update the user's profileImageURL in Firestore.
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .update({
            'profileImageURL': imageURL,
          });

          setState(() {
            _profileImageURL = imageURL;
          });
        }).catchError((error) {
          print('Error uploading image: $error');
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Load the user's profile image URL from Firestore when the page loads.
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final userID = user?.uid;

    if (userID != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get()
          .then((userDoc) {
        final data = userDoc.data() as Map<String, dynamic>;
        final profileImageURL = data['profileImageURL'];
        setState(() {
          _profileImageURL = profileImageURL ??
              ''; // If there's no profile image URL, set it to an empty string.
        });
      });
    }
  }

  @override
  Widget build(context) {
    final user = Provider.of<AuthProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User page'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: _updateProfilePicture,
                          child: const Text('Update Profile Picture'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Name: ${user?.displayName ?? 'Unknown'}'),
              const SizedBox(height: 20),
              Text('Email: ${user?.email ?? 'Unknown'}'),
            ],
          ),
        ),
      ),
    );
  }
}
