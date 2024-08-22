import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DocumentProvider with ChangeNotifier {
  List<String> _selectedDocumentIds = [];
  List<DocumentSnapshot> _selectedDocuments = [];

  List<String> get selectedDocumentIds => _selectedDocumentIds;
  List<DocumentSnapshot> get selectedDocuments => _selectedDocuments;

  void setSelectedDocuments(
      List<String> documentIds, List<DocumentSnapshot> documents) {
    _selectedDocumentIds = documentIds;
    _selectedDocuments = documents;
    notifyListeners();
  }
}
