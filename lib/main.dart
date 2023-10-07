import 'package:flutter/material.dart';
import 'package:tugaskelompok/Pages/Loading.dart';
import 'botnav.dart';
import 'Pages/Calendar.dart';
import 'HomePage.dart';
import 'Pages/NewEvent.dart';
import 'Pages/GetStart.dart';
import 'Drawer.dart';
import 'Pages/Features.dart';
import 'Pages/Category.dart';
import 'Tools/Model/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoadingPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [HomePage(), CalendarPage(), Features()];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleAddButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewEventPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: MyDrawer(),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavBar(
          onTabTapped: onTabTapped,
          currentIndex: _currentIndex,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Transform.scale(
          scale: 1.2,
          child: Container(
            margin: EdgeInsets.only(right: 5, bottom: 5),
            child: FloatingActionButton(
              onPressed: _handleAddButton,
              tooltip: 'Add Plan',
              child: Icon(
                Icons.create,
                size: 24,
              ),
            ),
          ),
        ));
  }
}
