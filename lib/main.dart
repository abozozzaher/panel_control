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

import 'pages/adminHome.dart';
import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';
import 'pages/addNewProduct/NewItem.dart';
import 'pages/product/InvPage.dart';
import 'pages/product/ProductPage.dart';
import 'pages/product/proInvPage.dart';
import 'pages/scan/ScanItem.dart';
import 'provider/data_table_model.dart';
import 'provider/invoice_provider.dart';
import 'provider/scan_item_provider.dart';
import 'provider/trader_provider.dart';
import 'provider/user_provider.dart';

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
/*


python3 update_translations.py
flutter pub run intl_utils:generate


http://localhost:56330/pro-invoices/0912173624

http://localhost:56330/240009001200040029/invoices/0912174824

نعديل الترجمة في كل التطبيق
تعديل اسم الموقع
https://panel-control-company-zaher.web.app/
الى
https://admin.bluedukkan.com/





عمل تجربة ثم تحديث بنية التطبيق في الويب

اعادة الرفع بستخدام هذه الاكواد فقط
flutter clean
flutter build web --web-renderer html --release
firebase deploy


عمل صفحة كشف حساب لكل تاجر ماهي البضاعة التي قام بسحبها




اضافة في منسدلة التجار بحث للبحث عن اسم تاجر
ويكون البحث لمت له فقط لعشر خيارات لتوفير عدد القراءات من الفايربيس

تعديل البيانات الظاهرة بعد مسح الكود للمنتج


دعم طباعة الفواتير أو إرسالها عبر البريد الإلكتروني. والمشاركة مع الرابط
دعم مشاركة رابط الفاتورة وتحويلها الى صورة
تعديل ايقونة التطبيق


عمل بريفوم فاتورة لارسالة الى العميل ثم تمسح من قبل العامل ثم اقوم بتاكيد الفاتورة

تتبع حالة الدفع (مدفوع، غير مدفوع، متأخر). وتظهر على الشاشة الرئسية

إنشاء وإدارة الطلبات.

تتبع حالة الطلبات (قيد التنفيذ، مكتمل، ملغى).
تتبع المخزون بناءً على الطلبات.
تعديل بيانات المخزون عمل صفحة تساعدني في تعديل البيانات وطبع جديد


إدارة التالف والفاقد:
تسجيل المنتجات التالفة أو المفقودة.
تقارير حول أسباب الفاقد والتالف.

إدارة الإنتاج:
تسجيل عمليات الإنتاج المختلفة.
تتبع تقدم الإنتاج مقابل الأهداف.

إدارة المواد الخام:
تتبع المواد الخام المطلوبة للإنتاج.
إدارة عمليات طلب المواد الخام.






وعند المسح في حال كان تم مسحه مسبقاً تنبيه العامل (تجربة هذا الشرط على الموبيل لم تزبط التجربة تحتاج اصلاح)
في طباعة الفاتورة وضع رابط الفاتورة فوراً دون تنزيله 

اضافة طلب فاتورة ويقوم العامل باختيار اكمال الطلب ووكل عملية مسح يقوم بمسح من المتطلبات ويظهر لدي في قائمة الفواتير



عمل جدول لعرض بيانات الخيط المدخل


اضافة مع جو كونتكس للصفحة نيفيكوتر بوش
تعريف اسم الصفحة حسب go context وبنفس الوقت تشغيل نيتوفكيشن بوش للسبب في حال الرجول ينتقل الى الصفحة السابفة لا يغلق التطبيق
add novigator. push . context.go('/'); اريد بناء هذا الشكل
اضافة نقريتين للخروج
عمل رول وتاكيد من صلاحية الوصول وعمل روابط بشكل افضل للصفحات

تعديل السناك بار الى توست flutter pub add fluttertoast


اضافة شرط في حال كان الكود ممسوح بقائمة ثانية يعطي تنبيه ولا يضاف الى الجدول الا واحد (عمل هذا الشرط لاحقا)

*/
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
        ChangeNotifierProvider<TraderProvider>(create: (_) => TraderProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider<TableDataProvider>(
            create: (_) => TableDataProvider()),
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

  Future<bool> checkUserRoleAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['admin'] == true;
    }
    return false;
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
        path: '/pro-invoices/:invoiceCode',
        builder: (context, state) {
          final invoiceCode = state.pathParameters['invoiceCode'];
          return ProInvoicePage(invoiceCode: invoiceCode);
        },
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
        path: '/:codeIdClien/invoices/:invoiceCode',
        builder: (context, state) {
          final codeIdClien = state.pathParameters['codeIdClien'];
          final invoiceCode = state.pathParameters['invoiceCode'];
          return InvoicePage(
              codeIdClien: codeIdClien, invoiceCode: invoiceCode);
        },
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
              return Scaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()));
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
              return Scaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()));
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
      GoRoute(
        path: '/admin',
        builder: (context, state) => FutureBuilder<bool>(
          future: checkUserRoleAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()));
            }
            if (snapshot.data == true) {
              return AdminHomePage(
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
          appBarTheme: const AppBarTheme(
              color: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20),
              centerTitle: true),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blueGrey, // لاستخدام تدرجات الرمادي
            brightness: Brightness.light,
          ).copyWith(
            primary: Colors.black87, // اللون الرئيسي هو الأسود
            secondary: Colors.white70, // اللون الثانوي هو الأبيض
            surface: Colors.white70, // لون الأسطح (مثل الـCard) هو الأبيض
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Beiruti',
          appBarTheme: const AppBarTheme(
            color: Colors.transparent, // لون شريط التطبيق
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20),
            centerTitle: true,
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey, // لاستخدام تدرجات الرمادي
            brightness: Brightness.dark,
          ).copyWith(
            primary: Colors.white70, // اللون الرئيسي هو الأبيض
            secondary: Colors.black87, // اللون الثانوي هو الأسود
            surface: Colors.black87, // لون الأسطح (مثل الـCard) هو الأسود
          ),
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
