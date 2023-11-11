import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugaskelompok/Tools/Model/GetStart_FirstTime.dart';
import 'package:tugaskelompok/main.dart';
import 'package:tugaskelompok/Pages/Auth/Login.dart';

class GetStart extends StatefulWidget {
  const GetStart({Key? key}) : super(key: key);

  @override
  State<GetStart> createState() => _GetStartState();
}

void checkOnboardingStatus(BuildContext context) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  bool hasCompletedOnboarding = _pref.getBool(KeyStore.pernahMasuk) ?? false;

  if (hasCompletedOnboarding) {
    // If onboarding is completed, navigate to the main screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}

class _GetStartState extends State<GetStart> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    checkOnboardingStatus(context);
    _pageController = PageController();
  }

  Widget _buildPage(
    String title,
    String description,
    String imagePath,
    VoidCallback onPressed,
    String buttonText,
  ) {
    return Container(
      color: Colors.blue[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              imagePath,
              width: 200.0,
              height: 200.0,
            ),
            SizedBox(height: 30.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          _buildPage(
            'Welcome to Daily Minder!',
            'Get started and explore our amazing features!',
            'assets/images/bg.png',
            () => _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            'Next',
          ),
          _buildPage(
            'Explore Amazing Features',
            'Discover all the powerful tools we offer.',
            'assets/images/BG1.png',
            () => _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            'Next',
          ),
          _buildPage(
            'Manage your time, achieve your dreams!',
            'Plan, execute, achieve!',
            'assets/images/bg3.png',
            () async {
              SharedPreferences _pref = await SharedPreferences.getInstance();
              _pref.setBool(KeyStore.pernahMasuk, true);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  // builder: (context) => MyHomePage(title: "Daily Minder"),
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            'Get Started',
          ),
        ],
      ),
    );
  }
}
