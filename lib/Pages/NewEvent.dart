import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_provider.dart'; // Import your event provider
import '../Tools/Model/event_model.dart';

class NewEventPage extends StatefulWidget {
  @override
  _NewEventPageState createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  StreamController<int> _eventCountController = StreamController<int>();
  Stream<int> get eventCountStream => _eventCountController.stream;

  void _addEvent(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final eventName = eventProvider.eventNameController.text;
    final eventDescription = eventProvider.eventDescriptionController.text;
    final eventDate = eventProvider.selectedDate;

    // Add the event to the list
    eventProvider.addEvent(
      EventModel(
        eventName: eventName,
        eventDescription: eventDescription,
        eventDate: eventDate,
      ),
    );

    // Update the event count
    int totalEventCount = eventProvider.events.length;
    eventProvider.updateEventCount(totalEventCount);

    // Navigate back to the previous page (HomePage) with the added event data
    Navigator.pop(
      context,
      EventModel(
        eventName: eventName,
        eventDescription: eventDescription,
        eventDate: eventDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: eventProvider.eventNameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: eventProvider.eventDescriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: eventProvider.selectedDayController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selected Date',
                suffixIcon: IconButton(
                  onPressed: () => eventProvider.selectDate(context),
                  icon: Icon(Icons.calendar_today),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addEvent(context); // Call _addEvent method
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      home: NewEventPage(),
    ),
  );
}
