import 'package:flutter/material.dart';
import 'botnav.dart';
import 'package:tugaskelompok/utils/key_sharedpreference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: GetStart(),
    );
  }
}

class GetStart extends StatefulWidget {
  const GetStart({super.key});

  @override
  State<GetStart> createState() => _GetStartState();
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _GetStartState extends State<GetStart> {
  late SharedPreferences _pref;
  bool pernahMasuk = false;

  void checkApp() async {
    _pref = await SharedPreferences.getInstance();
    pernahMasuk = _pref.getBool(KeyStore.pernahMasuk) ?? false;
    if (pernahMasuk == true) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return const MyHomePage(title: 'Planner');
        },
      ));
    }
  }

  @override
  void initState() {
    checkApp();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Get Start Screen")),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              _pref = await SharedPreferences.getInstance();
              _pref.setBool(KeyStore.pernahMasuk, true);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return MyHomePage(
                    title: "Planner",
                  );
                },
              ));
            },
            child: const Text("Get Start")),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomePage(),
    CalendarPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleAddButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddButton,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}
