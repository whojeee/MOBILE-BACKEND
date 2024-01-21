import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getUser() async {
    return _auth.currentUser;
  }

  Future<Map<String, String>?> getUserDetails() async {
    User? user = await getUser();
    if (user != null) {
      return {
        'email': user.email ?? '',
        'uid': user.uid,
      };
    }
    return null;
  }

  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserCredential?> signup(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userUid = userCredential.user!.uid;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('profile')
          .doc(userUid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('profile')
            .doc(userUid)
            .set({
          'userId': userUid,
        });
      }

      return userCredential;
    } catch (e) {
      print("Signup error: $e");
      return null;
    }
  }
}
