import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';

class NewEventPage extends StatefulWidget {
  final Function(EventModel) onNewEventAdded;

  const NewEventPage({super.key, required this.onNewEventAdded});
  @override
  _NewEventPageState createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();
  final TextEditingController eventCreatedByController =
      TextEditingController();
  final TextEditingController selectedDayController = TextEditingController();

  late DateTime selectedDate = DateTime.now();

  List<EventModel> globalEvents = [];

  @override
  void initState() {
    super.initState();
  }

  void _addEvent(BuildContext context) async {
    try {
      final eventName = eventNameController.text;
      final eventDescription = eventDescriptionController.text;
      final eventDate = selectedDate.toIso8601String();

      print('Event Name: $eventName');
      print('Event Description: $eventDescription');
      print('Event Date: $eventDate');

      if (eventName.isEmpty) {
        throw 'Please fill in the event name';
      }

      User? user = FirebaseAuth.instance.currentUser;
      print('Current User: $user');

      if (user == null) {
        throw 'User not authenticated';
      }

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('profile')
          .doc(user.uid)
          .get();
      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;
      String userEmail = userData['email'];
      print('User Email: $userEmail');

      final event = EventModel(
        eventName: eventName,
        eventDescription: eventDescription,
        eventDate: eventDate,
        createdBy: userEmail,
        isChecked: false,
      );

      print('Event Details: $event');

      DatabaseHelper.instance.insertEvent(event.toMap());
      widget.onNewEventAdded(event);

      print('Event added successfully');

      Navigator.pop(context);
      print('Navigating back to the previous page');
    } catch (error) {
      print('Error creating event: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create the event: $error')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        final formattedDate = DateFormat('EEEE, d - MM - y').format(picked);
        selectedDayController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: eventNameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: eventDescriptionController,
              decoration: const InputDecoration(labelText: 'Event Description'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: selectedDayController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selected Date',
                suffixIcon: IconButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Create Event button pressed');
                _addEvent(context);
              },
              child: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
