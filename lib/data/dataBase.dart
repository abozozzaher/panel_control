import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../model/clien.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
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

  Future<void> insertTraderCodeDetails(String code, String data) async {
    final db = await database;
    await db.insert(
      'code_details',
      {'code': code, 'data': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getTraderCodeDetails(String code) async {
    final db = await database;
    final result =
        await db.query('code_details', where: 'code = ?', whereArgs: [code]);
    if (result.isNotEmpty) {
      print('Data found: ${result.first}');
      return result.first;
    } else {
      print('No data found');
      return null;
    }
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
