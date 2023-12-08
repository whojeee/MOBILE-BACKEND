import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'Pages/Auth/Profile.dart';
import 'package:localization/localization.dart';

class MyDrawer extends StatefulWidget {
  final String? email;
  final VoidCallback _logoutCallback;

  MyDrawer({required this.email, required VoidCallback logoutCallback})
      : _logoutCallback = logoutCallback;

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  File? _image;

  // Function to request permission
  Future<void> _requestGalleryPermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Do nothing here, permission is already granted
    } else {
      // Handle the case where the user denies the permission
      // You may want to show a dialog or message to inform the user
      print('Permission denied');
    }
  }

  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Welcome".i18n()), // Replace with user's name
            accountEmail: Text("${widget.email}"), // Replace with user's email
            currentAccountPicture: GestureDetector(
              onTap: () {
                _requestGalleryPermission(); // Request permission when profile picture is tapped
                getImage(); // Call getImage() function when the profile picture is tapped
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: _image != null
                    ? ClipOval(
                        child: Image.file(
                          _image!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.person, size: 48),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'.i18n()),
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
            title: Text('Calendar'.i18n()),
            onTap: () {
              // Handle "Calendar" feature
            },
          ),
          ListTile(
            leading: Icon(Icons.event_note),
            title: Text('Events'.i18n()),
            onTap: () {
              // Handle "Events" feature
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Logout'.i18n()),
            onTap: () {
              widget
                  ._logoutCallback(); // Call the logout function when Logout is tapped
            },
          ),
        ],
      ),
    );
  }
}
