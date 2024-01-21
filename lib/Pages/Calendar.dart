import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';
import 'dart:convert';

class MyData {
  final int id;
  final String information;
  final String day;
  final String holidayDate;
  final String? eventName;

  MyData(
      {required this.id,
      required this.information,
      required this.day,
      required this.holidayDate,
      this.eventName});

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
        id: json['id'],
        information: json['information'],
        day: json['day'],
        holidayDate: json['holiday_date'],
        eventName: json['event_name']);
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<MyData> holidayData = [];
  List<EventModel> events = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });

    try {
      _getEventsForSelectedDay(selectedDay);
      _loadEvents();
    } catch (error) {
      print('Error updating events for selected day: $error');
    }
  }

  String getHolidayName(DateTime selectedDay) {
    final selectedDate =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    final holidayDataItem = holidayData.firstWhere(
      (data) => data.holidayDate == selectedDate,
      orElse: () => MyData(
        id: 0,
        information: "Tidak ada kegiatan",
        day: "",
        holidayDate: selectedDate,
      ),
    );

    final eventName = holidayDataItem.eventName;
    if (eventName != null && eventName.isNotEmpty) {
      return '$eventName\n${holidayDataItem.information}';
    } else {
      return holidayDataItem.information;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchData2();
    _loadEvents();
  }

  void fetchData() async {
    try {
      final apiUrl = "https://kasekiru.com/api/liburan/JeiaFN39De20Snra";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey("data")) {
          final data = jsonResponse["data"];
          if (data is List && mounted) {
            setState(() {
              holidayData = data.map((item) => MyData.fromJson(item)).toList();
            });
          } else {
            throw Exception('API response data is not a JSON array.');
          }
        } else {
          throw Exception('API response is missing the "data" key.');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void fetchData2() async {
    try {
      final apiUrl = 'https://kasekiru.com/api/liburan/oG37i2GyVq64zRGI';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey("data")) {
          final data = jsonResponse["data"];
          if (data is List && mounted) {
            setState(() {
              holidayData
                  .addAll(data.map((item) => MyData.fromJson(item)).toList());
            });
          } else {
            throw Exception('API response data is not a JSON array.');
          }
        } else {
          throw Exception('API response is missing the "data" key.');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            SizedBox(height: 20),
            _buildEventText(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventText() {
    return Container(
      height: 170,
      child: ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text(getHolidayName(_selectedDay ?? DateTime.now())),
      ),
    );
  }

  Future<void> _getEventsForSelectedDay(DateTime selectedDay) async {
    try {
      final selectedDate =
          "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

      print('Selected Date: $selectedDate');

      final eventData = events.firstWhere(
        (data) => data.eventDate == selectedDate,
        orElse: () => EventModel(
          eventName: "Tidak Ada Kegiatan",
          eventDescription: "",
          eventDate: selectedDate,
          isChecked: false,
        ),
      );

      print('Event Data: $eventData');

      setState(() {
        events = [eventData];
      });
    } catch (error) {
      print('Error getting events for selected day: $error');
    }
  }

  void _loadEvents() async {
    final eventsData = await DatabaseHelper.instance.queryAllEvents();
    setState(() {
      events = eventsData;
    });
  }
}
