import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDrLjc_ax6-uQPZIJePY_48HUc-ksNwYxU",
      appId: "1:905049367219:android:597318802a22c8d44b86c6",
      messagingSenderId: "Messaging sender id here",
      projectId: "panel-control-company-zaher",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final usersRef = _firestore.collection('users');
    final usersSnapshot = await usersRef.get();
    final users =
        usersSnapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    setState(() {
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.job),
          );
        },
      ),
    );
  }
}

class User {
  final String name;
  final String job;

  User({required this.name, required this.job});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      job: map['job'],
    );
  }
}
