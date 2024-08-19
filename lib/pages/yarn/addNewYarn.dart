import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../model/YarnData.dart';
import '../../provider/user_provider.dart';
import '../../service/app_drawer.dart';
import '../addNewProduct/dropdownWidget.dart';

class AddYarn extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AddYarn(
      {super.key, required this.toggleTheme, required this.toggleLocale});
  @override
  _AddYarnState createState() => _AddYarnState();
}

class _AddYarnState extends State<AddYarn> {
  String? selectedYarnNumber;
  String? selectedYarnType;
  String? selectedYarnSupplier;
  String? selectedColor;
  TextEditingController weightController = TextEditingController();
  final DataLists dataLists = DataLists();

  String generateCode() {
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

  @override
  Widget build(BuildContext context) {
    final userProvider =
        Provider.of<UserProvider>(context); // Replace with actual user provider
    final user = userProvider.user; // Assuming you have currentUser
    final String todayDate =
        DateFormat('dd/MM/yyyy').format(DateTime.now()); // صيغة التاريخ
    bool isMobile = MediaQuery.of(context).size.width < 600;
    String yarnId = generateCode();
    return Scaffold(
      appBar: AppBar(
          title: Text('Add Yarn'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Today\'s Date: $todayDate'),
              SizedBox(height: 20),
              Text('Yarn Id  :  $yarnId',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textDirection: ui.TextDirection.rtl),
              buildDropdown(
                context,
                '${S().select} ${S().yarn_number}',
                selectedYarnNumber,
                dataLists.yarnNumbers,
                (value) {
                  setState(() {
                    selectedYarnNumber = value;
                  });
                },
                '${S().select} ${S().yarn_number}',
                suffixText: 'D', // يمكنك إضافة النص الذي تريده هنا

                //   allowAddNew: false, // enable "Add new item" option
              ),
              buildDropdown(
                context,
                '${S().select} ${S().type}',
                selectedYarnType,
                dataLists.yarnTypes,
                (value) {
                  setState(() {
                    selectedYarnType = value;
                  });
                },
                '${S().select} ${S().type}',
                //   suffixText: 'D', // يمكنك إضافة النص الذي تريده هنا

                //   allowAddNew: false, // enable "Add new item" option
              ),
              buildDropdown(
                context,
                '${S().select} ${S().yarn_supplier}',
                selectedYarnSupplier,
                dataLists.yarnSupplier,
                (value) {
                  setState(() {
                    selectedYarnSupplier = value;
                  });
                },
                '${S().select} ${S().yarn_supplier}',
                //     isNumeric: false,
                allowAddNew: true, // enable "Add new item" option
              ),
              buildDropdown(
                context,
                '${S().select} ${S().color}',
                selectedColor,
                dataLists.colors,
                (value) {
                  setState(() {
                    selectedColor = value;
                  });
                },
                '${S().select} ${S().color}',
                //     isNumeric: false,
                allowAddNew: true, // enable "Add new item" option
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(S().weight),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Text("Kg"),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (selectedYarnNumber != null &&
                      selectedYarnType != null &&
                      selectedYarnSupplier != null &&
                      selectedColor != null &&
                      weightController.text.isNotEmpty) {
                    // Create the yarn data
                    final yarnData = YarnData(
                      yarnNumber: selectedYarnNumber!,
                      yarnType: selectedYarnType!,
                      yarnSupplier: selectedYarnSupplier!,
                      color: selectedColor!,
                      weight: double.tryParse(weightController.text) ?? 0,
                      userId: user!.id,
                      firstName: user.firstName,
                      lastName: user.lastName,
                      createdAt: DateTime.now(),
                      codeIdYarn: yarnId,
                    );

                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Yarn Data',
                              textAlign: TextAlign.center),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('${S().id} : ${yarnData.codeIdYarn}'),
                              Text(
                                  '${S().yarn_number} : ${dataLists.yarnNumbers.firstWhere((element) => element[0] == selectedYarnNumber)[1]}'),
                              Text(
                                  '${S().yarn_type} : ${dataLists.yarnTypes.firstWhere((element) => element[0] == selectedYarnType)[1]}'),
                              Text(
                                  '${S().yarn_supplier} : ${dataLists.yarnSupplier.firstWhere((element) => element[0] == selectedYarnSupplier)[1]}'),
                              Text(
                                  '${S().color} : ${dataLists.colors.firstWhere((element) => element[0] == selectedColor)[1]}'),
                              Text(
                                  '${S().weight} : ${weightController.text} kg'),
                              Text(
                                  '${S().user} : ${yarnData.firstName} ${yarnData.lastName}'),
                            ],
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                const SizedBox(height: 5, width: 5),
                                Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.greenAccent),
                                    child: Text(S().confirm,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    onPressed: () async {
                                      // Add the yarn to Firestore
                                      await FirebaseFirestore.instance
                                          .collection('yarns')
                                          .doc(yarnData.codeIdYarn)
                                          .set(yarnData.toMap());

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Yarn added successfully!')));

                                      // Clear the form
                                      setState(() {
                                        selectedYarnNumber = null;
                                        selectedYarnType = null;
                                        selectedYarnSupplier = null;
                                        selectedColor = null;
                                        weightController.clear();
                                      });

                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please fill all fields.'),
                    ));
                  }
                },
                child: Text('Add Yarn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
