// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:neighbor_nexus/login.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  // Remove the iconController

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
            TextField(controller: displayNameController, decoration: const InputDecoration(labelText: 'Display Name')),
            // Remove the TextField for the icon
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).signUp(
                  email: emailController.text,
                  password: passwordController.text,
                  displayName: displayNameController.text,
                );
              },
              child: const Text('Sign Up'),
              
            ),
            TextButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text("Already have an account? Login"),)
          ],
        ),
      ),
    );
  }
}
