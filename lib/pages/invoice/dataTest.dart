import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/invoice_provider.dart';

class DataFetcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    // افترض أن هناك قائمة من الـ ids لتكون بمثابة مثال
    List<String> selectedIds = invoiceProvider.selectionState.keys
        .where((id) => invoiceProvider.selectionState[id] == true)
        .toList();

    // جلب البيانات بناءً على الـ ids المحددة
    List<Map<String, dynamic>?> datatr =
        selectedIds.map((id) => invoiceProvider.getDataById(id)).toList();

    // إنشاء Future للبيانات
    Future<List<Map<String, dynamic>?>> fetchData() async {
      List<Map<String, dynamic>?> data = [];

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
              final dataData = documentSnapshot.data() as Map<String, dynamic>;

              data.add(dataData);
            }
            print("ssss");
            print('sdsds ${documentSnapshot.data()}');
          }
        }
      }

      return data;
    }

    return FutureBuilder<List<Map<String, dynamic>?>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data;

          return Container(
            child: Column(
              children: data!.map((itemData) {
                if (itemData != null) {
                  return Text('Data: ${itemData} + ${datatr.length}');
                } else {
                  return Text('No data available');
                }
              }).toList(),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}
