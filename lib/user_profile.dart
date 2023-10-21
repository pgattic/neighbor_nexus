import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neighbor_nexus/chat_screen.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:neighbor_nexus/login.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Widget> chatButtons = [];
  Set<String> uniqueUserIds = Set(); // Store unique user IDs

  Future<void> _changeProfilePicture(AuthProvider authProvider) async {
    // ... your existing code for changing the profile picture
  }

  Future<void> _fetchChatButtons(AuthProvider authProvider) async {
    final user = authProvider.user;

    // Clear the existing chatButtons and uniqueUserIds when fetching
    chatButtons.clear();
    uniqueUserIds.clear();

    final chatDocs = await FirebaseFirestore.instance
        .collection('messages')
        .where('recipientId', isEqualTo: user?.uid)
        .get();

    for (final chat in chatDocs.docs) {
      final otherUserId = chat['senderId'];

      // Only add unique users
      if (!uniqueUserIds.contains(otherUserId)) {
        uniqueUserIds.add(otherUserId);

        final otherUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();
        final otherUserDisplayName = otherUserDoc['displayName'];

        chatButtons.add(
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(recipientUid: otherUserId),
              ));
            },
            child: Text("Your Chat with " + otherUserDisplayName),
          ),
        );
      }
    }
    setState(() {}); // Trigger a rebuild to display the chat buttons.
  }

  @override
  void initState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fetchChatButtons(authProvider);
    super.initState();
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
                backgroundImage:AssetImage("assets/images/logo.png"),
              ),
            ),
            ElevatedButton(
              onPressed: () { Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));},
              child: Text(
                'Signout',
                style: TextStyle(fontSize: 20),
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
            Expanded(
              child: ListView(
                children: chatButtons
                    .map((chatButton) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: chatButton,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
