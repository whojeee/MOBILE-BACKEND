import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugaskelompok/Tools/Model/user.dart'; // Import your user model
import 'package:tugaskelompok/Tools/Model/user_provider.dart'; // Import the UserProvider

class RegistrationPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _handleRegistration(BuildContext context) {
    final username = usernameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    try {
      if (password == confirmPassword) {
        final newUser = User(
          username: username,
          gmail: email,
          password: password,
          premium: false,
          nama: username,
        );

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.addUser(newUser);

        print('Registration successful');
        print('User data added: $newUser');
      } else {
        print('Passwords do not match');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

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
              onPressed: () => _handleRegistration(context),
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            Text('All Data Inside Provider:'),
            Expanded(
              child: ListView.builder(
                itemCount: userProvider.users.length,
                itemBuilder: (context, index) {
                  final user = userProvider.users[index];
                  return ListTile(
                    title: Text(user.username ?? ''),
                    subtitle: Text(user.gmail ?? ''),
                    // You can display more user details as needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
