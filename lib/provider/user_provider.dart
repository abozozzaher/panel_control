import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPr {
  String? id;

  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? image;
  bool? work;
  bool? admin;

  UserPr({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.image,
    this.work,
    this.admin,
  });
}

class UserProvider with ChangeNotifier {
  UserPr? _user;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _user = UserPr(
      id: prefs.getString('id'),
      firstName: prefs.getString('firstName'),
      lastName: prefs.getString('lastName'),
      phone: prefs.getString('phone'),
      email: prefs.getString('email'),
      image: prefs.getString('image'),
      work: prefs.getBool('work'),
      admin: prefs.getBool('admin'),
    );
    notifyListeners();
  }

  UserPr? get user => _user;
  String? get id => id;

  String? get firstName => firstName;
  String? get lastName => lastName;
  String? get phone => phone;
  String? get email => email;
  String? get image => image;
  bool? get work => work;
  bool? get admin => admin;

  Future<void> saveUserData({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? image,
    bool? work,
    bool? admin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id!);
    await prefs.setString('firstName', firstName!);
    await prefs.setString('lastName', lastName!);
    await prefs.setString('phone', phone!);
    await prefs.setString('email', email!);
    await prefs.setString('image', image!);
    await prefs.setBool('work', work!);
    await prefs.setBool('admin', admin!);
    id = id;
    firstName = firstName;
    lastName = lastName;
    phone = phone;
    email = email;
    image = image;
    work = work;
    admin = admin;
    notifyListeners();
  }
}
/*
class UserProvider with ChangeNotifier {
  UserData? _user;

  UserData? get user => _user;

  void setUser(UserData user) async {
    _user = user;
    notifyListeners();

    // حفظ البيانات في SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final userJson = jsonDecode(userString);
      _user = UserData.fromMap(userJson);
      notifyListeners();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _user?.id,
      'firstName': _user?.firstName,
      'lastName': _user?.lastName,
      'phone': _user?.phone,
      'image': _user?.image,
      'work': _user?.work,
      'admin': _user?.admin,
    };
  }
}
*/