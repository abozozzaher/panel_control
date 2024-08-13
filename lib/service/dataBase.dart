import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'codes.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE code_details(code TEXT PRIMARY KEY, data TEXT)",
        );
        db.execute(
          "CREATE TABLE scanned_data(code TEXT PRIMARY KEY)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertCodeDetails(String code, String data) async {
    final db = await database;
    await db.insert(
      'code_details',
      {'code': code, 'data': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertScannedData(String code) async {
    final db = await database;
    await db.insert(
      'scanned_data',
      {'code': code},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getScannedData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scanned_data');
    return List.generate(maps.length, (i) {
      return maps[i]['code'] as String;
    });
  }

  Future<Map<String, dynamic>?> getCodeDetails(String code) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'code_details',
      where: "code = ?",
      whereArgs: [code],
    );
    if (maps.isNotEmpty) {
      return jsonDecode(maps.first['data'] as String);
    }
    return null;
  }

  Future<void> deleteCodeDetails(String code) async {
    final db = await database;
    await db.delete(
      'code_details',
      where: "code = ?",
      whereArgs: [code],
    );
    print('Deleted code details for code: $code');
  }

  Future<void> deleteScannedData(String code) async {
    final db = await database;
    await db.delete(
      'scanned_data',
      where: "code = ?",
      whereArgs: [code],
    );
    print('Deleted scanned data for code: $code');
  }
}


/*
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'scanned_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scannedData (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE codeDetails (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL,
            details TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertScannedData(String data) async {
    final db = await database;
    await db.insert('scannedData', {'data': data});
  }

  Future<void> insertCodeDetails(String data, String details) async {
    final db = await database;
    await db.insert('codeDetails', {'data': data, 'details': details});
  }

  Future<List<Map<String, dynamic>>> getScannedData() async {
    final db = await database;
    return await db.query('scannedData');
  }

  Future<List<Map<String, dynamic>>> getCodeDetails() async {
    final db = await database;
    return await db.query('codeDetails');
  }

  Future<void> deleteScannedData(String data) async {
    final db = await database;
    await db.delete('scannedData', where: 'data = ?', whereArgs: [data]);
  }

  Future<void> deleteCodeDetails(String data) async {
    final db = await database;
    await db.delete('codeDetails', where: 'data = ?', whereArgs: [data]);
  }
}
*/