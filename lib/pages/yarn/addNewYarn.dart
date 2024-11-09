import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../../data/data_lists.dart';

import '../../generated/l10n.dart';
import '../../model/YarnData.dart';
import '../../provider/user_provider.dart';
import '../../service/app_drawer.dart';
import '../../service/dropdownWidget.dart';
import '../../service/exchangeRate_service.dart';
import '../../service/toasts.dart';
import '../../excel_fille/save_file_mobile.dart'
    if (dart.library.html) '../../excel_fille/save_file_web.dart';

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
  TextEditingController priceController = TextEditingController();

  final DataLists dataLists = DataLists();
  List<YarnData> yarnDataList = []; // تعريف قائمة الخيوط

  String generateCode() {
    // تنسيق التاريخ
    String formattedDate =
        DateFormat('yy00MM00dd00HHmmss').format(DateTime.now());

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

  Future<List<YarnData>> fetchYarnsByDateRange(
      DateTime startDate, DateTime endDate) async {
    // جلب البيانات من Firebase
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('yarns')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .orderBy('createdAt', descending: true) // ترتيب حسب تاريخ الإدخال
        .get();
    // تحويل البيانات إلى قائمة من الكائنات
    return querySnapshot.docs.map((doc) {
      print('sss ${doc.data()}');

      return YarnData(
        yarnNumber: doc['yarn_number'],
        yarnType: doc['yarnType'],
        yarnSupplier: doc['yarnSupplier'],
        color: doc['color'],
        weight: doc['weight'],
        priceYarn: doc['priceYarn'],
        goodsPrice: doc['goodsPrice'],
        userId: doc['userId'],
        nameUserAddData: doc['nameUserAddData'],
        createdAt: (doc['createdAt']).toDate(),
        codeIdYarn: doc['code'],
      );
    }).toList();
  }

  Future<void> selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020), // تاريخ بداية محتمل
      lastDate: DateTime.now(), // تاريخ نهاية
    );

    if (picked != null) {
      // ضبط تاريخ البداية ليكون في بداية اليوم
      DateTime start = DateTime(
          picked.start.year, picked.start.month, picked.start.day, 0, 0, 0);
      // ضبط تاريخ النهاية ليكون في نهاية اليوم
      DateTime end = DateTime(
          picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);

      print('picked.start: $start');

      print('picked.end: $end');

      // جلب البيانات حسب الفترة الزمنية المختارة
      List<YarnData> yarns = await fetchYarnsByDateRange(start, end);
      print('Yarns fetched: ${yarns.length}');
      // عرض البيانات في جدول
      setState(() {
        yarnDataList = yarns;
      });
    }
  }

  Future<void> exportToExcel() async {
    // الحصول على التاريخ الحالي
    final now = DateTime.now();
    final formattedDateXlsx =
        '${now.day}-${now.month}-${now.year}'; // تنسيق التاريخ يوم-شهر-سنة

    // إنشاء مصنف Excel جديد
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

// إعداد عناوين الأعمدة
    sheet.getRangeByName('A1').setValue('Created At');
    sheet.getRangeByName('B1').setValue('Yarn Number');
    sheet.getRangeByName('C1').setValue('Yarn Type');
    sheet.getRangeByName('D1').setValue('Yarn Supplier');
    sheet.getRangeByName('E1').setValue('Color');
    sheet.getRangeByName('F1').setValue('Weight KG');
    sheet.getRangeByName('G1').setValue('Price Yarn \$');
    sheet.getRangeByName('H1').setValue('Goods Price \$'); // العمود الجديد
    sheet.getRangeByName('I1').setValue('Code ID Yarn'); // العمود الجديد

// إضافة البيانات من yarnDataList إلى الصفوف
    for (int i = 0; i < yarnDataList.length; i++) {
      final yarn = yarnDataList[i];

      // إضافة التاريخ في العمود الأول باستخدام الأرقام الإنجليزية
      sheet
          .getRangeByName('A${i + 2}')
          .setValue(DateFormat('dd/MM/yyyy', 'en_US').format(yarn.createdAt));

      // إضافة باقي البيانات
      sheet.getRangeByName('B${i + 2}').setValue(yarn.yarnNumber);
      sheet.getRangeByName('C${i + 2}').setValue(yarn.yarnType);
      sheet.getRangeByName('D${i + 2}').setValue(yarn.yarnSupplier);
      sheet.getRangeByName('E${i + 2}').setValue(yarn.color);
      sheet.getRangeByName('F${i + 2}').setValue('${yarn.weight}');
      sheet.getRangeByName('G${i + 2}').setValue('${yarn.priceYarn}');

      // إضافة الأعمدة الجديدة
      sheet.getRangeByName('H${i + 2}').setValue('${yarn.goodsPrice}');
      sheet.getRangeByName('I${i + 2}').setValue(yarn.codeIdYarn);
    }

    // حفظ الملف
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final fileName = 'yarn_data_$formattedDateXlsx.xlsx';

    await saveAndLaunchFile(bytes, fileName);
    showToast('${S().excel_file_saved} $fileName');
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
          title: Text(S().add_yarn),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      '${S().todays_date} : ${convertArabicToEnglish(todayDate)}'),
                  const SizedBox(height: 20),
                  Text('${S().yarn_id}  :  $yarnId',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(S().weight),
                      SizedBox(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            textDirection: ui.TextDirection.ltr,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10.0),
                                isDense: true,
                                border: OutlineInputBorder(),
                                suffixText: "Kg"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(S().price),
                      SizedBox(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            textDirection: ui.TextDirection.ltr,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10.0),
                                isDense: true,
                                border: OutlineInputBorder(),
                                suffixText: "\$"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_box),
                    onPressed: () async {
                      double? exchangeRateTR = await fetchExchangeRateTR();
                      double? weightxx = double.tryParse(
                          convertArabicToEnglish(weightController.text));
                      double? pricexx = double.tryParse(
                          convertArabicToEnglish(priceController.text));
                      final goodsPrice = (weightxx! * pricexx!);
                      if (selectedYarnNumber != null &&
                          selectedYarnType != null &&
                          selectedYarnSupplier != null &&
                          selectedColor != null &&
                          weightController.text.isNotEmpty &&
                          priceController.text.isNotEmpty) {
                        // Create the yarn data
                        final yarnData = YarnData(
                            yarnNumber: selectedYarnNumber!,
                            yarnType: selectedYarnType!,
                            yarnSupplier: selectedYarnSupplier!,
                            color: selectedColor!,
                            weight: weightxx,
                            priceYarn: pricexx,
                            goodsPrice: goodsPrice,
                            userId: user!.id,
                            nameUserAddData:
                                '${user.firstName} ${user.lastName}',
                            createdAt: DateTime.now(),
                            codeIdYarn: yarnId);

                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(S().confirm_yarn_data,
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
                                      '${S().weight} : ${convertArabicToEnglish(weightController.text)} kg'),
                                  Text(
                                      '${S().price} : ${convertArabicToEnglish(priceController.text)}'),
                                  Text(
                                      '${S().user} : ${yarnData.nameUserAddData}'),
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
                                    const SizedBox(height: 5, width: 5),
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                Colors.greenAccent),
                                        child: Text(S().confirm,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        onPressed: () async {
                                          // Add the yarn to Firestore
                                          await FirebaseFirestore.instance
                                              .collection('yarns')
                                              .doc(yarnData.codeIdYarn)
                                              .set(yarnData
                                                  .toMap(exchangeRateTR));

                                          showToast(
                                              S().yarn_added_successfully);

                                          // Clear the form
                                          setState(() {
                                            selectedYarnNumber = null;
                                            selectedYarnType = null;
                                            selectedYarnSupplier = null;
                                            selectedColor = null;
                                            weightController.clear();
                                            priceController.clear();
                                          });
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                          context.go('/');
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
                        showToast(S().please_fill_all_fields);
                      }
                    },
                    label: Text(S().add_yarn),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    label: Text(S().show_yarn_table),
                    icon: Icon(Icons.table_view_outlined),
                    onPressed: () => selectDateRange(context),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: exportToExcel,
                    label: Text(S().export_to_excel),
                    icon: Icon(Icons.shuffle_outlined),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // للسماح بتمرير الجدول إذا كان كبيراً
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text(S().yarn_number,
                                textAlign: TextAlign.center)),
                        DataColumn(
                            label: Text(S().yarn_type,
                                textAlign: TextAlign.center)),
                        DataColumn(
                            label: Text(S().yarn_supplier,
                                textAlign: TextAlign.center)),
                        DataColumn(
                            label:
                                Text(S().color, textAlign: TextAlign.center)),
                        DataColumn(
                            label:
                                Text(S().weight, textAlign: TextAlign.center)),
                        DataColumn(
                            label:
                                Text(S().price, textAlign: TextAlign.center)),
                        DataColumn(
                            label: Text(S().data, textAlign: TextAlign.center)),
                      ],
                      rows: yarnDataList.map((yarn) {
                        return DataRow(cells: [
                          DataCell(Text(
                              '${DataLists().translateType(yarn.yarnNumber.toString())}D',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              maxLines: 1)),
                          DataCell(Text(
                              DataLists()
                                  .translateType(yarn.yarnType.toString()),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              maxLines: 1)),
                          DataCell(Text(
                              DataLists()
                                  .translateType(yarn.yarnSupplier.toString()),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              maxLines: 1)),
                          DataCell(Text(
                              DataLists().translateType(yarn.color.toString()),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              maxLines: 1)),
                          DataCell(Text(
                              '${DataLists().translateType(yarn.weight.toString())}KG',
                              textDirection: ui.TextDirection.ltr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              maxLines: 1)),
                          DataCell(Text(
                              '${DataLists().translateType(yarn.priceYarn.toStringAsFixed(2))}\$',
                              textDirection: ui.TextDirection.ltr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              maxLines: 1)),
                          DataCell(Text(
                              DateFormat('dd/MM/yyyy', 'en_US')
                                  .format(yarn.createdAt),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              maxLines: 1)),
                        ]);
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
