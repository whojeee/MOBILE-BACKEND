import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';

class ProfilePage extends StatefulWidget {
  static bool isPremium=false;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _profilePictureController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _selectedStatus = 'Active';
  bool _isPremium = false;

  late User _currentUser;
  File? _image;
  bool _isUpdating = false;
  late String _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _profilePictureUrl = '';
    _currentUser = _auth.currentUser!;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = await AuthFirebase().getUser();

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
            _usernameController.text = userData['username'];
            _profilePictureController.text = userData['profilePicture'];
            _descriptionController.text = userData['description'];
            _statusController.text = userData['status'];
            _isPremium = userData['premium'] ?? false;
          });
        }
      }
    } catch (error) {
      print('Error loading user data: $error');
    }
  }

  Future<void> _updateUserData() async {
    try {
      setState(() {
      _isUpdating = false;
      // Update the static variable when premium status changes
      ProfilePage.isPremium = _isPremium;
    });

      final User? user = await AuthFirebase().getUser();

      if (user != null) {
        final String userUid = user.uid;

        // Check if there is a new image to upload
        if (_image != null) {
          // Upload the image to Firebase Storage
          String imagePath = 'profilePictures/$userUid/${DateTime.now()}.png';
          TaskSnapshot task = await _storage.ref(imagePath).putFile(_image!);

          // Get the download URL of the uploaded image
          _profilePictureUrl = await task.ref.getDownloadURL();
        }

        // Update user data in Firestore with the profile picture URL
        await _firestore.collection('profile').doc(userUid).set({
          'username': _usernameController.text,
          'description': _descriptionController.text,
          'status': _selectedStatus,
          'premium': _isPremium,
          'profilePicture': _profilePictureUrl, // Update with the image URL
          'email': _currentUser.email,
        });

        print('User data updated successfully!');
      }
    } catch (error) {
      print('Error updating user data: $error');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _profilePictureController.text = pickedFile.path;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'.i18n()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'.i18n()),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _profilePictureController,
              decoration:
                  InputDecoration(labelText: 'Profile-Picture-URL'.i18n()),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isUpdating ? null : () => _pickImage(),
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'.i18n()),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              items: <String>['Active', 'Inactive', 'On Hold']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              hint: Text('Status'.i18n()),
            ),
            CheckboxListTile(
              title: Text('Premium User'),
              value: _isPremium,
              onChanged: (bool? value) {
                setState(() {
                  _isPremium = value ?? false;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isUpdating ? null : () => _updateUserData(),
              child: Text('Update-Profile'.i18n()),
            ),
          ],
        ),
      ),
    );
  }
}
