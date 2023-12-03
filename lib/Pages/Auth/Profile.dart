import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _profilePictureController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  // final TextEditingController _premiumController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedStatus = 'Active'; 
  bool _isPremium = false; 

  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = await AuthFirebase().getUser();

      if (user != null) {
        final String userUid = user.uid;
        final DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('profile').doc(userUid).get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            _usernameController.text = userData['username'];
            _profilePictureController.text = userData['profilePicture'];
            _descriptionController.text = userData['description'];
            _statusController.text = userData['status'];
            // _premiumController.text = userData['premium'];
          });
        }
      }
    } catch (error) {
      print('Error loading user data: $error');
    }
  }

  Future<void> _updateUserData() async {
    try {
      final User? user = await AuthFirebase().getUser();

      if (user != null) {
        final String userUid = user.uid;

        await _firestore.collection('profile').doc(userUid).set({
          'username': _usernameController.text,
          'profilePicture': _profilePictureController.text,
          'description': _descriptionController.text,
          'status': _selectedStatus,
          // 'premium': _isPremium,
          'premium': false,
          'email': _currentUser.email,
        });

        print('User data updated successfully!');
      }
    } catch (error) {
      print('Error updating user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _profilePictureController,
              decoration: InputDecoration(labelText: 'Profile Picture URL'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
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
              hint: Text('Status'),
            ),
            // SizedBox(height: 16.0),
            // CheckboxListTile(
            //   title: Text('Premium'),
            //   value: _isPremium,
            //   onChanged: (bool? value) {
            //     setState(() {
            //       _isPremium = value!;
            //     });
            //   },
            // ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
