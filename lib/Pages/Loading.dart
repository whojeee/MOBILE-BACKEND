import 'package:flutter/material.dart';
import 'package:tugaskelompok/Pages/GetStart.dart';

void main() => runApp(MaterialApp(
      home: LoadingPage(),
    ));

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  Future<void> _delayedNavigation() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    _delayedNavigation().then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GetStart(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Atur warna latar belakang di sini
      body: Center(
        child: Image.asset(
          'assets/images/Loading.png',
          width: 450.0,
          height: 450.0,
        ),
      ),
    );
  }
}
