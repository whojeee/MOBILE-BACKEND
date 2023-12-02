import 'package:flutter/material.dart';
// import 'Pages/Auth/Register.dart';
import 'Pages/Auth/Login.dart';
import 'Pages/Auth/Profile.dart';

class MyDrawer extends StatelessWidget {
  final String? email;
  final VoidCallback _logoutCallback;

  MyDrawer({required this.email, required VoidCallback logoutCallback})
      : _logoutCallback = logoutCallback;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Welcome"), // Replace with user's name
            accountEmail: Text("$email"), // Replace with user's email
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 48),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Calendar'),
            onTap: () {
              // Handle "Calendar" feature
            },
          ),
          ListTile(
            leading: Icon(Icons.event_note),
            title: Text('Events'),
            onTap: () {
              // Handle "Events" feature
            },
          ),
          // Divider(),
          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Login'),
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => LoginScreen(),
          //       ),
          //     );
          //   },
          // ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Logout'),
            onTap: () {
              _logoutCallback(); // Panggil fungsi logout saat Logout diklik
            },
          ),
        ],
      ),
    );
  }
}
