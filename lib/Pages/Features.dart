import 'package:flutter/material.dart';
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

class GetHoliday extends StatefulWidget {
  final List<String> apiLinks;

  GetHoliday({required this.apiLinks});

  @override
  _GetHolidayState createState() => _GetHolidayState();
}

class _GetHolidayState extends State<GetHoliday> {
  late String selectedApiLink;

  @override
  void initState() {
    super.initState();
    // Set the default API link when the widget initializes
    selectedApiLink = widget.apiLinks[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday List'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to the previous screen (Features)
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          // Generate chips based on the provided API links
          Wrap(
            children: widget.apiLinks.map((apiLink) {
              final year = apiLink == selectedApiLink ? '2023' : '2024';
              return ActionChip(
                label: Text(year),
                onPressed: () {
                  // Update the selected API link
                  setState(() {
                    selectedApiLink = apiLink;
                  });
                },
              );
            }).toList(),
          ),
          // Add a container for displaying holiday data
          Container(
            child: FutureBuilder<List<MyData>>(
              future: fetchData(selectedApiLink),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final data = snapshot.data;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index].information),
                        subtitle: Text(data[index].holidayDate),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<MyData>> fetchData(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is Map && jsonResponse.containsKey("data")) {
        final data = jsonResponse["data"];
        if (data is List) {
          return data.map((item) => MyData.fromJson(item)).toList();
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
}

class Features extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2, // 2 cards per row
        children: [
          _FeatureCard(
            title: "Holiday's date",
            color: Colors.blue,
            borderColor: Colors.greenAccent,
            onTap: () {
              // Navigate to the GetHoliday screen
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return GetHoliday(apiLinks: [
                  "https://kasekiru.com/api/liburan/oG37i2GyVq64zRGI", // 2023
                  "https://kasekiru.com/api/liburan/JeiaFN39De20Snra", // 2024
                ]);
              }));
            },
            icon: Icons.star,
          ),
          _FeatureCard(
            title: 'Feature 2',
            color: Colors.red,
            borderColor: Colors.orange,
            onTap: () {
              // Handle tap on Feature 2
            },
            icon: Icons.settings,
          ),
          _FeatureCard(
            title: 'Feature 3',
            color: Colors.yellow,
            borderColor: Colors.pink,
            onTap: () {
              // Handle tap on Feature 3
            },
            icon: Icons.camera_alt,
          ),
          _FeatureCard(
            title: 'Feature 4',
            color: Colors.purple,
            borderColor: Colors.teal,
            onTap: () {
              // Handle tap on Feature 4
            },
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
  final IconData icon;

  _FeatureCard({
    required this.title,
    required this.color,
    required this.borderColor,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: borderColor, width: 2.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 45,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
