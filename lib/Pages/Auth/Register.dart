import 'package:flutter/material.dart';
import '../../Tools/Model/user.dart'; // Import the User model
import '../../Tools/Database/database_instance.dart'; // Import the DatabaseInstance class

class RegistrationPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final DatabaseInstance db =
      DatabaseInstance(); // Create an instance of DatabaseInstance

  void _handleRegistration() async {
    final username = usernameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    try {
      // Initialize the database
      await db.init();

      if (password == confirmPassword) {
        // Create a User object with premium set to false and name same as username
        final newUser = User(
          username: username,
          gmail: email,
          password: password,
          premium: false,
          nama: username,
        );

        // Insert the new user into the database
        await db.insert(newUser);

        // Perform any other registration logic here

        print('Registration successful');
        print('User data saved to the database: $newUser');
      } else {
        // Show an error message if passwords do not match
        print('Passwords do not match');
      }
    } catch (e) {
      // Handle any database initialization or insertion errors
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleRegistration,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
