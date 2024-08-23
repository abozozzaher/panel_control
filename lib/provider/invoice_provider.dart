import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceProvider with ChangeNotifier {
  List<String> _selectedDocumentIds = [];
  List<DocumentSnapshot> _selectedDocuments = [];

  List<String> get selectedDocumentIds => _selectedDocumentIds;
  List<DocumentSnapshot> get selectedDocuments => _selectedDocuments;

  void setSelectedItems(List<String> items) {
    _selectedDocumentIds = items;
    notifyListeners();
  }

  void setSelectedDocuments(
      List<String> documentIds, List<DocumentSnapshot> documents) {
    _selectedDocumentIds = documentIds;
    _selectedDocuments = documents;
    notifyListeners();
  }

  Future<void> saveSelectedItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedItems', items);
  }

  Future<List<String>> loadSelectedItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selectedItems') ?? [];
  }
}
