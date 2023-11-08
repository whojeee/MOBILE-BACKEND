import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthFirebase auth;

  @override
  void initState() {
    super.initState();
    auth = AuthFirebase();
    auth.getUser().then((value) {
      if (value != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(title: "Daily Minder"),
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
      // loginProviders: <LoginProvider>[
      //   LoginProvider(
      //       icon: FontAwesomeIcons.google,
      //       label: "Google",
      //       callback: _onLoginGoogle)
      // ],
      onSubmitAnimationCompleted: (() {}),
    );
  }

  Future<String?> _loginUser(LoginData data) async {
    final result = await auth.login(data.name, data.password);
    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: "Daily Minder")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Gagal"),
          action: SnackBarAction(
            label: "ok",
            onPressed: () {},
          ),
        ),
      );
    }
    return null;
  }

  Future<String>? _recoverPassword(String name) {
    return null;
  }

  Future<String?> _onSignup(SignupData data) async {
    final result = await auth.signup(data.name!, data.password!);
    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: "Daily Minder")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup Gagal"),
          action: SnackBarAction(
            label: "ok",
            onPressed: () {},
          ),
        ),
      );
    }
    return null;
  }

  // Future<String>? _onLoginGoogle() {
  //   return null;
  // }
}
