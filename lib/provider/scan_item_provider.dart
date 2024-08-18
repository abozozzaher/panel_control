import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:convert';

import '../data/dataBase.dart';

class ScanItemProvider with ChangeNotifier {
  final List<String> _scannedData = [];

  List<String> get scannedData => _scannedData;
  final Map<String, Map<String, dynamic>> _codeDetails = {};
  Map<String, Map<String, dynamic>> get codeDetails => _codeDetails;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> addCodeDetails(String code) async {
    final data = await _databaseHelper.getCodeDetails(code);
    if (data != null) {
      _codeDetails[code] = data;
      notifyListeners();
    }
  }

  Future<void> saveCodeDetails(
      String code, Map<String, dynamic> details) async {
    await _databaseHelper.insertCodeDetails(code, jsonEncode(details));
    _codeDetails[code] = details;
    notifyListeners();
  }

  Future<void> addScannedData(String code) async {
    if (!_scannedData.contains(code)) {
      _scannedData.add(code);
      await _databaseHelper.insertScannedData(code);
      notifyListeners();
    }
  }

  Future<void> loadScannedData() async {
    final List<String> loadedData = await _databaseHelper.getScannedData();
    _scannedData.addAll(loadedData);
    notifyListeners();
  }

  Future<void> deleteCodeDetails(String code) async {
    await _databaseHelper.deleteCodeDetails(code);
    _codeDetails.remove(code);
    notifyListeners();
  }

  Future<void> deleteScannedData(String code) async {
    await _databaseHelper.deleteScannedData(code);
    _scannedData.remove(code);
    notifyListeners();
  }

  void removeData(String data) async {
    _codeDetails.remove(data);
    _scannedData.remove(data);

    final dbHelper = DatabaseHelper();
    await dbHelper.deleteScannedData(data);
    await dbHelper.deleteCodeDetails(data);

    notifyListeners();
  }
}
