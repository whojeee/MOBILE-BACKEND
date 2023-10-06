import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  String getTitle(int index) {
    switch (index) {
      case 0:
        return 'Today';
      case 1:
        return 'Week';
      case 2:
        return 'Month';
      case 3:
        return 'Year';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      getTitle(index),
                      style: TextStyle(
                        color:
                            currentIndex == index ? Colors.black : Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              children: <Widget>[
                Center(child: Text('Today Page')),
                Center(child: Text('Week Page')),
                Center(child: Text('Month Page')),
                Center(child: Text('Year Page')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
