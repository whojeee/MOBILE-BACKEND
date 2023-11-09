import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';

class NewEventPage extends StatefulWidget {
  final Function(EventModel) onNewEventAdded; // Tambahkan ini

  NewEventPage({required this.onNewEventAdded});
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

  @override
  void initState() {
    super.initState();
  }

  void _addEvent(BuildContext context) async {
    final eventName = eventNameController.text;
    final eventDescription = eventDescriptionController.text;
    final createdBy = eventCreatedByController.text;
    final eventDate = selectedDate.toIso8601String();

    final event = EventModel(
      eventName: eventName,
      eventDescription: eventDescription,
      eventDate: eventDate,
      createdBy: createdBy,
      isChecked: false, // Default value for isChecked
    );

    try {
      await DatabaseHelper.instance.insertEvent(event.toMap());
      Navigator.pop(context, event);
      widget.onNewEventAdded(event);
    } catch (error) {
      print('Database insertion error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create the event')),
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
        title: Text('New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: eventNameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: eventDescriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
            ),
            TextField(
              controller: eventCreatedByController,
              decoration: InputDecoration(labelText: 'Created By'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: selectedDayController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selected Date',
                suffixIcon: IconButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addEvent(context);
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
