import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  // Sign-up function
  // Updated signUp function
Future<void> signUp({required String email, required String password, required String displayName}) async {
  try {
    final authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = authResult.user;

    if (user != null) {
      // Update user display name
      await user.updateDisplayName(displayName);

      // Assign a generic example icon URL
      const String genericIconUrl = 'https://example.com/generic-icon.png';

      // Create a user document in Firestore with the generic icon URL
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': displayName,
        'icon': genericIconUrl,
      });

      _user = User(uid: user.uid, email: email, displayName: displayName, icon: genericIconUrl, eventIds: []); // Assign the generic icon URL
      notifyListeners();
    }
  } catch (e) {
    // Handle sign-up errors
    // ignore: avoid_print
    print(e);
  }
}

  


  // Sign out function
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

Future<void> login({required String email, required String password}) async {
  try {
    final authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = authResult.user;

    if (user != null) {
      _user = User(
        uid: user.uid,
        email: email,
        displayName: user.displayName ?? '', // You can handle null display name
        icon: '', // You can assign an icon if needed
        eventIds: [], // You can assign event IDs if needed
      );
      notifyListeners();
      print('Login successful');
    }
  } catch (e) {
    // Handle login errors
    // You can show an error message to the user if needed
    print('Login error: $e');
  }
}

 Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
    } catch (e) {
      throw e; // Handle or rethrow the error as needed
    }
  }

  void setUserIconURL(String iconURL,context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    user?.icon = iconURL;
  }
}




class User {
  String uid;
  String email;
  String displayName;
  String icon;
  List<String> eventIds;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.icon,
    required this.eventIds,
  });

  setEventIds(List<String> eventIds, {required String value}) {
  eventIds.add(value);
  }


  iconURL({required String newIconURL}) {
    icon = newIconURL;
  }
}


class Message {
  String? senderId;
  String? recipientId;
  String text;
  DateTime timestamp;

  Message({
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
  });
}

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message, String chatId) async {
    await _firestore.collection('messages').add({
      'senderId': message.senderId,
      'recipientId': message.recipientId,
      'text': message.text,
      'timestamp': message.timestamp,
      'chatId': chatId,
    });
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

class Event {
  final String eventId;
  final String title;
  final String dateTime;
  final String description;
  final double latitude;
  final double longitude;
  final String userId;

  Event({
    required this.eventId,
    required this.title,
    required this.dateTime,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });
}

