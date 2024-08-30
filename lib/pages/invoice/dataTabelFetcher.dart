import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../provider/invoice_provider.dart';

class DataTabelFetcher extends StatelessWidget {
  final DataLists dataLists = DataLists();

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    // افترض أن هناك قائمة من الـ ids لتكون بمثابة مثال
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
        print(DateFormat('HH:mm:ss').format(DateTime.now()));
        print('aaaaa1');
        print('Fetched Data: $data');
        print(DateFormat('HH:mm:ss').format(DateTime.now()));
        return data;
      }
      return null;
    }

    Future<Map<String, Map<String, dynamic>>> fetchData() async {
      Map<String, Map<String, dynamic>> aggregatedData = {};
      print('Cached Data: 1');

      for (String id in selectedIds) {
        print('Cached Data: 2 $selectedIds , sssss $id');

        // جلب البيانات من provider
        final itemData = invoiceProvider.getDataById(id);
        print('Cached Data: 3 $itemData');

        if (itemData != null) {
          print('Cached Data: 4 $itemData');

          List<dynamic> scannedData = itemData['scannedData'] ?? [];

          for (var docId in scannedData) {
            // Check if data is already available in provider
            final cachedData = invoiceProvider.getCachedData(docId);

            if (cachedData != null) {
              print('Cached Data: $cachedData');

              // استخدم البيانات المخزنة في الكاش
              aggregatedData = prepareData(aggregatedData, cachedData);
            } else {
              // Fetch data from Firestore
              final data = await fetchDataFromFirestore(docId);
              if (data != null) {
                aggregatedData = prepareData(aggregatedData, data);

                // Cache the data in the provider
                invoiceProvider.cacheData(docId, data);
              }
            }
          }
        }
      }

      print('Aggregated Data: $aggregatedData');
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

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                        label: Text(S().type,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().color,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().width,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().yarn_number,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().quantity,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().length,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text('${S().weight} ${S().total}',
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().scanned,
                            style: TextStyle(color: Colors.greenAccent))),
                  ],
                  rows: aggregatedData!.entries.map((entry) {
                    final itemData = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Center(
                          child: Text(
                            DataLists()
                                .translateType(itemData['type'].toString()),
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                        DataCell(Center(
                          child: Text(
                            DataLists()
                                .translateType(itemData['color'].toString()),
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                        DataCell(Center(
                          child: Text(
                            '${DataLists().translateType(itemData['width'].toString())} mm',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                        DataCell(Center(
                          child: Text(
                            '${DataLists().translateType(itemData['yarn_number'].toString())} D',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                        DataCell(Center(
                          child: Text(
                            '${DataLists().translateType(itemData['quantity'].toString())} Pcs',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                        DataCell(Center(
                          child: Text(
                            '${DataLists().translateType(itemData['length'].toString())} Mt',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                        DataCell(Center(
                          child: Text(
                            '${itemData['total_weight']} Kg',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                        DataCell(Center(
                          child: Text(
                            '${itemData['scanned_data']}',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
