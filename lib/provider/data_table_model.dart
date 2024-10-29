import 'package:flutter/material.dart';

//للمسح لا يوجد لها استخدم
class TableDataProvider with ChangeNotifier {
  final List<DataRow> _confirmedRows = [];
  DataRow? _temporaryRow;

  List<DataRow> get confirmedRows => _confirmedRows;
  DataRow? get temporaryRow => _temporaryRow;

  void setTemporaryRow(DataRow? row) {
    _temporaryRow = row;
    notifyListeners();
  }

  void addConfirmedRow(DataRow row) {
    _confirmedRows.add(row);
    _temporaryRow = null;
    notifyListeners();
  }

  void removeConfirmedRow(DataRow row) {
    _confirmedRows.remove(row);
    notifyListeners();
  }
}
