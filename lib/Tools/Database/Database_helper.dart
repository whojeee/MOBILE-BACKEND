import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:tugaskelompok/Tools/Model/event_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  StreamController<int> _eventCountController =
      StreamController<int>.broadcast();
  Stream<int> get eventCountStream => _eventCountController.stream;
  StreamController<int> _eventCountStreamController =
      StreamController<int>.broadcast();

  // Definisikan getter untuk stream

  void initEventCountStream() async {
    try {
      // Di sini Anda dapat menghubungkannya ke database dan mengambil jumlah acara
      int eventCount =
          await fetchEventCountFromDatabase(); // Contoh fungsi pengambilan jumlah acara dari database

      // Kemudian mengirimkannya ke stream
      _eventCountStreamController.sink.add(eventCount);
    } catch (e) {
      // Tangani jika terjadi kesalahan saat mengambil jumlah acara dari database
      print("Error initializing event count stream: $e");
    }
  }

  Future<int> fetchEventCountFromDatabase() async {
    // Di sini Anda harus mengambil jumlah acara dari database
    // Contoh sederhana: Mengembalikan jumlah acara dari database
    return 10; // Misalnya, kembalikan jumlah acara dari database
  }

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

  Future<List<EventModel>> queryCheckedEvents() async {
    final db = await instance.database;
    final result =
        await db.query('events', where: 'isChecked = ?', whereArgs: [1]);
    return result.map((e) => EventModel.fromMap(e)).toList();
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

  Future<List<EventModel>> queryAllEvents() async {
    final db = await instance.database;
    final result = await db.query('events');
    return result.map((e) => EventModel.fromMap(e)).toList();
  }

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

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
