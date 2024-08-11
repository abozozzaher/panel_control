import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'provider/scan_item_provider.dart';
import 'provider/user_provider.dart';
import 'test.dart';
import 'test2.dart';

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

  final userProvider = UserProvider();
  await userProvider.loadUserData(); // تحميل بيانات المستخدم عند بدء التطبيق

  final bool isLoggedIn = await _checkLoginStatus();
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => userProvider),
        ChangeNotifierProvider<ScanItemProvider>(
            create: (_) => ScanItemProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
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
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _initThemeAndLocale();
  }

  void _initThemeAndLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('themeMode');
    final locale = prefs.getString('locale');

    setState(() {
      _themeMode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
      if (locale != null) {
        _locale = Locale(locale);
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    _saveThemeMode();
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en');
    });
    _saveLocale();
  }

  void _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  void _saveLocale() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', _locale.languageCode);
  }

  Future<bool> checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['work'] == true;
    }
    return false;
  }

  late final GoRouter _router = GoRouter(
    initialLocation: widget.isLoggedIn ? '/' : '/register',
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
        path: '/test2',
        builder: (context, state) => QRViewExample(),
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
        builder: (context, state) => FutureBuilder<bool>(
          future: checkUserRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.data == true) {
              return AddNewItemScreen(
                toggleTheme: _toggleTheme,
                toggleLocale: _toggleLocale,
              );
            } else {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S().access_denied_you_do_not_have_the_required_role),
                      SizedBox(height: 20), // لإضافة مسافة بين النص والزر
                      ElevatedButton(
                        onPressed: () {
                          // الانتقال إلى الصفحة الرئيسية
                          context.go('/');
                        },
                        child: Text(S().go_to_page),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => FutureBuilder<bool>(
          future: checkUserRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.data == true) {
              return ScanItemQr(
                toggleTheme: _toggleTheme,
                toggleLocale: _toggleLocale,
              );
            } else {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S().access_denied_you_do_not_have_the_required_role),
                      SizedBox(height: 20), // لإضافة مسافة بين النص والزر
                      ElevatedButton(
                        onPressed: () {
                          // الانتقال إلى الصفحة الرئيسية
                          context.go('/');
                        },
                        child: Text(S().go_to_page),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        appBar: AppBar(title: Text(S().error_404)),
        body: Center(child: Text(S().page_not_found)),
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
              seedColor: Colors.black, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Beiruti',
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white, brightness: Brightness.dark),
        ),
        themeMode: _themeMode,
        locale: _locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
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
          return const Locale('en');
        },
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
