import '../Model/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseInstance {
  Database? _database;

  //database
  final String _myDatabase = 'user.db';
  final int _databaseVersion = 1;
  final String table = 'user';

  Future<Database> init() async {
    if (_database != null) return _database!;

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, _myDatabase);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $table (id INTEGER PRIMARY KEY, username TEXT, nama TEXT)');
  }

  Future insert(User row) async {
    try {
      final int queryResult = await _database!.insert(table, row.toJson());
      print('$row berhasil di tambahkan');
      print(queryResult);
    } catch (e) {
      print('error $e');
      rethrow;
    }
  }

  Future<List<User>> fetch() async {
    try {
      _database ??= await init();
      List<Map<String, dynamic>> queryResult = await _database!.query(table);
      List<User> result = queryResult.map((e) => User.fromJson(e)).toList();
      return result;
    } catch (e) {
      print('error $e');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _database!.delete(table, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('error : $e');
      rethrow;
    }
  }

  Future update(User row) async {
    try {
      print('ini di upadte');
      await _database!.update(table, row.toJson(),
          where: 'username = ?', whereArgs: [row.username]);
    } catch (e) {
      print('error $e');
      rethrow;
    }
  }
}
