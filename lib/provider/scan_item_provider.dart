import 'dart:convert'; // لتشفير وفك تشفير JSON
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanItemProvider with ChangeNotifier {
  List<String> _scannedData = [];
  List<String> get scannedData => _scannedData;

  Map<String, Map<String, dynamic>> codeDetails = {};
  final String scannedDataKey = 'scannedDataKey';
  final String codeDetailsKey = 'codeDetailsKey';
  final int expirationDuration = 3600; // 1 ساعة بالثواني

  ScanItemProvider() {
    _loadData();
  }
  void addData(String newData) {
    if (!_scannedData.contains(newData)) {
      _scannedData.add(newData);
      saveToSharedPreferences();
      notifyListeners();
    }
  }

  void loadFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _scannedData = prefs.getStringList('scannedData') ?? [];
    notifyListeners();
  }

  void saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('scannedData', _scannedData);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScannedData = prefs.getStringList(scannedDataKey) ?? [];
    final savedCodeDetailsString = prefs.getString(codeDetailsKey) ?? '{}';

    _scannedData = savedScannedData;
    codeDetails = Map<String, Map<String, dynamic>>.from(
        json.decode(savedCodeDetailsString) as Map);

    // تحقق من صلاحية البيانات
    await _checkDataValidity();
    notifyListeners();
  }

  Future<void> _checkDataValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    final expirationTime = prefs.getDouble('expirationTime') ?? 0;

    if (currentTime > expirationTime) {
      await clearAll();
    }
  }

  Future<void> clearAll() async {
    scannedData.clear();
    codeDetails.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(scannedDataKey);
    await prefs.remove(codeDetailsKey);
    await prefs.remove('expirationTime');
    notifyListeners();
  }
}
