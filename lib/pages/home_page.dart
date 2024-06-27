import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/l10n.dart';
import '../model/user.dart';
import 'auth/login_page.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchCurrentUser();
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
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    _currentUserData!.phone,
                    style: TextStyle(color: Colors.red),
                  ),
                  Text(
                    'ID: ${_currentUserData!.id}',
                    style: TextStyle(fontSize: 18),
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
