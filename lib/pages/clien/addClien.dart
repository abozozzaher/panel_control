import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../model/clien.dart';
import '../../service/app_drawer.dart'; // لتوليد الكود الموحد من تاريخ اليوم

class ClienEntryPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const ClienEntryPage(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  _ClienEntryPageState createState() => _ClienEntryPageState();
}

class _ClienEntryPageState extends State<ClienEntryPage> {
  final _formKey = GlobalKey<FormState>();

  String? fullNameArabic;
  String? fullNameEnglish;
  String? address;
  String? phoneNumber;

  // لتوليد كود فريد بناءً على تاريخ اليوم
  String generateClienCode() {
    // تنسيق التاريخ
    String formattedDate = DateFormat('yy00MM00dd00ss').format(DateTime.now());

    // تحويل الأرقام العربية إلى إنجليزية
    return convertArabicToEnglish(formattedDate);
  }

  String convertArabicToEnglish(String text) {
    // تحويل الأرقام العربية إلى أرقام إنجليزية
    return text.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString(),
    );
  }

  // دالة لحفظ البيانات في Firebase
  Future<void> addClienToFirebase(ClienData clien) async {
    await FirebaseFirestore.instance
        .collection('cliens')
        .doc(clien.codeIdClien)
        .set(clien.toMap());
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
          title: Text('إضافة بيانات العميل'),
          centerTitle: true,
          leading: isMobile
              ? null
              : IconButton(
                  icon: Icon(Icons.arrow_back), // أيقونة الرجوع
                  onPressed: () {
                    Navigator.pop(context); // لتفعيل الرجوع عند الضغط على الزر
                  },
                )),
      drawer: AppDrawer(
          toggleTheme: widget.toggleTheme, toggleLocale: widget.toggleLocale),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // إدخال الاسم بالعربية
              TextFormField(
                decoration: InputDecoration(labelText: 'الاسم الكامل (عربي)'),
                onSaved: (value) {
                  fullNameArabic = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم بالعربية';
                  }
                  return null;
                },
              ),

              // إدخال الاسم بالإنجليزية
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name (English)'),
                onSaved: (value) {
                  fullNameEnglish = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the full name in English';
                  }
                  return null;
                },
              ),

              // إدخال العنوان
              TextFormField(
                decoration: InputDecoration(labelText: 'عنوان العميل'),
                maxLines: 3,
                onSaved: (value) {
                  address = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال العنوان';
                  }
                  return null;
                },
              ),

              // إدخال رقم الهاتف
              TextFormField(
                decoration: InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  phoneNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // زر لإضافة البيانات
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // إنشاء كود العميل الموحد
                    String clienCode = generateClienCode();

                    // إنشاء مودل بيانات العميل
                    ClienData newClien = ClienData(
                      clienCode: clienCode,
                      fullNameArabic: fullNameArabic!,
                      fullNameEnglish: fullNameEnglish!,
                      address: address!,
                      phoneNumber: phoneNumber!,
                      createdAt: DateTime.now(),
                      codeIdClien: generateClienCode(),
                    );

                    // إضافة البيانات إلى Firebase
                    addClienToFirebase(newClien).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم إضافة العميل بنجاح')),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('حدث خطأ أثناء الإضافة: $error')),
                      );
                    });
                  }
                },
                child: Text('إضافة العميل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
