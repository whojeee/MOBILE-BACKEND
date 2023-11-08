import 'package:flutter/material.dart';
// import 'Pages/Auth/Register.dart';
import 'Pages/Auth/Login.dart';

class MyDrawer extends StatelessWidget {
  String? email;

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
              // Replace with user's profile picture
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 48),
            ),
          ),
          ListTile(
            leading: Icon(Icons.today),
            title: Text('Today'),
            onTap: () {
              // Handle "Today" feature
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
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Login'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
