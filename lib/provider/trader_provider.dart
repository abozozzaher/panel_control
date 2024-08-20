import 'package:flutter/material.dart';

import '../model/clien.dart';

class TraderProvider with ChangeNotifier {
  ClienData? _trader;

  ClienData? get trader => _trader;

  void setTrader(ClienData trader) {
    _trader = trader;
    notifyListeners();
  }
}
