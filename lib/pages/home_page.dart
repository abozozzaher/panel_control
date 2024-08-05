import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/l10n.dart';
import '../model/user.dart';
import '../service/app_drawer.dart';

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
    _checkLoginStatusAndFetchCurrentUser();
  }

  Future<void> _checkLoginStatusAndFetchCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      context.go('/login');
      return;
    }

    _currentUser = _auth.currentUser;
    await _fetchCurrentUser();
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
    setState(() {
      _currentUserData = null;
    });

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    bool work = _currentUserData?.work ?? false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S().blue_textiles),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      body: _currentUserData != null
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircleAvatar(
                      radius: 90,
                      foregroundImage: _currentUserData!.image
                              .startsWith('assets')
                          ? AssetImage(_currentUserData!.image)
                          : CachedNetworkImageProvider(_currentUserData!.image)
                              as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_currentUserData!.firstName} ${_currentUserData!.lastName}',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(_currentUserData!.phone),
                    const SizedBox(height: 10),
                    Text('${S().id}: ${_currentUserData!.id}'),
                    const SizedBox(height: 20),
                    if (work)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/add');
                        },
                        icon: const Icon(Icons.add_sharp),
                        label: Text('${S().add} ${S().item}'),
                      ),
                    const SizedBox(height: 20),
                    if (work)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/scan');
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text('${S().scan} ${S().item}'),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/test');
                      },
                      icon: const Icon(Icons.error_outline),
                      label: Text('${S().scan} ${S().error}'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/test2');
                      },
                      icon: const Icon(Icons.safety_check),
                      label: Text('${S().scan} ${S().error}'),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
