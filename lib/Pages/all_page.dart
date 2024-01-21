import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tugaskelompok/Drawer.dart';
import 'package:tugaskelompok/Pages/Auth/login_page.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/Pages/calender.dart';
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';
import 'package:tugaskelompok/botnav.dart';
import 'package:tugaskelompok/Pages/homepage.dart';

class MainPage extends StatefulWidget {
  final String title;
  final String? email;

  const MainPage(
      {Key? key, required this.title, this.email, required bool isPremiumUser});

  @override
  State<MainPage> createState() => _MainPageState(isPremiumUser: false);
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List<EventModel> events = [];
  int eventCount = 0;
  late AuthFirebase auth;

  var isPremiumUser;

  _MainPageState({required this.isPremiumUser});

  final List<Widget> _children = [
    HomePage(
      onPremiumStatusReceived: (p0) {},
    ),
    CalendarPage(),
  ];
  StreamController<int> myNotificationStreamController =
      StreamController<int>.broadcast();
  @override
  void dispose() {
    super.dispose();
    myNotificationStreamController.close();
  }

  @override
  void initState() {
    super.initState();
    auth = AuthFirebase();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    await auth.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            const SizedBox(width: 10),
            StreamBuilder<int>(
              stream: DatabaseHelper.instance.eventCountStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return Stack(
                    children: [
                      const Icon(Icons.notifications),
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                          child: Text(
                            snapshot.data.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Icon(Icons.notifications);
                }
              },
            )
          ],
        ),
      ),
      drawer: MyDrawer(
        email: widget.email ?? "user@example.com",
        logoutCallback: _logout,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
