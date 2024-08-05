import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'generated/l10n.dart';
import 'service/app_drawer.dart';

class TestPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;
  const TestPage(
      {super.key, required this.toggleTheme, required this.toggleLocale});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                //   _playSound('assets/sound/scanner-beep.mp3');
              },
              child: Text(S().play_beep_sound),
            ),
            ElevatedButton(
              onPressed: () {
                //   _playSound('assets/sound/beep.mp3');
              },
              child: Text(S().play_scan_sound),
            ),
          ],
        ),
      ),
    );
  }
}
