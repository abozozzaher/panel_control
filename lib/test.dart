import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/l10n.dart';
import 'model/user.dart';
import 'pages/auth/login_page.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const MyHomePage(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  UserData? _currentUserData;

  String? _selectedProductType;
  String? _selectedOffer;
  String? _selectedWeight;
  String? _selectedColor;
  String? _selectedThreadNumber;

  List<String> _productTypes = [];
  List<String> _offers = [];
  List<String> _weights = [];
  List<String> _colors = [];
  List<String> _threadNumbers = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchCurrentUser();
    _fetchProductInfo();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(toggleTheme: widget.toggleTheme)),
    );
  }

  Future<void> _fetchCurrentUser() async {
    if (_currentUser == null) return;

    try {
      final userRef = _firestore.collection('users').doc(_currentUser!.uid);
      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        print('Fetched user data: $userData');
        setState(() {
          _currentUserData = UserData.fromMap(userData!);
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchProductInfo() async {
    try {
      final productInfoRef = _firestore.collection('products_info');
      final snapshot = await productInfoRef.get();
      final data = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _productTypes =
            data.map((doc) => doc['productType'] as String).toList();
        _offers = data.map((doc) => doc['offer'] as String).toList();
        _weights = data.map((doc) => doc['weight'] as String).toList();
        _colors = data.map((doc) => doc['color'] as String).toList();
        _threadNumbers =
            data.map((doc) => doc['threadNumber'] as String).toList();
      });
    } catch (e) {
      print('Error fetching product info: $e');
    }
  }

  Future<void> _saveProduct() async {
    try {
      final DateTime now = DateTime.now();
      final String date = DateFormat('yyyyMMddHHmmss').format(now);
      final String productCode = 'BLLTTLT${date}';

      await _firestore.collection('products').add({
        'productType': _selectedProductType,
        'offer': _selectedOffer,
        'weight': _selectedWeight,
        'color': _selectedColor,
        'threadNumber': _selectedThreadNumber,
        'date': now,
        'user': _currentUserData!.firstName,
        'shiftNumber': 1, // يمكن تحديثها بناءً على الحالة الفعلية
        'productCode': productCode,
      });

      print('Product saved successfully');
    } catch (e) {
      print('Error saving product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S().blue_textiles),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                S().menu,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text(S().toggle_theme),
              onTap: widget.toggleTheme,
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(S().toggle_language),
              onTap: widget.toggleLocale,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(S().logout),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _currentUserData != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _currentUserData!.image
                            .startsWith('assets')
                        ? AssetImage(_currentUserData!.image)
                        : CachedNetworkImageProvider(_currentUserData!.image),
                  ),
                  SizedBox(height: 20),
                  Text(
                      '${_currentUserData!.firstName} ${_currentUserData!.lastName}',
                      style: TextStyle(fontSize: 24)),
                  Text(_currentUserData!.phone),
                  Text('ID: ${_currentUserData!.id}'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Text('Select Product Type'),
                      value: _selectedProductType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProductType = newValue;
                        });
                      },
                      items: _productTypes
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Text('Select Offer'),
                      value: _selectedOffer,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOffer = newValue;
                        });
                      },
                      items: _offers
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Text('Select Weight'),
                      value: _selectedWeight,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedWeight = newValue;
                        });
                      },
                      items: _weights
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Text('Select Color'),
                      value: _selectedColor,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedColor = newValue;
                        });
                      },
                      items: _colors
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Text('Select Thread Number'),
                      value: _selectedThreadNumber,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedThreadNumber = newValue;
                        });
                      },
                      items: _threadNumbers
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                          .toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text('Save Product'),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
