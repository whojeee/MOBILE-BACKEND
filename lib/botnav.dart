import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const BottomNavBar(
      {Key? key, required this.onTabTapped, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Planner'.i18n(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar'.i18n(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_compact_rounded),
          label: 'Features'.i18n(),
        ),
      ],
    );
  }
}
