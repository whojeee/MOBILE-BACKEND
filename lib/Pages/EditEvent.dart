import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';

class EditEventPage extends StatefulWidget {
  final EventModel initialEvent;

  EditEventPage({required this.initialEvent});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController _eventNameController;
  late TextEditingController _eventDescriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _eventNameController =
        TextEditingController(text: widget.initialEvent.eventName);
    _eventDescriptionController =
        TextEditingController(text: widget.initialEvent.eventDescription);
    _selectedDate = DateTime.parse(widget.initialEvent.eventDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
            ),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text(
                    'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                EventModel updatedEvent = EventModel(
                  id: widget.initialEvent.id,
                  eventName: _eventNameController.text,
                  eventDescription: _eventDescriptionController.text,
                  eventDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  isChecked: widget.initialEvent.isChecked,
                );

                Navigator.pop(context, updatedEvent);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
