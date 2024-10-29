import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class InvoiceProvider with ChangeNotifier {
  List<String> _selectedDocumentIds = []; // For storing selected item IDs

  Map<String, Map<String, dynamic>> _selectedItemData =
      {}; // Storing document data

  List<String> get selectedDocumentIds => _selectedDocumentIds;
  Map<String, Map<String, dynamic>> get selectedItemData => _selectedItemData;

//  final DatabaseHelper _databaseHelper = DatabaseHelper();

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

// من هون ولفوق للحذف لاحقاً
  Map<String, dynamic> itemsData = {};
  Map<String, bool> selectionState = {};

  // هذه لحفظ البيانات التي تعمل فاتش في الفاتورة تفاصيل العناصر
  final Map<String, Map<String, dynamic>> _cachedData = {};
  Map<String, Map<String, dynamic>> get cachedData => _cachedData;

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
  // دالة لجلب البيانات من قاعدة البيانات

  Map<String, dynamic>? getCachedData(String docId) {
    return _cachedData[docId];
  }
  // دالة لتحديث البيانات في قاعدة البيانات

  void cacheData(String docId, Map<String, dynamic> data) {
    _cachedData[docId] = data;
    notifyListeners();
  }

  // هذه لحساب مجموع السعر وحفظه في البروفيدر
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, ValueNotifier<String>> _totalPriceNotifiers = {};

  // Get a price controller for a specific key
  TextEditingController getPriceController(String key) {
    if (!_priceControllers.containsKey(key)) {
      _priceControllers[key] = TextEditingController();
    }
    return _priceControllers[key]!;
  }

  // Get a total price notifier for a specific key
  ValueNotifier<String> getTotalPriceNotifier(String key) {
    if (!_totalPriceNotifiers.containsKey(key)) {
      _totalPriceNotifiers[key] = ValueNotifier<String>('0.00');
    }
    return _totalPriceNotifiers[key]!;
  }

  // Calculate the grand total price
  double calculateGrandTotalPrice() {
    return _totalPriceNotifiers.entries.fold(0.0, (sum, entry) {
      return sum + (double.tryParse(entry.value.value) ?? 0.0);
    });
  }

  // خريطة لتخزين الأسعار حسب المجموعة
  final Map<String, double> _prices = {};

  // دالة لتحديث السعر المرتبط بالمجموعة
  void setPrice(String groupKey, double price) {
    _prices[groupKey] = price;
    //notifyListeners();
  }

  // دالة لجلب السعر المرتبط بالمجموعة
  double getPrice(String groupKey) {
    return _prices[groupKey] ?? 0.00;
  }

  final Map<String, bool> _selectionState = {}; // لتخزين حالة التحديد

  // الطريقة لتحديث حالة التحديد
  void updateSelectionState(String key, bool isSelected) {
    _selectionState[key] = isSelected;
    // notifyListeners();
  }

  bool? getSelectionState(String key) => _selectionState[key];

  // Clear all controllers and notifiers (if needed)
  void clear() {
    _priceControllers.clear();
    _totalPriceNotifiers.clear();
    itemsData.clear();
    selectionState.clear();
    _prices.clear();

    notifyListeners();
  }
}
