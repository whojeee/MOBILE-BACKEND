import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:tugaskelompok/Tools/Model/event_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  final StreamController<int> _eventCountController =
      StreamController<int>.broadcast();
  Stream<int> get eventCountStream => _eventCountController.stream;
  StreamController<int> _eventCountStreamController =
      StreamController<int>.broadcast();
  bool _isEventCountStreamInitialized = false;

  void initEventCountStream(String email) async {
    if (!_isEventCountStreamInitialized) {
      _eventCountStreamController = StreamController<int>();
      try {
        int eventCount = await fetchEventCountFromDatabase(email);
        _eventCountStreamController.sink.add(eventCount);

        // Listen for changes and update the main controller
        _eventCountStreamController.stream.listen((count) {
          _eventCountController.sink.add(count);
        });

        _isEventCountStreamInitialized = true;
      } catch (e) {
        print("Error initializing event count stream: $e");
      }
    }
  }

  void dispose() {
    _eventCountController.close();
    _eventCountStreamController.close();
  }

  Future<int> fetchEventCountFromDatabase(String email) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM events WHERE createdBy = ? AND isChecked = 0',
      [email],
    );

    return Sqflite.firstIntValue(result) ?? 0;
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
    return await db.insert('events', row);
  }

  Future<List<EventModel>> queryAllEvents(String email) async {
    final db = await instance.database;
    final result =
        await db.query('events', where: 'createdBy = ?', whereArgs: [email]);
    return result.map((e) => EventModel.fromMap(e)).toList();
  }

  Future<int> updateEvent(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('events', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateEventChecked(int id, Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final int updatedRows =
          await db.update('events', row, where: 'id = ?', whereArgs: [id]);
      if (updatedRows > 0) {
        // Only update the event count if the update was successful
        await updateEventCount(row['createdBy']);
      }
      return updatedRows;
    } catch (e) {
      print('Error updating event: $e');
      return 0;
    }
  }

  Future<void> updateEventCount(String email) async {
    final count = await fetchEventCountFromDatabase(email);
    _eventCountController.add(count);
  }

  Future<int> queryEventCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM events');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
