// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugaskelompok/Pages/GetStart.dart';
import 'package:tugaskelompok/main.dart';
import 'package:localization/localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:tugaskelompok/Pages/NewEvent.dart';
import 'package:tugaskelompok/Drawer.dart';

void main() {

  //mengecek apakah tampilan loading/Get Start bisa berjalan dengan baik
  testWidgets('Testing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GetStart(),
    ));
    
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  });

  //mengecek apakah Drawer bisa muncul dan menampilkan data dengan benar atau tidak
  testWidgets('MyDrawer Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test App')),
        drawer: MyDrawer(
          email: 'test@example.com',
          logoutCallback: () {},
        ),
      ),
    ));
    //ketika loading tekan Icon menu untuk tampilkan drawer
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    //melihat apakah jika login sebagai test@example.com akan muncul nama tersebut di drawer atau tidak
    expect(find.text('test@example.com'), findsOneWidget);

    //memastikan bahwa terdapat menu menu yang sesuai
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Profiles'), findsNothing);
    expect(find.text('Login'), findsNothing);
  });

  //mengecek apakah ketika create event text input sudah sesuai atau belum
  testWidgets('NewEventPage Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NewEventPage(
        onNewEventAdded: (event) {},
      ),
    ));

    //melihat apakah pada menu Add Event sudah sesuai atau belum
    expect(find.text('Event Name'), findsOneWidget);
    expect(find.text('Event Description'), findsOneWidget);
    expect(find.text('Selected Date'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.text('Create Event'), findsOneWidget);
    expect(find.text('Event Event'), findsNothing);
  });

}