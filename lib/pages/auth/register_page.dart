import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../../generated/l10n.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const RegisterPage({super.key, required this.toggleTheme});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _image;
  Uint8List? _webImage;
  String? _errorMessage;
  bool _loading = false; // تعيين متغير للتحقق من تحميل الصورة
  bool work = false;
  bool admin = false;

  Future<void> _pickImage() async {
    setState(() {
      _loading = true; // تعيين قيمة لمؤشر التحميل عند بدء تحميل الصورة
    });

    if (kIsWeb) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _webImage = result.files.single.bytes;
          _loading = false; // تعيين قيمة لمؤشر التحميل عند انتهاء تحميل الصورة
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _loading = false; // تعيين قيمة لمؤشر التحميل عند انتهاء تحميل الصورة
        });
      }
    }
  }

  Future<void> _register() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = S().please_fill_all_fields;
      });
      return;
    }

    setState(() {
      _loading = true; // تعيين قيمة لمؤشر التحميل عند بدء التسجيل
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String imageUrl = 'assets/img/user.jpg';
      if (_image != null || _webImage != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${userCredential.user!.uid}.jpg');
        SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

        if (kIsWeb && _webImage != null) {
          await storageRef.putData(_webImage!, metadata);
        } else if (_image != null) {
          await storageRef.putFile(_image!, metadata);
        }

        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'id': userCredential.user!.uid,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'image': imageUrl,
        'work': work,
        'admin': admin,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      setState(() {
        _loading = false; // تعيين قيمة لمؤشر التحميل عند انتهاء التسجيل
      });

      context.go('/');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _loading = false; // تعيين قيمة لمؤشر التحميل عند حدوث خطأ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S().register),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (_image != null)
                  Image.file(_image!, width: 200, height: 200),
                if (_webImage != null)
                  Image.memory(_webImage!, width: 200, height: 200),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_search_outlined),
                  label: Text('${S().select} ${S().pick_image}'),
                ),
                /*
                ElevatedButton.icon(
                  onPressed: _loading
                      ? null
                      : _pickImage, // تعيين الوظيفة غير متاحة أثناء التحميل
                  icon: Icon(Icons.image_search_outlined),
                  label: _loading
                      ? SizedBox(
                          child: CircularProgressIndicator(
                              //    valueColor:  AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                        )
                      : Text(S().select + ' ' + S().pick_image),
                ),
                */
                const SizedBox(height: 20),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: S().first_name),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: S().last_name),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: S().phone),
                ),
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
                  onPressed: _loading
                      ? null
                      : _register, // تعيين الوظيفة غير متاحة أثناء التحميل
                  icon: const Icon(Icons.account_box_outlined),
                  label: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : Text(S().register),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/login');
                  },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
