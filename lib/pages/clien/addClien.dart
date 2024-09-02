import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/user_provider.dart';
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
  final fullNameArabicController = TextEditingController();
  final fullNameEnglishController = TextEditingController();
  final addressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  // لتوليد كود فريد بناءً على تاريخ اليوم
  String generateClienCode() {
    // تنسيق التاريخ
    String formattedDate =
        DateFormat('yy00MM00dd00HH00mm').format(DateTime.now());

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
    final userProvider =
        Provider.of<UserProvider>(context); // Replace with actual user provider
    final user = userProvider.user; // Assuming you have currentUser
    final String todayDate =
        DateFormat('dd/MM/yyyy').format(DateTime.now()); // صيغة التاريخ
    bool isMobile = MediaQuery.of(context).size.width < 600;
    String clienId = generateClienCode();

    return Scaffold(
      appBar: AppBar(
          title: Text('Add customer data'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Today\'s Date: $todayDate'),
          SizedBox(height: 20),
          Text('Clien Id  :  $clienId',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textDirection: ui.TextDirection.rtl),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  // إدخال الاسم بالعربية
                  TextFormField(
                    controller: fullNameArabicController,
                    decoration:
                        InputDecoration(labelText: 'الاسم الكامل (عربي)'),
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
                    controller: fullNameEnglishController,
                    decoration:
                        InputDecoration(labelText: 'Full Name (English)'),
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
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'عنوان العميل'),
                    maxLines: 2,
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
                    controller: phoneNumberController,
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

                        // إنشاء مودل بيانات العميل
                        ClienData newClien = ClienData(
                          fullNameArabic: fullNameArabic!,
                          fullNameEnglish: fullNameEnglish!,
                          address: address!,
                          phoneNumber: phoneNumber!,
                          createdAt: DateTime.now(),
                          codeIdClien: clienId,
                        );

                        // عرض مربع حوار لتأكيد البيانات
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('تأكيد بيانات العميل',
                                  textAlign: TextAlign.center),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('كود العميل: ${newClien.codeIdClien}'),
                                  Text('الاسم بالعربية: $fullNameArabic'),
                                  Text('الاسم بالإنجليزية: $fullNameEnglish'),
                                  Text('العنوان: $address'),
                                  Text('رقم الهاتف: $phoneNumber'),
                                ],
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close dialog
                                        },
                                        child: Text(
                                          S().cancel,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5, width: 5),
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                Colors.greenAccent),
                                        child: Text(S().confirm,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        onPressed: () {
                                          // إضافة البيانات إلى Firebase
                                          addClienToFirebase(newClien)
                                              .then((_) {
                                            // Clear the form fields
                                            setState(() {
                                              fullNameArabicController.clear();
                                              fullNameEnglishController.clear();
                                              addressController.clear();
                                              phoneNumberController.clear();
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'تم إضافة العميل بنجاح')),
                                            );

                                            Navigator.of(context)
                                                .pop(); // إغلاق مربع الحوار بعد التأكيد
                                          }).catchError((error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'حدث خطأ أثناء الإضافة: $error')),
                                            );
                                            Navigator.of(context)
                                                .pop(); // إغلاق مربع الحوار عند حدوث خطأ
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text('Add customer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
