import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localization/localization.dart  ';
import 'package:permission_handler/permission_handler.dart';
import 'package:tugaskelompok/Pages/loading.dart';
import 'package:tugaskelompok/Pages/all_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await requestPermission();

  bool isPremiumUser = false;

  runApp(MyApp(
    isPremiumUser: isPremiumUser,
  ));
}

Future<void> requestPermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

class MyApp extends StatelessWidget {
  final bool isPremiumUser;

  const MyApp({Key? key, required this.isPremiumUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return MaterialApp(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
        Locale('ja', 'JP'),
        Locale('it', 'IT'),
        Locale('ko', 'KR'),
        Locale('zh', 'CN'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }
        return const Locale('id', 'ID');
      },
      title: 'Planner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (_) =>
            MainPage(title: "Daily-Minder".i18n(), isPremiumUser: isPremiumUser)
      },
      home: LoadingPage(
        isPremiumUser: isPremiumUser,
      ),
    );
  }
}
