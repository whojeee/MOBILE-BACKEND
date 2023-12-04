import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'Pages/Auth/Profile.dart';

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
  void initState() {
    super.initState();
    // Memeriksa izin saat drawer diinisialisasi
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Welcome"), // Replace with user's name
            accountEmail: Text("${widget.email}"), // Replace with user's email
            currentAccountPicture: GestureDetector(
              onTap: () {
                getImage(); // Panggil fungsi getImage() ketika gambar profil ditekan
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
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Logout'),
            onTap: () {
              widget
                  ._logoutCallback(); // Panggil fungsi logout saat Logout diklik
            },
          ),
        ],
      ),
    );
  }
}
