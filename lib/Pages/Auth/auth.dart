import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getUser() async {
    return _auth.currentUser;
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
      return userCredential;
    } catch (e) {
      print("Signup error: $e");
      return null;
    }
  }
}
