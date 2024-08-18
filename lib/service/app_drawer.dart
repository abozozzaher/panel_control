import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import 'auth_service.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AppDrawer(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              S().menu,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(S().toggle_theme),
            onTap: toggleTheme,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S().toggle_language),
            onTap: toggleLocale,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(S().logout),
            onTap: () async {
              await AuthService().logout(context);
            },
          ),
        ],
      ),
    );
  }
}
