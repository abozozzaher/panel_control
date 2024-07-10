// flutter run -d chrome --web-renderer html
// alias firebase="`npm config get prefix`/bin/firebase"

import 'package:flutter/material.dart';

import 'generated/l10n.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S().add),
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
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(S().toggle_language),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(S().logout),
            ),
          ],
        ),
      ),
      body: Container(
        child: Text('dddd'),
      ),
    );
  }
}
