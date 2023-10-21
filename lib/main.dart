import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);

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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neighborhood Nexus'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfilePage()));
            },
          ),
        ],
      ),
      body: Center(
        child: EventMap(),
      ),
    );
  }
}
