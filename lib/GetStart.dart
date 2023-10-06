import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugaskelompok/utils/key_sharedpreference.dart';
import 'main.dart';

class GetStart extends StatefulWidget {
  const GetStart({super.key});

  @override
  State<GetStart> createState() => _GetStartState();
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
