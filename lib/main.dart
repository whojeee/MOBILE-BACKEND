import 'package:flutter/material.dart';
import 'package:tugaskelompok/Pages/Loading.dart';
import 'botnav.dart';
import 'Pages/Calendar.dart';
import 'HomePage.dart';
import 'Pages/NewEvent.dart';
import 'Drawer.dart';
import 'Pages/Features.dart';
import 'Tools/Model/user_provider.dart';
import 'package:provider/provider.dart';
import 'Pages/event_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => EventProvider(),
        ),
      ],
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

  @override
  void initState() {
    super.initState();

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.eventCountStream.listen((eventCount) {
      setState(() {
        _eventCount = eventCount;
      });
    });
  }

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

  int _eventCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            SizedBox(width: 10),
            Stack(
              children: [
                Icon(Icons.notifications),
                if (_eventCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _eventCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
      ),
    );
  }
}
