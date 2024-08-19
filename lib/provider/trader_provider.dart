import 'package:flutter/material.dart';

class TraderProvider with ChangeNotifier {
  String traderCode = '';
  String traderName = '';

  void setTrader(String code, String name) {
    traderCode = code;
    traderName = name;
    notifyListeners();
  }
}
