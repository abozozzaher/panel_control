import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../generated/l10n.dart';
import 'auth_service.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AppDrawer(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)!.settings.name ?? '/';

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
          if (currentRoute != '/')
            ListTile(
              leading: const Icon(Icons.home_filled),
              title: Text(S().go_to_page),
              onTap: () {
                context.go('/');
              },
            ),
          if (currentRoute != '/')
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
          if (currentRoute == '/')
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
