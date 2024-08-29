import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:panel_control/generated/l10n.dart';

import '../../data/data_lists.dart';
import 'DropdownButton.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchProductsData(List<String> months) async {
    try {
      Map<String, Map<String, dynamic>> allProducts = {};
      List<String> headers = [];

      for (String month in months) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc('productsForAllMonths')
            .collection(month)
            // .where('sale_status', isEqualTo: false)
            .get();

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
          // Apply filters
          if ((selectedType == null || product['type'] == selectedType) &&
              (selectedColor == null || product['color'] == selectedColor) &&
              (selectedWidth == null || product['width'] == selectedWidth) &&
              (selectedYarnNumber == null ||
                  product['yarn_number'] == selectedYarnNumber) &&
              (selectedQuantity == null ||
                  product['quantity'] == selectedQuantity) &&
              (selectedLength == null || product['length'] == selectedLength)) {
            String key =
                '${product['yarn_number']}-${product['type']}-${product['color']}-${product['width']}';

            if (!allProducts.containsKey(key)) {
              allProducts[key] = {
                'yarn_number': product['yarn_number'],
                'type': product['type'],
                'color': product['color'],
                'width': product['width'],
                'total_weight': 0.0,
                'quantity': 0,
                'length': 0,
                'scanned_data': 0,
              };
            }

            allProducts[key]!['total_weight'] +=
                double.tryParse(product['total_weight'].toString()) ?? 0.0;
            allProducts[key]!['quantity'] += product['quantity'] is int
                ? product['quantity']
                : int.tryParse(product['quantity'].toString()) ?? 0;
            allProducts[key]!['length'] += product['length'] is int
                ? product['length']
                : int.tryParse(product['length'].toString()) ?? 0;
            allProducts[key]!['scanned_data'] += 1;
          }
        }
      }

      setState(() {
        aggregatedData = allProducts;
        columnHeaders = headers;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products Table', textAlign: TextAlign.center),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: openMultiSelectDialog,
              child: Text('Select Months', textAlign: TextAlign.center),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
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
            const Expanded(
              child: Center(
                child: Text('Please select months to see the products.',
                    textAlign: TextAlign.center),
              ),
            )
          else if (columnHeaders.isEmpty)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Selected months have no data.',
                    textAlign: TextAlign.center),
                Text('Please select different months.',
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
                            style: TextStyle(color: Colors.greenAccent)),
                      );
                    }).toList(),
                    rows: aggregatedData.entries.map((entry) {
                      final itemData = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Center(
                              child: Text(itemData['type'].toString(),
                                  style: TextStyle(color: Colors.black)))),
                          DataCell(Center(
                              child: Text(itemData['color'].toString(),
                                  style: TextStyle(color: Colors.black)))),
                          DataCell(Center(
                              child: Text('${itemData['width']} mm',
                                  style: TextStyle(color: Colors.black)))),
                          DataCell(Center(
                              child: Text('${itemData['yarn_number']} D',
                                  style: TextStyle(color: Colors.black)))),
                          DataCell(Center(
                              child: Text('${itemData['quantity']} Pcs',
                                  style: TextStyle(color: Colors.black)))),
                          DataCell(Center(
                              child: Text('${itemData['length']} Mt',
                                  style: TextStyle(color: Colors.black)))),
                          DataCell(Center(
                              child: Text('${itemData['total_weight']} Kg',
                                  style: TextStyle(color: Colors.black)))),
                          DataCell(Center(
                              child: Text('${itemData['scanned_data']}',
                                  style: TextStyle(color: Colors.black)))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
