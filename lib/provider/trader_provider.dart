import 'package:flutter/material.dart';

import '../model/clien.dart';

class TraderProvider with ChangeNotifier {
  ClienData? _trader;

  ClienData? get trader => _trader;

  String? _selectedCode;

  String? get selectedCode => _selectedCode;

  void setSelectedCode(String? code) {
    _selectedCode = code;
    notifyListeners();
  }

  void setTrader(ClienData trader) {
    _trader = trader;
    notifyListeners();
  }

  void clearTrader() {
    _trader = null;
    _selectedCode = null;
    notifyListeners();
  }
}
