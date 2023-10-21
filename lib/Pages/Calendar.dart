import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyData {
  final int id;
  final String information;
  final String day;
  final String holidayDate;

  MyData({
    required this.id,
    required this.information,
    required this.day,
    required this.holidayDate,
  });

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
      id: json['id'],
      information: json['information'],
      day: json['day'],
      holidayDate: json['holiday_date'],
    );
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  String getEventText() {
    if (_selectedDay != null) {
      final selectedDate =
          "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";

      final eventData = holidayData.firstWhere(
        (data) => data.holidayDate == selectedDate,
        orElse: () => MyData(
          id: -1,
          information: "Tidak Ada Kegiatan",
          day: "",
          holidayDate: selectedDate,
        ),
      );

      return eventData.information;
    } else {
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchData2(); // Panggil fungsi fetchData2024
  }

  void fetchData() async {
    final apiUrl = 'https://kasekiru.com/api/liburan/oG37i2GyVq64zRGI';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is Map && jsonResponse.containsKey("data")) {
        final data = jsonResponse["data"];
        if (data is List) {
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
  }

  void fetchData2() async {
    final apiUrl = "https://kasekiru.com/api/liburan/JeiaFN39De20Snra";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is Map && jsonResponse.containsKey("data")) {
        final data = jsonResponse["data"];
        if (data is List) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Container(
              height: 200,
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(getEventText()),
              )),
        ],
      ),
    );
  }
}
