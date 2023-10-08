import 'package:flutter/material.dart';

class NewEventPage extends StatefulWidget {
  @override
  _NewEventPageState createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  DateTime _selectedDate = DateTime.now();
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();
  TextEditingController _selectedDayController = TextEditingController();

  String? formattedDayOfWeek;
  String? formattedDay;
  String? formattedMonth;
  String? formattedYear;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        formattedDayOfWeek = _getDayOfWeek(picked.weekday);
        formattedDay = picked.day.toString().padLeft(2, '0');
        formattedMonth = picked.month.toString().padLeft(2, '0');
        formattedYear = picked.year.toString();

        _selectedDayController.text =
            '$formattedDayOfWeek, $formattedDay - $formattedMonth - $formattedYear';
      });
    }
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
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
              controller: _eventNameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _selectedDayController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selected Date',
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String eventName = _eventNameController.text;
                String eventDescription = _eventDescriptionController.text;
                DateTime eventDate = _selectedDate;

                // Tambahkan logika untuk menyimpan event
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
