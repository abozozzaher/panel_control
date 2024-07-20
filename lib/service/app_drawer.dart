import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../generated/l10n.dart';
import 'auth_service.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AppDrawer(
      {Key? key, required this.toggleTheme, required this.toggleLocale})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            onTap: toggleTheme,
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text(S().toggle_language),
            onTap: toggleLocale,
          ),
          ListTile(
            leading: Icon(Icons.logout),
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
