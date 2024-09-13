import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class UserProvider with ChangeNotifier {
  UserData? _user;

  UserData? get user => _user;

  void setUser(UserData userData) {
    _user = userData;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final email = prefs.getString('email');
    final phone = prefs.getString('phone');
    final image = prefs.getString('image') ?? 'assets/img/user.png';
    final work = prefs.getBool('work') ?? false;
    final admin = prefs.getBool('admin') ?? false;

    if (id != null &&
        firstName != null &&
        lastName != null &&
        phone != null &&
        email != null) {
      _user = UserData(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        image: image,
        work: work,
        admin: admin,
      );
    }

    notifyListeners();
  }

  Future<void> saveUserData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', userData.id);
    await prefs.setString('firstName', userData.firstName);
    await prefs.setString('lastName', userData.lastName);
    await prefs.setString('email', userData.email);
    await prefs.setString('phone', userData.phone);
    await prefs.setString('image', userData.image);
    await prefs.setBool('work', userData.work);
    await prefs.setBool('admin', userData.admin);

    _user = userData;
    notifyListeners();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();
  }
}
