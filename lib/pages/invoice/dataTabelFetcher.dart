import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../provider/invoice_provider.dart';

class DataTabelFetcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    // افترض أن هناك قائمة من الـ ids لتكون بمثابة مثال
    List<String> selectedIds = invoiceProvider.selectionState.keys
        .where((id) => invoiceProvider.selectionState[id] == true)
        .toList();

    Future<Map<String, Map<String, dynamic>>> fetchData() async {
      Map<String, Map<String, dynamic>> aggregatedData = {};

      for (String id in selectedIds) {
        // جلب البيانات من provider
        final itemData = invoiceProvider.getDataById(id);
        if (itemData != null) {
          List<dynamic> scannedData = itemData['scannedData'] ?? [];

          // جلب بيانات المستندات من Firestore استنادًا إلى scannedData
          for (var docId in scannedData) {
            final monthFolder =
                '${docId.substring(0, 4)}-${docId.substring(4, 6)}';
            final documentSnapshot = await FirebaseFirestore.instance
                .doc('/products/productsForAllMonths/$monthFolder/$docId')
                .get();

            if (documentSnapshot.exists) {
              final data = documentSnapshot.data() as Map<String, dynamic>;

              String key =
                  '${data['yarn_number']}-${data['type']}-${data['color']}-${data['width']}';

              if (!aggregatedData.containsKey(key)) {
                aggregatedData[key] = {
                  'yarn_number': data['yarn_number'],
                  'type': data['type'],
                  'color': data['color'],
                  'width': data['width'],
                  'total_weight': 0,
                  'quantity': 0,
                  'length': 0,
                  'scanned_data': 0,
                };
              }
              aggregatedData[key]!['total_weight'] +=
                  data['total_weight'] is int
                      ? data['total_weight']
                      : int.tryParse(data['total_weight'].toString()) ?? 0;
              aggregatedData[key]!['quantity'] += data['quantity'] is int
                  ? data['quantity']
                  : int.tryParse(data['quantity'].toString()) ?? 0;
              aggregatedData[key]!['length'] += data['length'] is int
                  ? data['length']
                  : int.tryParse(data['length'].toString()) ?? 0;
              aggregatedData[key]!['scanned_data'] += 1;
            }
          }
        }
      }

      return aggregatedData;
    }

    return FutureBuilder<Map<String, Map<String, dynamic>>>(
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
                  return DataRow(cells: [
                    DataCell(Center(
                        child: Text(itemData['type'].toString(),
                            style: const TextStyle(color: Colors.black)))),
                    DataCell(Center(
                        child: Text(itemData['color'].toString(),
                            style: const TextStyle(color: Colors.black)))),
                    DataCell(Center(
                        child: Text('${itemData['width']} mm',
                            style: const TextStyle(color: Colors.black)))),
                    DataCell(Center(
                        child: Text('${itemData['yarn_number']} D',
                            style: const TextStyle(color: Colors.black)))),
                    DataCell(Center(
                        child: Text('${itemData['quantity']} Pcs',
                            style: const TextStyle(color: Colors.black)))),
                    DataCell(Center(
                        child: Text('${itemData['length']} Mt',
                            style: const TextStyle(color: Colors.black)))),
                    DataCell(Center(
                        child: Text('${itemData['total_weight']} Kg',
                            style: const TextStyle(color: Colors.black)))),
                    DataCell(Center(
                        child: Text('${itemData['scanned_data']}',
                            style: const TextStyle(color: Colors.black)))),
                  ]);
                }).toList(),
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}
