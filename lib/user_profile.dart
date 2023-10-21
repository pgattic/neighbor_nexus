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

  Future<void> _changeProfilePicture(AuthProvider authProvider) async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    final user = authProvider.user;

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
          authProvider.setUserIconURL(iconURL,context);
        });
      } catch (e) {
        print('Error updating user profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user?.icon ?? 'https://example.com/default-profile-image.jpg'),
              ),
            ),
            ElevatedButton(
              onPressed: () => _changeProfilePicture(authProvider),
              child: Text('Change Profile Picture',
              style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(10),
                child: Text(
                  'Display Name: ${user?.displayName ?? 'Loading...'}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(10),
                child: Text(
                  'Email: ${user?.email ?? 'Loading...'}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
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
                      onTap: () {},
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
