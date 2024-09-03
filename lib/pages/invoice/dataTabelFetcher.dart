import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:panel_control/pages/invoice/pdf_Inv.dart';
import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../provider/invoice_provider.dart';

class DataTabelFetcher extends StatefulWidget {
  @override
  _DataTabelFetcherState createState() => _DataTabelFetcherState();
}

class _DataTabelFetcherState extends State<DataTabelFetcher> {
  final DataLists dataLists = DataLists();
  double grandTotalPrice = 0.0; // تعريف المتغير هنا

  List<bool> _selectedItem = [];

  TextEditingController taxController = TextEditingController();
  TextEditingController previousDebtController = TextEditingController();
  TextEditingController shippingFeeController = TextEditingController();

  final ValueNotifier<double> taxsNotifier =
      ValueNotifier<double>(0.0); // الضريبة
  final ValueNotifier<double> previousDebtsNotifier =
      ValueNotifier<double>(0.0); // المجموع السعر مع الدين
  final ValueNotifier<double> shippingFeesNotifier =
      ValueNotifier<double>(0.0); // المجموع السعر مع الدين و اجور الشحن

  /// تحويل الأرقام العربية إلى أرقام إنجليزية
  String convertArabicToEnglish(String text) {
    return text.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    List<String> columnTitles = [
      S().type,
      S().color,
      S().yarn_number,
      S().length,
      '${S().weight} ${S().total}',
      S().unit,
      S().quantity,
      S().price,
      S().total_price,
    ];

    List<DataColumn> columns = columnTitles.map((title) {
      return DataColumn(
        label: Text(title),
      );
    }).toList();

    List<String> selectedIds = invoiceProvider.selectionState.keys
        .where((id) => invoiceProvider.selectionState[id] == true)
        .toList();

    Map<String, Map<String, dynamic>> prepareData(
      Map<String, Map<String, dynamic>> aggregatedData,
      Map<String, dynamic> data,
    ) {
      String key =
          '${data['yarn_number']}-${data['type']}-${data['color']}-${data['width']}';

      if (!aggregatedData.containsKey(key)) {
        aggregatedData[key] = {
          'yarn_number': data['yarn_number'],
          'type': data['type'],
          'color': data['color'],
          'width': data['width'],
          'total_weight': 0.0,
          'quantity': 0,
          'length': 0,
          'scanned_data': 0,
        };
      }

      aggregatedData[key]!['total_weight'] +=
          double.tryParse(data['total_weight'].toString()) ?? 0.0;
      aggregatedData[key]!['quantity'] += data['quantity'] is int
          ? data['quantity']
          : int.tryParse(data['quantity'].toString()) ?? 0;
      aggregatedData[key]!['length'] += data['length'] is int
          ? data['length']
          : int.tryParse(data['length'].toString()) ?? 0;
      aggregatedData[key]!['scanned_data'] += 1;

      return aggregatedData;
    }

    Future<Map<String, dynamic>?> fetchDataFromFirestore(String docId) async {
      final monthFolder = '${docId.substring(0, 4)}-${docId.substring(4, 6)}';
      final documentSnapshot = await FirebaseFirestore.instance
          .doc('/products/productsForAllMonths/$monthFolder/$docId')
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        return data;
      }
      return null;
    }

    Future<Map<String, Map<String, dynamic>>> fetchData() async {
      Map<String, Map<String, dynamic>> aggregatedData = {};

      for (String id in selectedIds) {
        final itemData = invoiceProvider.getDataById(id);

        if (itemData != null) {
          List<dynamic> scannedData = itemData['scannedData'] ?? [];

          for (var docId in scannedData) {
            final cachedData = invoiceProvider.getCachedData(docId);

            if (cachedData != null) {
              aggregatedData = prepareData(aggregatedData, cachedData);
            } else {
              final data = await fetchDataFromFirestore(docId);
              if (data != null) {
                aggregatedData = prepareData(aggregatedData, data);
                invoiceProvider.cacheData(docId, data);
              }
            }
          }
        }
      }

      return aggregatedData;
    }

    return Center(
      child: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final aggregatedData = snapshot.data;

            // Initialize totals
            double totalWeight = 0.0;
            int totalQuantity = 0;
            int totalLength = 0;
            int totalScannedData = 0;

            List<DataRow> dataRows = aggregatedData!.entries.map((entry) {
              final itemData = entry.value;
              final groupKey = entry.key;
              final index = aggregatedData.keys
                  .toList()
                  .indexOf(groupKey); // احصل على الفهرس هنا

// تحديث حالة التحديد بناءً على البروفيدر
              _selectedItem = aggregatedData.keys.map((key) {
                return invoiceProvider.getSelectionState(key) ?? false;
              }).toList();

              // Accumulate totals
              totalWeight += itemData['total_weight'] as double;
              totalQuantity += itemData['quantity'] as int;
              totalLength += itemData['length'] as int;
              totalScannedData += itemData['scanned_data'] as int;

              return DataRow(
                cells: [
                  DataCell(Center(
                    child: Text(
                        DataLists().translateType(itemData['type'].toString())),
                  )),
                  DataCell(Center(
                    child: Text(DataLists()
                        .translateType(itemData['color'].toString())),
                  )),
                  DataCell(Center(
                    child: Text(
                        '${DataLists().translateType(itemData['yarn_number'].toString())} D'),
                  )),
                  DataCell(Center(
                    child: Text(
                        '${DataLists().translateType(itemData['length'].toString())} Mt'),
                  )),
                  DataCell(Center(
                    child: Text('${itemData['total_weight']} Kg'),
                  )),
                  DataCell(Center(
                    child: Text('${itemData['scanned_data']} ${S().unit}'),
                  )),
                  DataCell(Center(
                    child: Text(
                        '${DataLists().translateType(itemData['quantity'].toString())} ${S().pcs}'),
                  )),
                  DataCell(Center(
                    child: TextField(
                      controller: invoiceProvider.getPriceController(groupKey),
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (text) {
                        double price = double.tryParse(text) ?? 0.00;
                        double quantity =
                            double.tryParse(itemData['quantity'].toString()) ??
                                0.00;
                        double totalWeight = double.tryParse(
                                itemData['total_weight'].toString()) ??
                            0.00;

                        double totalPrice = _selectedItem[index]
                            ? price * totalWeight
                            : price * quantity;
                        // حفظ السعر الكلي في البروفايدر
                        invoiceProvider.setPrice(groupKey, totalPrice);

                        invoiceProvider.getTotalPriceNotifier(groupKey).value =
                            totalPrice.toString();
                        grandTotalPrice =
                            invoiceProvider.calculateGrandTotalPrice();
                      },
                      decoration: InputDecoration(
                        prefixText: '\$',
                        hintText: '0.00',
                      ),
                    ),
                  )),
                  DataCell(Center(
                    child: ValueListenableBuilder(
                      valueListenable:
                          invoiceProvider.getTotalPriceNotifier(groupKey),
                      builder: (context, value, child) {
                        double totalPrice = double.parse(value.toString());

                        return Text(
                          '\$ ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.redAccent),
                        );
                      },
                    ),
                  )),
                ],
                selected: _selectedItem[index],
                onSelectChanged: (bool? selectedItem) {
                  setState(() {
                    if (selectedItem != null) {
                      _selectedItem[index] = selectedItem;
                      // تحديث حالة التحديد في البروفيدر
                      final key = aggregatedData.keys.toList()[index];
                      invoiceProvider.updateSelectionState(key, selectedItem);
                      invoiceProvider.getPriceController(key).clear();
                      invoiceProvider.getTotalPriceNotifier(groupKey).value =
                          '0.00';
                    }
                  });
                },
              );
            }).toList();

            // Add a row for totals المجموع الاول
            dataRows.add(
              DataRow(
                cells: [
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(
                    child: Text(
                      '$totalLength Mt',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      '$totalWeight Kg',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      '$totalScannedData ${S().unit}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      '$totalQuantity ${S().pcs}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                  DataCell(Center(child: Text('${S().total}  ${S().invoice}'))),
                  DataCell(Center(
                    child: Text(
                      '\$ $grandTotalPrice',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 18),
                    ),
                  )),
                ],
              ),
            );
            print('object $grandTotalPrice');

            // Add a row for totals Tax الضريبة
            dataRows.add(
              DataRow(
                cells: [
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(
                      child:
                          Text('${S().tax} :', textAlign: TextAlign.center))),
                  DataCell(
                    Center(
                      child: TextField(
                        controller: taxController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            String englishNumbers =
                                convertArabicToEnglish(text);
                            double inputValue = double.parse(englishNumbers);
                            taxsNotifier.value = inputValue / 100;
                          } else {
                            taxsNotifier.value = 0.00;
                          }
                        },
                        decoration: InputDecoration(
                          prefixText: '\%',
                          hintText: '0.0',
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: ValueListenableBuilder<double>(
                        valueListenable: taxsNotifier,
                        builder: (context, value, child) {
                          return Text(
                            '${value.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
            final taxValue = 1 + taxsNotifier.value;

            // حساب السعر مع الضريبة
            final grandTotalPriceTaxs = grandTotalPrice * taxValue;

            // Add a row for totals الدين السابق
            dataRows.add(
              DataRow(
                cells: [
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(
                    Center(
                        child: Text(
                      previousDebtsNotifier.value == 0
                          ? S().no_dues
                          : previousDebtsNotifier.value > -1
                              ? S().previous_debt
                              : S().no_previous_religion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: previousDebtsNotifier.value == 0
                              ? Colors.black
                              : previousDebtsNotifier.value > 1
                                  ? Colors.redAccent
                                  : Colors.green),
                    )),
                  ),
                  DataCell(
                    Center(
                      child: TextField(
                        controller: previousDebtController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: previousDebtsNotifier.value == 0
                                ? Colors.black
                                : previousDebtsNotifier.value > -1
                                    ? Colors.redAccent
                                    : Colors.green,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            String englishNumbers =
                                convertArabicToEnglish(text);
                            previousDebtsNotifier.value =
                                double.parse(englishNumbers);
                          } else {
                            previousDebtsNotifier.value = 0.0;
                          }
                        },
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: '0.00',
                        ),
                      ),
                    ),
                  ),

// عرض النتيجة
                  DataCell(
                    Center(
                      child: ValueListenableBuilder<double>(
                        valueListenable: previousDebtsNotifier,
                        builder: (context, value, child) {
                          return Text(
                            '\$ ${value != 0 ? (value + grandTotalPriceTaxs).toStringAsFixed(2) : 0}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: value == 0
                                    ? Colors.black
                                    : value > -1
                                        ? Colors.redAccent
                                        : Colors.green),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );

            // Add a row for totals اجور الشحن
            dataRows.add(
              DataRow(
                cells: [
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(
                      child: Text(S().shipping_fees,
                          textAlign: TextAlign.center))),

// TextField
                  DataCell(
                    Center(
                      child: TextField(
                        controller: shippingFeeController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: shippingFeesNotifier.value > -1
                                ? Colors.redAccent
                                : Colors.green,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            String englishNumbers =
                                convertArabicToEnglish(text);
                            shippingFeesNotifier.value =
                                double.parse(englishNumbers);
                          } else {
                            shippingFeesNotifier.value = 0.0;
                          }
                        },
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: '0.00',
                        ),
                      ),
                    ),
                  ),

// Display the total
                  DataCell(
                    Center(
                      child: ValueListenableBuilder<double>(
                        valueListenable: shippingFeesNotifier,
                        builder: (context, value, child) {
                          return Text(
                            '\$ ${value != 0 ? (value + previousDebtsNotifier.value + grandTotalPriceTaxs).toStringAsFixed(2) : 0}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  value > -1 ? Colors.redAccent : Colors.green,
                              fontSize: 18,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );

            final totalAllMoney = grandTotalPriceTaxs +
                previousDebtsNotifier.value +
                shippingFeesNotifier.value;

            //   print('ssss $TotalAllMoney');
            // Add a row for totals قيمة الفاتورة
            dataRows.add(
              DataRow(
                cells: [
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(child: Text(''))),
                  DataCell(Center(
                      child: Text(S().invoice_amount_due,
                          textAlign: TextAlign.center))),
                  DataCell(Center(
                      child: ElevatedButton(
                    child: Text('Click to calculate'),
                    onPressed: () {
                      setState(() {});
                    },
                  ))),
                  DataCell(
                    Center(
                        child: Text(
                      '\$ ${totalAllMoney.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 18),
                    )),
                  ),
                ],
              ),
            );

            return Directionality(
              textDirection: TextDirection.ltr,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    DataTable(
                      columns: columns,
                      rows: dataRows,
                      headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                          decorationThickness: 100),
                      headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.black),
                      dataTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decorationThickness: 100),
                    ),
                    SizedBox(height: 20),
                    // عمل شكل فاتورة

                    ElevatedButton.icon(
                      onPressed: () async {
                        final aggregatedData = await fetchData();

                        // قائمة لجمع جميع الأسعار
                        final prices = aggregatedData.keys.map((groupKey) {
                          return double.tryParse(invoiceProvider
                                  .getPriceController(groupKey)
                                  .text) ??
                              0.00;
                        }).toList();

                        // جلب جميع الأسعار من البروفايدر
                        final allPrices = aggregatedData.keys.map((groupKey) {
                          return invoiceProvider.getPrice(groupKey);
                        }).toList();
                        final total = grandTotalPriceTaxs +
                            previousDebtsNotifier.value +
                            shippingFeesNotifier.value;

                        await generatePdf(
                            context,
                            aggregatedData,
                            grandTotalPrice,
                            previousDebtsNotifier.value,
                            shippingFeesNotifier.value,
                            prices,
                            allPrices,
                            total,
                            taxsNotifier.value);
                      },
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text(S().view_invoice),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
                child: Text(S().no_data_found, textAlign: TextAlign.center));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    taxController.dispose();
    previousDebtController.dispose();
    shippingFeeController.dispose();
    super.dispose();
  }
}
