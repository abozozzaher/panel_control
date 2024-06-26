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

  List<UserData> _users = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (_currentUser == null) return;

    final userRef = _firestore.collection('users').doc(_currentUser!.uid);
    final userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      setState(() {
        _users = [UserData.fromMap(userSnapshot.data()!)];
      });
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
                'Menu',
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
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text(user.phone),
            leading: user.image.startsWith('assets')
                ? Image.asset(user.image, width: 50, height: 50)
                : CachedNetworkImage(
                    imageUrl: user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset(
                        'assets/img/user.jpg',
                        width: 50,
                        height: 50),
                    width: 50,
                    height: 50,
                  ),
          );
        },
      ),
    );
  }
}
