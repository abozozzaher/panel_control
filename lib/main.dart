import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'generated/l10n.dart';

import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = Locale('en');

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en' ? Locale('ar') : Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(
          create: (_) => FirebaseAuth.instance,
        ),
      ],
      child: MaterialApp(
        title: S().blue_textiles,
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Tajawal',
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Tajawal',
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.yellowAccent, brightness: Brightness.dark),
        ),
        themeMode: _themeMode,
        locale: _locale,
        supportedLocales: S.delegate.supportedLocales,

        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        debugShowCheckedModeBanner: false, // لإزالة شريط debug
        home: FutureBuilder(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              return snapshot.data == true
                  ? MyHomePage(
                      toggleTheme: _toggleTheme, toggleLocale: _toggleLocale)
                  : LoginPage(toggleTheme: _toggleTheme);
            }
          },
        ),
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
