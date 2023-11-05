import 'package:flutter/material.dart';

class Features extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2, // 2 cards per row
        children: [
          _FeatureCard(
            title: 'Feature 1',
            color: Colors.red,
            borderColor: Colors.orange,
            onTap: () {
              // Handle tap on Feature 2
            },
            icon: Icons.star,
          ),
          _FeatureCard(
            title: 'Feature 2',
            color: Colors.red,
            borderColor: Colors.orange,
            onTap: () {
              // Handle tap on Feature 2
            },
            icon: Icons.settings,
          ),
          _FeatureCard(
            title: 'Feature 3',
            color: Colors.yellow,
            borderColor: Colors.pink,
            onTap: () {
              // Handle tap on Feature 3
            },
            icon: Icons.camera_alt,
          ),
          _FeatureCard(
            title: 'Feature 4',
            color: Colors.purple,
            borderColor: Colors.teal,
            onTap: () {
              // Handle tap on Feature 4
            },
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
  final IconData icon;

  _FeatureCard({
    required this.title,
    required this.color,
    required this.borderColor,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: borderColor, width: 2.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 45,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
