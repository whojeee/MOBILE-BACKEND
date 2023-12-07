import 'package:flutter/material.dart';
import 'package:tugaskelompok/Pages/Auth/Login.dart';
import 'package:tugaskelompok/Pages/Loading.dart';
import 'Pages/Auth/auth.dart';
import 'botnav.dart';
import 'Pages/Calendar.dart';
import 'package:tugaskelompok/Pages/NewEvent.dart';
import 'Drawer.dart';
import 'Pages/Features.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:localization/localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await requestPermission();
  runApp(MyApp());
}

Future<void> requestPermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    // Jika izin belum diberikan, munculkan permintaan izin
    await Permission.storage.request();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  LocalJsonLocalization.delegate.directories=['lib/i18n'];
    return MaterialApp(
      supportedLocales:const[
        Locale('en','US'),
        Locale('id','ID'),
      ],
      localizationsDelegates:[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      localeResolutionCallback:(locale,supportedLocales){
        if(supportedLocales.contains(locale)){
          return locale;
        }
        return const Locale('id','ID');
      },
      title: 'Planner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoadingPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String? email;

  const MyHomePage({Key? key, required this.title, this.email});

  // const MyHomePage({required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  int eventCount = 0;
  late AuthFirebase auth;

  final List<Widget> _children = [HomePage(), CalendarPage(), Features()];
  StreamController<int> myNotificationStreamController =
      StreamController<int>.broadcast();
  @override
  void dispose() {
    super.dispose();
    myNotificationStreamController.close();
  }

  @override
  void initState() {
    super.initState();
    auth = AuthFirebase();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    await auth.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            SizedBox(width: 10),
            StreamBuilder<int>(
              stream: DatabaseHelper.instance.eventCountStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return Stack(
                    children: [
                      Icon(Icons.notifications),
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                          child: Text(
                            snapshot.data.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Icon(Icons.notifications);
                }
              },
            )
          ],
        ),
      ),
      drawer: MyDrawer(
        email: widget.email ?? "user@example.com",
        logoutCallback: _logout,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  int eventCount = 0;
  List<EventModel> events = [];
  bool _isNewEventAdded = false;
  StreamController<int> notificationStreamController = StreamController<int>();
  Stream<int> get notificationStream => notificationStreamController.stream;
  Sink<int> get notificationSink => notificationStreamController.sink;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    DatabaseHelper.instance.eventCountStream.listen((count) {
      setState(() {
        eventCount = count;
      });
    });
  }

  Future<void> _loadEventCount() async {
    DatabaseHelper.instance.eventCountStream.listen((count) {
      setState(() {
        eventCount = count;
        notificationSink.add(count); // Mengirim jumlah notifikasi ke stream
      });
    });
  }

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

  Future<void> _loadEvents() async {
    final eventsData = await DatabaseHelper.instance.queryAllEvents();
    print('loaded events : $eventsData');
    if (eventsData != null) {
      eventsData.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      setState(() {
        this.events = eventsData;
      });
    }
  }

  Widget _buildBody() {
    return events.isEmpty
        ? Center(child: Text('No-events-available'.i18n()))
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              String formattedDate = DateFormat('EEEE, d - MM - y')
                  .format(DateTime.parse(events[index].eventDate));

              return events[index].isChecked
                  ? SizedBox.shrink()
                  : Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: events[index].isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  _handleCheckboxChanged(index, value!);
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
                    );
            },
          );
  }

  void _handleAddButton() async {
    final addedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEventPage(
          onNewEventAdded: _handleNewEventAdded,
        ),
      ),
    );

    if (addedEvent != null) {
      await DatabaseHelper.instance.insertEvent(addedEvent.toMap());
      setState(() {
        events.add(addedEvent);
        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        DatabaseHelper.instance.updateEventCount();
      });
    }
  }

  void _handleCheckboxChanged(int index, bool value) async {
    print('Checkbox changed :$index,$value');
    if (value && events[index].id != null) {
      print("Deleting event with ID: ${events[index].id}");
      // Hapus event dari database
      await DatabaseHelper.instance.deleteEvent(events[index].id!);

      // Update jumlah notifikasi
      DatabaseHelper.instance.updateEventCount();
    }

    setState(() {
      events[index].isChecked = value;

      if (value) {
        // Hapus event dari list jika checkbox dicentang
        events.removeAt(index);
      }

      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    });
  }

  void _handleNewEventAdded(EventModel addedEvent) {
    setState(() {
      events.add(addedEvent);
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    });

    DatabaseHelper.instance.updateEventCount();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            _handleAddButton();
          },
          child: Icon(Icons.create),
        ),
      ),
    );
  }
}
