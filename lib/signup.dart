import 'package:flutter/material.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:neighbor_nexus/login.dart';
import 'package:neighbor_nexus/main.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo here
            // For example, an Image widget
            Image.asset(
              'assets/images/logo.png',
              width: 150, // Adjust the size as needed
              height: 150, // Adjust the size as needed
            ),
            const SizedBox(height: 16), // Add spacing
            const Text(
              'Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16), // Add spacing
            // Curved text fields
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8), // Add more spacing
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8), // Add more spacing
            TextFormField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Remove the TextField for the icon
            const SizedBox(height: 16), // Add more spacing
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).signUp(
                  email: emailController.text,
                  password: passwordController.text,
                  displayName: displayNameController.text,
                );
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
