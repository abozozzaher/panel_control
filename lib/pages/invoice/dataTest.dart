import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/invoice_provider.dart';

class DataFetcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceProvider>(context);

    // افترض أن هناك قائمة من الـ ids لتكون بمثابة مثال
    List<String> selectedIds = provider.selectionState.keys
        .where((id) => provider.selectionState[id] == true)
        .toList();

    // جلب البيانات بناءً على الـ ids المحددة
    List<Map<String, dynamic>?> data =
        selectedIds.map((id) => provider.getDataById(id)).toList();

    return Container(
      child: Column(
        children: data.map((itemData) {
          final List<dynamic> scannedData = itemData!['scannedData'];
          if (itemData != null) {
            // عرض البيانات كما تحتاج
            return Text('Data: $scannedData ');
          } else {
            return Text('No data available');
          }
        }).toList(),
      ),
    );
  }
}
