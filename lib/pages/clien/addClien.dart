import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../service/app_drawer.dart';
import '../../service/toasts.dart';
import '../../service/upperCase.dart'; // لتوليد الكود الموحد من تاريخ اليوم

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
  String? country;
  String? state;
  String? city;
  String? addressArabic;
  String? addressEnglish;
  String? email;
  String? phoneNumber;
  bool work = true;
  final fullNameArabicController = TextEditingController();
  final fullNameEnglishController = TextEditingController();
  final addressArabicController = TextEditingController();
  final addressEnglishController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();

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
    final String todayDate =
        DateFormat('dd/MM/yyyy').format(DateTime.now()); // صيغة التاريخ
    bool isMobile = MediaQuery.of(context).size.width < 600;
    String clienId = generateClienCode();

    return Scaffold(
      appBar: AppBar(
          title: Text(S().add_customer_data),
          centerTitle: true,
          leading: isMobile
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back), // أيقونة الرجوع
                  onPressed: () {
                    Navigator.pop(context); // لتفعيل الرجوع عند الضغط على الزر
                  },
                ),
          actions: [
            IconButton(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(Icons.home))
          ]),
      drawer: AppDrawer(
          toggleTheme: widget.toggleTheme, toggleLocale: widget.toggleLocale),
      body: Center(
        child: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    '${S().todays_date} : ${convertArabicToEnglish(todayDate)}'),
                const SizedBox(height: 20),
                Text('${S().clien_id} :  $clienId',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
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
                              InputDecoration(labelText: S().full_name_arabic),
                          onSaved: (value) {
                            fullNameArabic = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S().please_enter_the_name_in_arabic;
                            }
                            return null;
                          },
                        ),
                        // إدخال الاسم بالإنجليزية
                        TextFormField(
                          controller: fullNameEnglishController,
                          decoration:
                              InputDecoration(labelText: S().full_name_english),
                          onSaved: (value) {
                            fullNameEnglish = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S().please_enter_the_full_name_in_english;
                            }
                            return null;
                          },
                          inputFormatters: [
                            UpperCaseFirstLetterFormatter(),
                          ],
                        ),
                        // ادخال البلد والعنوان
                        CountryStateCityPicker(
                            country: countryController,
                            state: stateController,
                            city: cityController,
                            dialogColor: Colors.grey.shade200,
                            textFieldDecoration: InputDecoration(
                                fillColor: Colors.blueGrey.shade100,
                                filled: true,
                                suffixIcon:
                                    const Icon(Icons.arrow_downward_rounded),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none))),
                        // إدخال العنوان  بالعربية
                        TextFormField(
                          controller: addressArabicController,
                          decoration:
                              InputDecoration(labelText: S().addressArabic),
                          maxLines: 2,
                          onSaved: (value) {
                            addressArabic = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S().please_enter_the_address;
                            }
                            return null;
                          },
                        ),
                        // إدخال العنوان بالانكليزي
                        TextFormField(
                          controller: addressEnglishController,
                          decoration:
                              InputDecoration(labelText: S().addressEnglish),
                          maxLines: 2,
                          onSaved: (value) {
                            addressEnglish = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S().please_enter_the_address;
                            }
                            return null;
                          },
                        ),

                        // إدخال Email
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: S().email),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) {
                            email = value;
                          },
                          /*
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S().please_enter_phone_number;
                            }
                            return null;
                          },
                          */
                        ),

                        // إدخال رقم الهاتف
                        TextFormField(
                          controller: phoneNumberController,
                          decoration:
                              InputDecoration(labelText: S().phone_number),
                          keyboardType: TextInputType.phone,
                          onSaved: (value) {
                            phoneNumber = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S().please_enter_phone_number;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
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
                                country: countryController.text,
                                state: stateController.text,
                                city: cityController.text,
                                addressArabic: addressArabic!,
                                addressEnglish: addressEnglish!,
                                email: email!,
                                phoneNumber: phoneNumber!,
                                createdAt: DateTime.now(),
                                codeIdClien: clienId,
                                work: work,
                              );

                              // عرض مربع حوار لتأكيد البيانات
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(S().confirm_customer_data,
                                        textAlign: TextAlign.center),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                            '${S().client_code} : ${newClien.codeIdClien}'),
                                        Text(
                                            '${S().name_in_arabic} : $fullNameArabic'),
                                        Text(
                                            '${S().name_in_english} : $fullNameEnglish'),
                                        Text(
                                            "${countryController.text}, ${stateController.text}, ${cityController.text}"),
                                        Text(
                                            '${S().addressArabic} : $addressArabic'),
                                        Text(
                                            '${S().addressEnglish} : $addressEnglish'),
                                        Text('${S().email} : $email'),
                                        Text('${S().phone} : $phoneNumber'),
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
                                                  backgroundColor:
                                                      Colors.redAccent),
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
                                          const SizedBox(height: 5, width: 5),
                                          Expanded(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.greenAccent),
                                              child: Text(S().confirm,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              onPressed: () {
                                                // إضافة البيانات إلى Firebase
                                                addClienToFirebase(newClien)
                                                    .then((_) {
                                                  // Clear the form fields
                                                  setState(() {
                                                    fullNameArabicController
                                                        .clear();
                                                    fullNameEnglishController
                                                        .clear();
                                                    countryController.clear();
                                                    stateController.clear();
                                                    cityController.clear();

                                                    addressArabicController
                                                        .clear();
                                                    addressEnglishController
                                                        .clear();
                                                    emailController.clear();
                                                    phoneNumberController
                                                        .clear();
                                                  });

                                                  showToast(S()
                                                      .customer_added_successfully);
                                                  Navigator.of(context)
                                                      .pop(); // إغلاق مربع الحوار بعد التأكيد
                                                }).catchError((error) {
                                                  showToast(
                                                      '${S().an_error_occurred_while_adding} : $error');
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
                          child: Text(S().add_clien),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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
