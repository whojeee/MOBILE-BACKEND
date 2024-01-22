import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/Pages/calender.dart';
import 'Pages/Auth/profile.dart';
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

  Future<void> _requestGalleryPermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      print('Permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Welcome".i18n()),
            accountEmail: Text("${widget.email}"),
            currentAccountPicture: GestureDetector(
              onTap: () {
                _requestGalleryPermission();
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event_note),
            title: Text('Events'.i18n()),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Logout'.i18n()),
            onTap: () {
              widget._logoutCallback();
            },
          ),
        ],
      ),
    );
  }
}
