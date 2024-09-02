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
  double taxs = .0; // الضريبة

  double previousDebts = 0.0; // المجموع السعر مع الدين
  double shippingFees = 0.0; // المجموع السعر مع الدين و اجور الشحن

  bool _canUpdate = true;
  List<bool> _selectedItem = [];

  TextEditingController tax = TextEditingController();
  TextEditingController previousDebt = TextEditingController();
  TextEditingController shippingFee = TextEditingController();

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
                        Future.delayed(Duration(seconds: 3), () {
                          // حفظ السعر الكلي في البروفايدر
                          invoiceProvider.setPrice(groupKey, totalPrice);
                        });
                        invoiceProvider.getTotalPriceNotifier(groupKey).value =
                            totalPrice.toString();
                        if (_canUpdate) {
                          _canUpdate = false;
                          Future.delayed(Duration(seconds: 3), () {
                            setState(() {
                              grandTotalPrice =
                                  invoiceProvider.calculateGrandTotalPrice();
                            });

                            _canUpdate = true;
                          });
                        }
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
                      '\$ ${grandTotalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 18),
                    ),
                  )),
                ],
              ),
            );
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
                        controller: tax,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            Future.delayed(Duration(milliseconds: 3000), () {
                              setState(() {
                                double inputValue = double.parse(text);
                                taxs = inputValue / 100;
                              });
                            });
                          } else {
                            setState(() {
                              taxs = .0;
                            });
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
                      child: Text(
                        '${(taxs).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
            // حساب السعر مع الضريبة
            final grandTotalPriceTaxs = grandTotalPrice * (1 + taxs);
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
                      previousDebts == 0
                          ? S().no_dues
                          : previousDebts > -1
                              ? S().previous_debt
                              : S().no_previous_religion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: previousDebts == 0
                              ? Colors.black
                              : previousDebts > 1
                                  ? Colors.redAccent
                                  : Colors.green),
                    )),
                  ),
                  DataCell(
                    Center(
                      child: TextField(
                        controller: previousDebt,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: previousDebts == 0
                                ? Colors.black
                                : previousDebts > -1
                                    ? Colors.redAccent
                                    : Colors.green,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            Future.delayed(Duration(milliseconds: 3000), () {
                              setState(() {
                                double inputValue = double.parse(text);
                                previousDebts = inputValue;
                              });
                            });
                          } else {
                            setState(() {
                              previousDebts = 0.0;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: '0.00',
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        '\$ ${previousDebts != 0 ? (previousDebts + grandTotalPriceTaxs).toStringAsFixed(2) : 0}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: previousDebts == 0
                                ? Colors.black
                                : previousDebts > -1
                                    ? Colors.redAccent
                                    : Colors.green),
                      ),
                    ),
                  )
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
                  DataCell(
                    Center(
                      child: TextField(
                        controller: shippingFee,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: shippingFees > -1
                                ? Colors.redAccent
                                : Colors.green,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            Future.delayed(Duration(milliseconds: 3000), () {
                              setState(() {
                                double inputValue = double.parse(text);
                                shippingFees = inputValue;
                              });
                            });
                          } else {
                            setState(() {
                              shippingFees = 0.0;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: '0.00',
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        '\$ ${shippingFees != 0 ? (shippingFees + previousDebts + grandTotalPriceTaxs).toStringAsFixed(2) : 0}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: shippingFees > -1
                              ? Colors.redAccent
                              : Colors.green,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );

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
                  DataCell(Center(child: Text(''))),
                  DataCell(
                    Center(
                      child: Text(
                        '\$ ${(previousDebts + grandTotalPriceTaxs + shippingFees).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
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
                        final total =
                            grandTotalPriceTaxs + previousDebts + shippingFees;

                        await generatePdf(
                            context,
                            aggregatedData,
                            grandTotalPrice,
                            previousDebts,
                            shippingFees,
                            prices,
                            allPrices,
                            total,
                            taxs);
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
}
