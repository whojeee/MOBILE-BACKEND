import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Tools/Model/event_model.dart';

class EventProvider with ChangeNotifier {
  final StreamController<int> _eventCountController = StreamController<int>();

  Stream<int> get eventCountStream => _eventCountController.stream;

  void updateEventCount(int count) {
    _eventCountController.sink.add(count);
  }

  @override
  void dispose() {
    _eventCountController.close();
    super.dispose();
  }

  DateTime _selectedDate = DateTime.now();
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();
  TextEditingController _selectedDayController = TextEditingController();

  String? formattedDayOfWeek;
  String? formattedDay;
  String? formattedMonth;
  String? formattedYear;

  // Getter methods for accessing the state
  DateTime get selectedDate => _selectedDate;
  TextEditingController get eventNameController => _eventNameController;
  TextEditingController get eventDescriptionController =>
      _eventDescriptionController;
  TextEditingController get selectedDayController => _selectedDayController;

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      formattedDayOfWeek = _getDayOfWeek(picked.weekday);
      formattedDay = picked.day.toString().padLeft(2, '0');
      formattedMonth = picked.month.toString().padLeft(2, '0');
      formattedYear = picked.year.toString();

      _selectedDayController.text =
          '$formattedDayOfWeek, $formattedDay - $formattedMonth - $formattedYear';
      notifyListeners();
    }
  }

  List<EventModel> _events = [];

  List<EventModel> get events => _events;

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
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

  // Add your logic to save the event
  void saveEvent() {
    String eventName = _eventNameController.text;
    String eventDescription = _eventDescriptionController.text;
    DateTime eventDate = _selectedDate;

    // Tambahkan logika untuk menyimpan event
    // You can implement the logic to save the event here
    // For example, add it to a list or a database
  }
}
