import 'package:flutter/material.dart';

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
