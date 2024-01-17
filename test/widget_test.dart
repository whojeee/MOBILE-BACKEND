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
import 'package:localization/localization.dart  ';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tugaskelompok/Pages/Auth/Login.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/main.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  testWidgets('Testing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GetStart(),
    ));

    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  });
  //   testWidgets('Test Text Widget', (WidgetTester tester) async {
  //   await tester.pumpWidget(const MyApp());

  //   expect(find.text('COUNTER'), findsOneWidget);
  //   expect(find.text('Dec'), findsOneWidget);
  //   expect(find.text('Kurang'), findsNothing);
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsOneWidget);
  //   expect(find.text('Inc'), findsOneWidget);
  //   expect(find.text('Tambah'), findsNothing);
  //   expect(find.text('REVERSE TEXT'), findsOneWidget);
  //   expect(find.text('Reverse'), findsOneWidget);
  // });

  // testWidgets('Test Counter', (WidgetTester tester) async {
  //   await tester.pumpWidget(const MyApp());

  //   expect(find.text('0'), findsOneWidget);

  //   await tester.tap(find.byKey(Key("btnInc")));
  //   await tester.pump();

  //   expect(find.text('1'), findsOneWidget);

  //   await tester.tap(find.widgetWithText(ElevatedButton, 'Dec'));
  //   await tester.tap(find.widgetWithText(ElevatedButton, 'Dec'));
  //   await tester.pump();

  //   expect(find.text('1'), findsNothing);
  //   expect(find.text('-1'), findsOneWidget);
  // });

  // testWidgets('Test Reverse Text', (WidgetTester tester) async {
  //   await tester.pumpWidget(const MyApp());

  //   expect(find.byType(TextField), findsOneWidget);

  //   await tester.enterText(find.byType(TextField), 'Back End Flutter');
  //   await tester.tap(find.widgetWithText(ElevatedButton, 'Reverse'));
  //   await tester.pump();

  //   expect(find.text('rettulF dnE kcaB'), findsOneWidget);
  // });

  // testWidgets('Super Increment', (WidgetTester tester) async {
  //   await tester.pumpWidget(const MyApp());

  //   await tester.tap(find.widgetWithText(ElevatedButton, '+'));
  //   await tester.pump();

  //   expect(find.text('2'), findsOneWidget);
  // });

  // testWidgets('Super Decrement', (WidgetTester tester) async {
  //   await tester.pumpWidget(const MyApp());

  //   await tester.tap(find.widgetWithText(ElevatedButton, '+'));
  //   await tester.tap(find.widgetWithText(ElevatedButton, '+'));
  //   await tester.tap(find.widgetWithText(ElevatedButton, '+'));
  //   await tester.tap(find.widgetWithText(ElevatedButton, 'Dec'));
  //   await tester.pump();

  //   expect(find.text('-4'), findsOneWidget);
  // });
}
