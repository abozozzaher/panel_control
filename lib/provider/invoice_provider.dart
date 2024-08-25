import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceProvider with ChangeNotifier {
  List<String> _selectedDocumentIds = []; // For storing selected item IDs

  Map<String, Map<String, dynamic>> _selectedItemData =
      {}; // Storing document data

  List<String> get selectedDocumentIds => _selectedDocumentIds;
  Map<String, Map<String, dynamic>> get selectedItemData => _selectedItemData;

  void setSelectedItemData(String documentId, Map<String, dynamic> itemData) {
    _selectedItemData[documentId] = itemData;
    notifyListeners();
  }

  // Add a document ID and its data
  Future<void> addDocumentData(
      String documentId, Map<String, dynamic> data) async {
    _selectedDocumentIds.add(documentId);
    _selectedItemData[documentId] = data;
    await saveSelectedItems();
    await saveSelectedItemData();
    notifyListeners();
  }

  // Remove a specific document from the provider
  Future<void> removeDocument(String documentId) async {
    _selectedDocumentIds.remove(documentId);
    _selectedItemData.remove(documentId);
    await saveSelectedItems();
    await saveSelectedItemData();
    notifyListeners();
  }

  // Update the data for a specific document
  Future<void> updateDocumentData(
      String documentId, Map<String, dynamic> updatedData) async {
    if (_selectedItemData.containsKey(documentId)) {
      _selectedItemData[documentId] = updatedData;
      await saveSelectedItemData();
      notifyListeners();
    }
  }

  // Save selected items to SharedPreferences
  Future<void> saveSelectedItems() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedDocumentIds', _selectedDocumentIds.toList());
  }

  // Save selected item data to SharedPreferences
  Future<void> saveSelectedItemData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedItemData', jsonEncode(_selectedItemData));
  }

  // Load selected items from SharedPreferences
  Future<void> loadSelectedItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedItems = prefs.getStringList('selectedDocumentIds');
    _selectedDocumentIds = savedItems ?? [];
    notifyListeners();
  }

  // Load selected item data from SharedPreferences
  Future<void> loadSelectedItemData() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('selectedItemData');
    _selectedItemData = encodedData != null ? jsonDecode(encodedData) : {};
    notifyListeners();
  }

  // Delete selected items and data from SharedPreferences
  Future<void> deleteData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedDocumentIds');
    await prefs.remove('selectedItemData');
    _selectedDocumentIds.clear();
    _selectedItemData.clear();
    notifyListeners();
  }

  // Check if a document ID is already selected
  bool isDocumentSelected(String documentId) {
    return _selectedDocumentIds.contains(documentId);
  }

  // Clear all selected documents and their data
  void clearAllData() {
    _selectedDocumentIds.clear();
    _selectedItemData.clear();
    notifyListeners();
  }

/*
  // خريطة لتخزين حالة التحديد لكل عنصر
  Map<String, bool> _selectionState = {};

  // خريطة لتخزين بيانات العناصر والمستندات

  // دالة للحصول على حالة التحديد
  Map<String, bool> get selectionState => _selectionState;
  // خريطة لتخزين بيانات العناصر وحالتها
  Map<String, Map<String, dynamic>> _itemsData = {};

  // دالة للحصول على بيانات العناصر
  Map<String, Map<String, dynamic>> get itemsData => _itemsData;
  // دالة للحصول على بيانات العناصر

  // دالة لتحديث حالة التحديد
  void setSelectionState(Map<String, bool> selectionState,
      Map<String, Map<String, dynamic>> itemsData) {
    _selectionState = selectionState;
    _itemsData = itemsData;
    notifyListeners();
  }
 

  // دالة لتحديث بيانات العناصر
  void setItemsData(Map<String, Map<String, dynamic>> itemsData) {
    _itemsData = itemsData;
    notifyListeners();
  }
 */
  Map<String, dynamic> itemsData = {};
  Map<String, bool> selectionState = {};

  // دالة لجلب البيانات بناءً على الـ id
  Map<String, dynamic>? getDataById(String id) {
    return itemsData[id];
  }

  // دالة لتحديث حالة الاختيار
  void setSelectionState(
      Map<String, bool> newSelectionState, Map<String, dynamic> newItemsData) {
    selectionState = newSelectionState;
    itemsData = newItemsData;
    notifyListeners();
  }
}
