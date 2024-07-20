import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:panel_control/pages/auth/register_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'generated/l10n.dart';

import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';
import 'pages/product/NewItem.dart';
import 'pages/product/ProductPage.dart';
import 'pages/product/ScanItem.dart';
import 'test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDrLjc_ax6-uQPZIJePY_48HUc-ksNwYxU",
      appId: "1:905049367219:android:597318802a22c8d44b86c6",
      messagingSenderId: "905049367219",
      projectId: "panel-control-company-zaher",
      storageBucket: "panel-control-company-zaher.appspot.com",
    ),
  );

  final bool isLoggedIn = await _checkLoginStatus();
  usePathUrlStrategy();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

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

  late final GoRouter _router = GoRouter(
    initialLocation: widget.isLoggedIn ? '/' : '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MyHomePage(
          toggleTheme: _toggleTheme,
          toggleLocale: _toggleLocale,
        ),
      ),
      GoRoute(
        path: '/:monthFolder/:productId',
        builder: (context, state) {
          final monthFolder = state.pathParameters['monthFolder'];

          final productId = state.pathParameters['productId'];

          return ProductPage(
            monthFolder: monthFolder,
            productId: productId,
          );
        },
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => TestPage(
          toggleTheme: _toggleTheme,
          toggleLocale: _toggleLocale,
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterPage(toggleTheme: _toggleTheme),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(toggleTheme: _toggleTheme),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => AddNewItemScreen(
          toggleTheme: _toggleTheme,
          toggleLocale: _toggleLocale,
        ),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => ScanItemQr(
          toggleTheme: _toggleTheme,
          toggleLocale: _toggleLocale,
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        appBar: AppBar(title: Text('Error 404')),
        body: Center(child: Text('Page not found')),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(
          create: (_) => FirebaseAuth.instance,
        ),
      ],
      child: MaterialApp.router(
        title: S().blue_textiles,
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Beiruti',
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Beiruti',
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
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
