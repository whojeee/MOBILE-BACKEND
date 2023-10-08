import 'package:flutter/material.dart';
import 'Pages/NewEvent.dart'; // Import your event provider
import '../Tools/Model/event_model.dart';

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

  void _handleAddButton(BuildContext context) async {
    final addedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEventPage(),
      ),
    );

    // If an event was added, you can use it as needed
    if (addedEvent != null) {
      setState(() {
        // Update your UI to display the added event
        // Here, we assume you have a list of events
        // and we add the added event to that list
        events.add(addedEvent);
      });
    }
  }

  List<EventModel> events = []; // Maintain a list of events

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
                // You can add different pages here
                Center(child: Text('Today Page')),
                Center(child: Text('Week Page')),
                Center(child: Text('Month Page')),
                Center(child: Text('Year Page')),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _handleAddButton(context);
            },
            child: Text('Add Event'),
          ),
          // Display the added events in a list or another suitable way
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index].eventName),
                  subtitle: Text(events[index].eventDescription),
                  // Add more event details as needed
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
