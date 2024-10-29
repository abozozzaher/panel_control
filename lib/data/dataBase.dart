import '../service/toasts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:convert';

import '../model/clien.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;
  // الكود من هنا الى الاخير لا يوجد له استخدام
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
          'CREATE TABLE code_details (id INTEGER PRIMARY KEY, data TEXT)',
          //  "CREATE TABLE code_details(code TEXT PRIMARY KEY, data TEXT)",
        );
        db.execute(
          'CREATE TABLE scanned_data (id INTEGER PRIMARY KEY, data TEXT)',
          //  "CREATE TABLE scanned_data(code TEXT PRIMARY KEY)",
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
      return result.first;
    } else {
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
    showToast('Deleted code details for code: #401 $code');

    print('Deleted code details for code: $code');
  }

  Future<void> deleteScannedData(String code) async {
    final db = await database;
    await db.delete(
      'scanned_data',
      where: "code = ?",
      whereArgs: [code],
    );
    showToast('Deleted scanned data for code: #400 $code');

    print('Deleted scanned data for code: $code');
  }

  /// حتى هنا لا يوجد له اي اي اي استخدام للحذف
// لكشف المخزون تخزين البيانات في قاعدة البيانات المحلية فقط في الموبيل
  Future<Database> _openDatabaseInventory() async {
    // فتح قاعدة البيانات
    return openDatabase(
      join(await getDatabasesPath(), 'inventoryProducts_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE inventoryProducts(id TEXT PRIMARY KEY, yarn_number TEXT, type TEXT, color TEXT, width TEXT, total_weight REAL, quantity INTEGER, length INTEGER, scanned_data INTEGER)',
        );
      },
      version: 1,
    );
  }

// التحقق من وجود البيانات في SQLite
  Future<List<Map<String, dynamic>>> checkProductsInDatabaseInventory(
      List<String> keys) async {
    final Database db = await _openDatabaseInventory();
    List<Map<String, dynamic>> results = [];

    for (String key in keys) {
      List<Map<String, dynamic>> queryResult = await db.query(
        'inventoryProducts',
        where: 'id = ?',
        whereArgs: [key],
      );
      results.addAll(queryResult);
    }

    return results;
  }

// حفظ البيانات في SQLite
  Future<void> saveProductToDatabaseInventory(
      Map<String, dynamic> productData, String id) async {
    final Database db = await _openDatabaseInventory();
    await db.insert(
      'inventoryProducts',
      {
        'productId': id,
        'yarn_number': productData['yarn_number'],
        'type': productData['type'],
        'color': productData['color'],
        'width': productData['width'],
        'total_weight': productData['total_weight'],
        'quantity': productData['quantity'],
        'length': productData['length'],
        'scanned_data': productData['scanned_data'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    showToast('Data saved: #404 $productData');

    print('Data saved: $productData');
  }

// لم اعد استخدم ماكتبة حفظ البيانات التاجر في قاعدة البيانات المحلية
// لحفظ معلومات من التاجر
  Future<Database> _openDatabaseTraders() async {
    return openDatabase(
      join(await getDatabasesPath(), 'traders_database.db'), // اسم القاعدة هنا
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE traders(fullNameArabic TEXT, fullNameEnglish TEXT, country TEXT, state TEXT, city TEXT, address TEXT, phoneNumber TEXT, createdAt TEXT, codeIdClien TEXT PRIMARY KEY)',
        );
      },
      version: 1,
    );
  }

  Future<void> deleteDatabaseTraders() async {
    final dbPath = await getDatabasesPath();
    final databasePath = join(dbPath, 'traders_database.db');
    await databaseFactory.deleteDatabase(databasePath);
    print(databasePath);
  }

  Future<List<Map<String, dynamic>>> checkClientsInDatabaseTraders() async {
    final Database db = await _openDatabaseTraders();
    return await db.query('traders');
  }

  Future<void> saveClientToDatabaseTraders(ClienData clientData) async {
    final Database db = await _openDatabaseTraders();
    await db.insert(
      'traders',
      clientData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    showToast('Data saved traders : #402 $clientData');

    print('Data saved traders : $clientData');
  }
}
