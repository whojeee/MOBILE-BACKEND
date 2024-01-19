import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/Tools/Model/user.dart';
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
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePictureUrl();
  }

  Future<void> _loadProfilePictureUrl() async {
    try {
      final user = await AuthFirebase().getUser();

      if (user != null) {
        final String userUid = user.uid;
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('profile')
            .doc(userUid)
            .get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            _profilePictureUrl = userData['profilePicture'] ?? '';
          });
        }
      }
    } catch (error) {
      print('Error loading profile picture URL: $error');
    }
  }

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

  // Future getImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   setState(() async {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);

  //       // Upload the new image to Firestore and get the URL
  //       String profilePictureUrl = await uploadImageToFirestore(_image!);

  //       // Update the _profilePictureUrl
  //       setState(() {
  //         _profilePictureUrl = profilePictureUrl;
  //       });
  //     }
  //   });
  // }

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
                // getImage(); // Call getImage() function when the profile picture is tapped
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child:
                    _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              _profilePictureUrl!,
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
