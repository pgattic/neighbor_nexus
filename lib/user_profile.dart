import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:provider/provider.dart';




class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _displayName;

  Future<void> _changeProfilePicture(AuthProvider authProvider) async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    final user = authProvider.user; // Access the user from the AuthProvider

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final storage = FirebaseStorage.instance;
      final Reference storageReference = storage.ref().child('profile_images/${user!.uid}.jpg');
      await storageReference.putFile(imageFile);
      final iconURL = await storageReference.getDownloadURL();

      try {
        await user?.iconURL(newIconURL: iconURL);
        final userDoc = _firestore.collection('users').doc(user!.uid);
        await userDoc.update({'icon': iconURL});

        

        setState(() {
          // Update the user iconURL using authProvider.
          authProvider.setUserIconURL(iconURL,context);
        });
      } catch (e) {
        print('Error updating user profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the user from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // User Profile Picture
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user?.icon ??
                    'https://example.com/default-profile-image.jpg'),
              ),
            ),

            // Change Profile Picture Button
            ElevatedButton(
              onPressed: () => _changeProfilePicture(authProvider),
              child: Text('Change Profile Picture'),
            ),

            // Display Name
            Text(
              'Display Name: ${user?.displayName ?? 'Loading...'}',
              style: TextStyle(fontSize: 16),
            ),

            // Email
            Text(
              'Email: ${user?.email ?? 'Loading...'}',
              style: TextStyle(fontSize: 16),
            ),

            // List of Chats
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final chatDocs = snapshot.data!.docs;

                return Column(
                  children: chatDocs.map((chat) {
                    return ListTile(
                      title: Text(chat['chatName']),
                      onTap: () {
                        // Implement navigation to the chat screen with the selected chat.
                        // Pass the chat ID or other necessary information to open the correct chat.
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
