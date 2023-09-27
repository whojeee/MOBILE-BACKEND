import 'package:flutter/material.dart';

// Define kelas-kelas halaman
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Calendar Page'),
      ),
    );
  }
}

class NewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Page'),
      ),
      body: Center(
        child: Text('This is a New Page!'),
      ),
    );
  }
}

// Define BottomNavigationBar
class BottomNavBar extends StatelessWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  BottomNavBar({required this.onTabTapped, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Planner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
      ],
    );
  }
}
