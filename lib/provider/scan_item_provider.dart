import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanItemProvider with ChangeNotifier {
  List<String> scannedData = [];
  Map<String, Map<String, dynamic>> codeDetails = {};
//  Map<String, Map<String, dynamic>> get codeDetails => _codeDetails;

  DateTime? lastSaved;
  // وظيفة لتحديث البيانات
  void updateCodeDetails(Map<String, Map<String, dynamic>> newCodeDetails) {
    codeDetails = newCodeDetails;
    notifyListeners();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    scannedData = prefs.getStringList('scannedData') ?? [];
    lastSaved = DateTime.tryParse(prefs.getString('lastSaved') ?? '');

    if (lastSaved != null &&
        DateTime.now().difference(lastSaved!).inHours >= 1) {
      scannedData.clear();
      codeDetails.clear();
      await prefs.remove('scannedData');
      await prefs.remove('codeDetails');
      await prefs.remove('lastSaved');
    } else {
      final codeDetailsStr = prefs.getString('codeDetails');
      if (codeDetailsStr != null) {
        codeDetails = Map<String, Map<String, dynamic>>.from(
          (await jsonDecode(codeDetailsStr)) as Map<String, dynamic>,
        );
        print('Loaded Code Details: $codeDetails');
      }
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('scannedData', scannedData);
    await prefs.setString('codeDetails', jsonEncode(codeDetails));

    await prefs.setString('lastSaved', DateTime.now().toIso8601String());
    notifyListeners();
  }

  void addScanData(String data, Map<String, dynamic> details) {
    scannedData.add(data);
    codeDetails[data] = details;
    saveData();
  }

  void removeScanData(String data) {
    scannedData.remove(data);
    codeDetails.remove(data);
    saveData();
  }

  Future<void> reloadData() async {
    await loadData();
  }

  /*
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
*/
}
