import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Pages/NewEvent.dart';
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

    if (addedEvent != null) {
      setState(() {
        events.add(addedEvent);
      });
    }
  }

  List<EventModel> events = [];

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
                Center(), // Empty Container for Today Page
                Center(), // Empty Container for Week Page
                Center(), // Empty Container for Month Page
                Center(), // Empty Container for Year Page
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                String formattedDate = DateFormat('EEEE, d - MM - y')
                    .format(events[index].eventDate);

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
          ElevatedButton(
            onPressed: () {
              _handleAddButton(context);
            },
            child: Text('Add Event'),
          ),
        ],
      ),
    );
  }
}
