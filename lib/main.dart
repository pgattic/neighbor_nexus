import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:neighbor_nexus/login.dart'; // Import your LoginPage
import 'package:neighbor_nexus/chat_screen.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:neighbor_nexus/firebase_options.dart';
import 'package:neighbor_nexus/map_view.dart';
import 'package:neighbor_nexus/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          // Check if the user is authenticated
          if (user != null) {
            return HomeScreen(); // Return HomeScreen when the user is authenticated
          } else {
            return LoginPage(); // Return LoginPage when the user is not authenticated
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final userID = user!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Implement the sign-out functionality
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to your app!'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfilePage()));
                // Implement navigation to other screens here
              },
              child: const Text('Go to user'),
            ),
            
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(recipientUid: 'xotUbLqy0wMo6wuoo3HQRMmAqA03',)));
                // Implement navigation to other screens here
              },
              child: const Text('Go to chat'),
            ),
                        ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventMap()));
                // Implement navigation to other screens here
              },
              child: const Text('Go to map'),
            ),
          ],
        ),
      ),
    );
  }
}
