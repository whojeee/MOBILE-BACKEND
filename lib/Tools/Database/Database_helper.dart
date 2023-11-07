import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:tugaskelompok/Tools/Model/event_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Create a StreamController to handle event count updates
  // StreamController<int> _eventCountController = StreamController<int>();
  // Stream<int> get eventCountStream => _eventCountController.stream;

  StreamController<int> _eventCountController =
      StreamController<int>.broadcast();
  Stream<int> get eventCountStream => _eventCountController.stream;

  Future<void> updateEventCount() async {
    final count = await queryEventCount();
    _eventCountController.add(count);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'events_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY,
        eventName TEXT,
        eventDescription TEXT,
        eventDate TEXT,
        createdBy TEXT,
        isChecked INTEGER
      )
    ''');
  }

  Future<int> insertEvent(Map<String, dynamic> row) async {
    final db = await instance.database;
    // final id = await db.insert('events', row);

    // // Increment the event count and notify listeners
    // _eventCountController.add(await eventCountStream.first + 1);

    // return id;
    return await db.insert('events', row);
  }

  Future<List<EventModel>> queryAllEvents() async {
    final db = await instance.database;
    final result = await db.query('events');
    return result.map((e) => EventModel.fromMap(e)).toList();
  }

  // Future<List<Map<String, dynamic>>> queryAllEvents() async {
  //   final db = await instance.database;
  //   return await db.query('events');
  // }

  Future<int> updateEvent(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('events', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> queryEventCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM events');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

// Future<List<Map<String, dynamic>>?> queryAllEvents() async {
//   // Assuming you have a database reference named 'db'.
//   final db = await openDatabase('your_database.db');

//   // Query all events from the database.
//   final List<Map<String, dynamic>> result = await db.query('events');

//   // Close the database.
//   await db.close();

//   return result;
// }
