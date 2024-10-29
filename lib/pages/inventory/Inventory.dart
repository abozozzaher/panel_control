import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/dataBase.dart';
import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../service/toasts.dart';
import 'DropdownButton.dart';
import 'Excel_Inventory.dart';
import 'SelectedMonthsDialog.dart'; // Assuming you are using localization strings

class Inventory extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const Inventory(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final DataLists dataLists = DataLists();

  List<String> selectedMonths = [];
  Map<String, Map<String, dynamic>> aggregatedData = {};
  List<String> columnHeaders = [];

  // New state variables for dropdown selections
  String? selectedType;
  String? selectedColor;
  String? selectedWidth;
  String? selectedYarnNumber;
  String? selectedQuantity;
  String? selectedLength;

// تعديل دالة الفاتش
  ///9998
  String formatNumber(double num) {
    if (num >= 1000000000) {
      return (num / 1000000000).toStringAsFixed(0) + 'B'; // مليار
    } else if (num >= 1000000) {
      return (num / 1000000).toStringAsFixed(0) + 'M'; // مليون
    } else if (num >= 1000) {
      return (num / 1000).toStringAsFixed(0) + 'k'; // ألف
    } else {
      return num.toStringAsFixed(1); // أقل من ألف
    }
  }

  Future<void> fetchProductsData(List<String> months) async {
    try {
      Map<String, Map<String, dynamic>> allProducts = {};
      List<String> headers = [];
      List<String> keysToCheck = [];

      // إنشاء المفاتيح التي يجب التحقق منها في قاعدة البيانات
      for (String month in months) {
        // يمكن إنشاء مفتاح فريد لكل مستند بناءً على بيانات المنتج
        keysToCheck.add('$month-key');
      }

      // إذا كان التطبيق يعمل على الويب، نفذ عملية الفاتش مباشرة
      if (kIsWeb) {
        for (String month in months) {
          Query query = FirebaseFirestore.instance
              .collection('products')
              .doc('productsForAllMonths')
              .collection(month)
              .where('sale_status', isEqualTo: false);

          // تطبيق الفلاتر بناءً على القيم المختارة من القوائم المنسدلة
          if (selectedType != null) {
            query = query.where('type', isEqualTo: selectedType);
          }
          if (selectedColor != null) {
            query = query.where('color', isEqualTo: selectedColor);
          }
          if (selectedWidth != null) {
            query = query.where('width', isEqualTo: selectedWidth);
          }
          if (selectedYarnNumber != null) {
            query = query.where('yarn_number', isEqualTo: selectedYarnNumber);
          }
          if (selectedQuantity != null) {
            query = query.where('quantity', isEqualTo: selectedQuantity);
          }
          if (selectedLength != null) {
            query = query.where('length', isEqualTo: selectedLength);
          }

          QuerySnapshot snapshot = await query.get();
          List<Map<String, dynamic>> monthProducts = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          if (monthProducts.isNotEmpty && headers.isEmpty) {
            headers = [
              (S().type),
              (S().color),
              (S().width),
              (S().yarn_number),
              (S().quantity),
              (S().length),
              (S().total_length),
              (S().total_weight),
              (S().scanned)
            ];
          }

          for (var product in monthProducts) {
            String key =
                '${product['yarn_number']}-${product['type']}-${product['color']}-${product['width']}-${product['length']}';

            if (!allProducts.containsKey(key)) {
              // لم يتم العثور على المنتج في قاعدة البيانات، لذا احضره من Firebase وقم بحفظه في SQLite
              allProducts[key] = {
                'yarn_number': product['yarn_number'],
                'type': product['type'],
                'color': product['color'],
                'width': product['width'],
                'length': product['length'],
                'total_weight': 0.0,
                'quantity': 0,
                'total_length': 0.0,
                'scanned_data': 0,
              };

              // تخزين المنتج في SQLite مباشرة إذا كان على الويب
              databaseHelper.saveProductToDatabaseInventory(
                  allProducts[key]!, key);
            }

            // حساب الطول * الكمية
            double totalLength = (product['length'] is int
                    ? product['length']
                    : int.tryParse(product['length'].toString()) ?? 0) *
                (product['quantity'] is int
                    ? product['quantity']
                    : int.tryParse(product['quantity'].toString()) ?? 0);
            // تحديث البيانات المحسوبة
            allProducts[key]!['total_weight'] +=
                double.tryParse(product['total_weight'].toString()) ?? 0.0;
            allProducts[key]!['quantity'] += product['quantity'] is int
                ? product['quantity']
                : int.tryParse(product['quantity'].toString()) ?? 0;
            allProducts[key]!['total_length'] += totalLength;
            // حفظ الطول المختصر
            allProducts[key]!['formatted_length'] =
                formatNumber(allProducts[key]!['total_length']);
            allProducts[key]!['scanned_data'] += 1;
          }
        }
      } else {
        // إذا لم يكن على الويب، تحقق من وجود البيانات في SQLite
        List<Map<String, dynamic>> existingProducts =
            await databaseHelper.checkProductsInDatabaseInventory(keysToCheck);
        for (var product in existingProducts) {
          allProducts[product['id']] = product;
        }

        for (String month in months) {
          Query query = FirebaseFirestore.instance
              .collection('products')
              .doc('productsForAllMonths')
              .collection(month)
              .where('sale_status', isEqualTo: false);

          // تطبيق الفلاتر بناءً على القيم المختارة من القوائم المنسدلة
          if (selectedType != null) {
            query = query.where('type', isEqualTo: selectedType);
          }
          if (selectedColor != null) {
            query = query.where('color', isEqualTo: selectedColor);
          }
          if (selectedWidth != null) {
            query = query.where('width', isEqualTo: selectedWidth);
          }
          if (selectedYarnNumber != null) {
            query = query.where('yarn_number', isEqualTo: selectedYarnNumber);
          }
          if (selectedQuantity != null) {
            query = query.where('quantity', isEqualTo: selectedQuantity);
          }
          if (selectedLength != null) {
            query = query.where('length', isEqualTo: selectedLength);
          }

          QuerySnapshot snapshot = await query.get();
          List<Map<String, dynamic>> monthProducts = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          if (monthProducts.isNotEmpty && headers.isEmpty) {
            headers = [
              (S().type),
              (S().color),
              (S().width),
              (S().yarn_number),
              (S().quantity),
              (S().length),
              (S().total_weight),
              (S().scanned)
            ];
          }

          for (var product in monthProducts) {
            String key =
                '${product['yarn_number']}-${product['type']}-${product['color']}-${product['width']}-${product['length']}';

            if (!allProducts.containsKey(key)) {
              // لم يتم العثور على المنتج في قاعدة البيانات، لذا احضره من Firebase وقم بحفظه في SQLite
              allProducts[key] = {
                'yarn_number': product['yarn_number'],
                'type': product['type'],
                'color': product['color'],
                'width': product['width'],
                'length': product['length'],
                'total_weight': 0.0,
                'quantity': 0,
                'total_length': 0.0,
                'scanned_data': 0,
              };

              // تخزين المنتج في SQLite مباشرة إذا كان على الويب
              databaseHelper.saveProductToDatabaseInventory(
                  allProducts[key]!, key);
            }

            // حساب الطول * الكمية
            double totalLength = (product['length'] is int
                    ? product['length']
                    : int.tryParse(product['length'].toString()) ?? 0) *
                (product['quantity'] is int
                    ? product['quantity']
                    : int.tryParse(product['quantity'].toString()) ?? 0);
            allProducts[key]!['total_weight'] +=
                double.tryParse(product['total_weight'].toString()) ?? 0.0;
            allProducts[key]!['quantity'] += product['quantity'] is int
                ? product['quantity']
                : int.tryParse(product['quantity'].toString()) ?? 0;
            allProducts[key]!['total_length'] += totalLength;
            // حفظ الطول المختصر
            allProducts[key]!['formatted_length'] =
                formatNumber(allProducts[key]!['total_length']);
            allProducts[key]!['scanned_data'] += 1;
          }
        }
      }

      setState(() {
        aggregatedData = allProducts;
        columnHeaders = headers;
      });
    } catch (e) {
      showToast('Error fetching products: #301');
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> openMultiSelectDialog() async {
      final List<String> result = await showMultiSelectDialog(
        context,
        dataLists.months,
        selectedMonths,
      );
      setState(() {
        selectedMonths = result;
        fetchProductsData(selectedMonths);
      });
    }

//111 هنا الخطا لا يتطابق المعلومات حسب المنسدلة
    return Scaffold(
      appBar: AppBar(title: Text(S().products_table)),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: openMultiSelectDialog,
                child: Text(S().select_months, textAlign: TextAlign.center),
              ),
            ),
            // إضافة زر لتنزيل ملف Excel
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  exportToExcel(columnHeaders, aggregatedData);
                }, // هنا وظيفة التصدير
                child: Text(S().export_to_excel, textAlign: TextAlign.center),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      buildDropdownButton(
                        hint: '${S().select} ${S().type}',
                        selectedValue: selectedType,
                        items: dataLists.types,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedType = newValue;
                            fetchProductsData(selectedMonths);
                          });
                        },
                      ),
                      buildDropdownButton(
                        hint: '${S().select} ${S().color}',
                        selectedValue: selectedColor,
                        items: dataLists.colors,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedColor = newValue;
                            fetchProductsData(selectedMonths);
                          });
                        },
                      ),
                      buildDropdownButton(
                        hint: '${S().select} ${S().width}',
                        selectedValue: selectedWidth,
                        items: dataLists.widths,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedWidth = newValue;
                            fetchProductsData(selectedMonths);
                          });
                        },
                      ),
                      buildDropdownButton(
                        hint: '${S().select} ${S().yarn_number}',
                        selectedValue: selectedYarnNumber,
                        items: dataLists.yarnNumbers,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedYarnNumber = newValue;
                            fetchProductsData(selectedMonths);
                          });
                        },
                      ),
                      buildDropdownButton(
                        hint: '${S().select} ${S().quantity}',
                        selectedValue: selectedQuantity,
                        items: dataLists.quantity,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedQuantity = newValue;
                            fetchProductsData(selectedMonths);
                          });
                        },
                      ),
                      buildDropdownButton(
                        hint: '${S().select} ${S().length}',
                        selectedValue: selectedLength,
                        items: dataLists.length,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLength = newValue;
                            fetchProductsData(selectedMonths);
                          });
                        },
                      ),
                      // أضف خيارات إضافية إذا لزم الأمر
                    ],
                  )),
            ),
            if (selectedMonths.isEmpty)
              Expanded(
                child: Center(
                  child: Text(S().please_select_months_to_see_the_products,
                      textAlign: TextAlign.center),
                ),
              )
            else if (columnHeaders.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(S().selected_months_have_no_data,
                      textAlign: TextAlign.center),
                  Text(S().please_select_different_months,
                      textAlign: TextAlign.center),
                ],
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: columnHeaders.map((header) {
                        return DataColumn(
                          label: Text(header,
                              style:
                                  const TextStyle(color: Colors.greenAccent)),
                        );
                      }).toList(),
                      rows: aggregatedData.entries.map((entry) {
                        final itemData = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Center(
                              child: Text(
                                  DataLists().translateType(
                                      itemData['type'].toString()),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text(
                                  DataLists().translateType(
                                      itemData['color'].toString()),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text(
                                  '${DataLists().translateType(itemData['width'].toString())} mm',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text(
                                  '${DataLists().translateType(itemData['yarn_number'].toString())} D',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text(
                                  '${DataLists().translateType(itemData['quantity'].toString())} ${S().pcs}',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text(
                                  '${DataLists().translateType(itemData['length'].toString())} Mt',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text(
                                  '${DataLists().translateType(itemData['formatted_length'].toString())} Mt',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text('${itemData['total_weight']} Kg',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                            DataCell(Center(
                              child: Text('${itemData['scanned_data']}',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
