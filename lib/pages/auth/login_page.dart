import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../../model/user.dart';
import '../../provider/user_provider.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginPage({super.key, required this.toggleTheme});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S().login),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: S().email),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: S().password),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _login,
                icon: const Icon(Icons.login),
                label: Text(S().login),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _resetPassword,
                icon: const Icon(Icons.published_with_changes_rounded),
                label: Text(S().forgot_password),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/register');
                },
                label: Text(S().register),
                icon: const Icon(Icons.account_box_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      // تسجيل الدخول باستخدام Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // جلب بيانات المستخدم من Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception(S().user_data_not_found);
      }

      // تحويل البيانات إلى كائن UserData
      UserData userData =
          UserData.fromMap(userDoc.data() as Map<String, dynamic>);

      // حفظ بيانات المستخدم في UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(userData);
      await userProvider.saveUserData(userData);

      // حفظ بيانات المستخدم في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', userData.id);
      await prefs.setString('firstName', userData.firstName);
      await prefs.setString('lastName', userData.lastName);
      await prefs.setString('phone', userData.phone);
      await prefs.setString('image', userData.image);
      await prefs.setBool('work', userData.work);
      await prefs.setBool('admin', userData.admin);
      await prefs.setBool('isLoggedIn', true);
      print('Saving user data: ${userData.toJson()}');

      setState(() {
        _errorMessage = null;
      });

      // التوجه إلى الصفحة الرئيسية بعد تسجيل الدخول
      context.go('/');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = S().error_occurred;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = S().please_enter_your_email;
      });
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S().password_reset, textAlign: TextAlign.center),
            content: Text(S().password_reset + S().email_sent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(S().ok),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }
}
