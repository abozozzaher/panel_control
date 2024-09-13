import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../model/user.dart';
import '../provider/user_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserData? currentUserData = userProvider.user;

    bool work = currentUserData!.work;
    bool admin = currentUserData.admin;

    return Scaffold(
        appBar: AppBar(
          title: Text(S().blue_textiles),
          actions: [
            IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: widget.toggleTheme),
          ],
        ),
        drawer: AppDrawer(
            toggleTheme: widget.toggleTheme, toggleLocale: widget.toggleLocale),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  radius: 90,
                  foregroundImage: currentUserData.image.startsWith('assets')
                      ? AssetImage(currentUserData.image)
                      : CachedNetworkImageProvider(currentUserData.image)
                          as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  '${currentUserData.firstName} ${currentUserData.lastName}',
                  style: const TextStyle(fontSize: 24),
                ),
                Text(currentUserData.phone),
                Text(currentUserData.email),
                const SizedBox(height: 10),
                Text('${S().id}: ${currentUserData.id}'),
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
                const SizedBox(height: 20),
                if (admin)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/admin');
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: Text(S().administration_page),
                  ),
/*
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
*/
              ],
            ),
          ),
        ));
  }
}
