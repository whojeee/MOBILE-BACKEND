import 'package:flutter/material.dart';
import 'package:tugaskelompok/Pages/Loading.dart';
import 'botnav.dart';
import 'Pages/Calendar.dart';
import 'package:tugaskelompok/Pages/NewEvent.dart';
import 'Drawer.dart';
import 'Pages/Features.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';

void main() {
  runApp(MyApp());
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
  int eventCount = 0; // To store the event count

  final List<Widget> _children = [HomePage(), CalendarPage(), Features()];

  @override
  void initState() {
    super.initState();
    _loadEventCount();
  }

  // Future<void> _loadEventCount() async {
  //   final count = await DatabaseHelper.instance.queryEventCount();
  //   setState(() {
  //     eventCount = count;
  //   });
  // }

  Future<void> _loadEventCount() async {
    DatabaseHelper.instance.eventCountStream.listen((count) {
      setState(() {
        eventCount = count;
      });
    });
    DatabaseHelper.instance.updateEventCount();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleAddButton() async {
    final addedEvent = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewEventPage()),
    );

    if (addedEvent != null) {
      // Insert the new event into the database and update the event count.
      await DatabaseHelper.instance.insertEvent(addedEvent.toMap());
      await DatabaseHelper.instance.updateEventCount();
      setState(() {});
    }
  }

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
                if (eventCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        eventCount.toString(),
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
    );
  }
}

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

  List<EventModel> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await DatabaseHelper.instance.queryAllEvents();
    setState(() {
      this.events = events.map((event) => EventModel.fromMap(event)).toList();
    });
  }

  void _handleAddButton() async {
    final addedEvent = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewEventPage()),
    );

    if (addedEvent != null) {
      await DatabaseHelper.instance.insertEvent(addedEvent.toMap());
      setState(() {
        events.add(addedEvent);
        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      });

      // After adding the event, navigate back to the home page.
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          SizedBox(height: 16), // Added space between PageView and events list
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                String formattedDate = DateFormat('EEEE, d - MM - y')
                    .format(DateTime.parse(events[index].eventDate));

                return InkWell(
                  onTap: () {
                    setState(() {
                      events[index].isChecked = !events[index].isChecked;
                    });
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: events[index].isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                events[index].isChecked = value!;
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      events[index].eventName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  events[index].eventDescription,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            _handleAddButton();
          },
          child: Icon(Icons.create),
        ),
      ),
    );
  }
}
