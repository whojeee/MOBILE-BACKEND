import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:localization/localization.dart';
import 'package:tugaskelompok/Pages/all_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthFirebase auth;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    auth = AuthFirebase();
    auth.getUser().then((value) {
      if (value != null) {
        auth.getUserDetails().then((details) {
          if (details != null) {
            setState(() {
              userEmail = details['email'];
            });
          }
        });
        bool isUserPremium = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
              title: "Daily-Minder".i18n(),
              email: userEmail,
              isPremiumUser: isUserPremium,
            ),
          ),
        );
      }
    }).catchError((err) => print(err));
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      onLogin: _loginUser,
      onRecoverPassword: _recoverPassword,
      onSignup: _onSignup,
      passwordValidator: (value) {
        if (value != null) {
          if (value.length < 6) {
            return "pass terlalu pendek";
          }
        }
      },
      onSubmitAnimationCompleted: (() {}),
    );
  }

  Future<String?> _loginUser(LoginData data) async {
    final result = await auth.login(data.name, data.password);
    if (result != null) {
      await auth.getUserDetails().then((details) {
        if (details != null) {
          setState(() {
            userEmail = details['email'];
          });
        }
      });

      bool isUserPremium = true; // Set the premium status based on your logic

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
            title: "Daily-Minder".i18n(),
            email: userEmail,
            isPremiumUser: isUserPremium,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed-Login".i18n()),
          action: SnackBarAction(
            label: "OK",
            onPressed: () {},
          ),
        ),
      );
    }
    return "Gagal melakukan login"; // Mengembalikan pesan kesalahan
  }

  Future<String>? _recoverPassword(String name) {
    return null;
  }

  Future<String?> _onSignup(SignupData data) async {
    final result = await auth.signup(data.name!, data.password!);
    if (result != null) {
      auth.getUserDetails().then((details) {
        if (details != null) {
          setState(() {
            userEmail = details['email'];
          });
        }
      });

      bool isUserPremium = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
            title: "Daily-Minder".i18n(),
            email: userEmail,
            isPremiumUser: isUserPremium,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign-up-fail".i18n()),
          action: SnackBarAction(
            label: "ok",
            onPressed: () {},
          ),
        ),
      );
    }
    return "Gagal melakukan signup"; // Mengembalikan pesan kesalahan
  }

  Future<void> _logout() async {
    await auth.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
