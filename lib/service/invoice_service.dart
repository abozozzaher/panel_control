import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/data_lists.dart';
import '../provider/invoice_provider.dart';

class InvoiceService {
  final BuildContext context;
  final InvoiceProvider invoiceProvider;

  InvoiceService(this.context, this.invoiceProvider);
  final DataLists dataLists = DataLists();

  String generateInvoiceCode() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';

    return 'INV-$formattedDate';
  }

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
    List<String> selectedIds = invoiceProvider.selectionState.keys
        .where((id) => invoiceProvider.selectionState[id] == true)
        .toList();
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
}
