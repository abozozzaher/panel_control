import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../provider/scan_item_provider.dart';
import '../../service/scan_item_service.dart';

class ScanDataTableWidgets {
  final ScanItemService scanItemService = ScanItemService();

  Container scrollViewScannedDataTableWidget(BuildContext context) {
    final provider = Provider.of<ScanItemProvider>(context);
    final codeDetailes = provider.codeDetails;

    // تأكد من أن البيانات تصل هنا بشكل صحيح
    print('Code Details: $codeDetailes'); // التحقق من البيانات هنا

    print('Current Time: ${DateTime.now()}');
    // print('Last Saved Time: ${lastSaved}');
    return Container(
      color: Colors.grey,
      child: SingleChildScrollView(
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
                  label: Text('${S().scanned}',
                      style: TextStyle(color: Colors.greenAccent))),
            ],
            rows: buildRows(codeDetailes),
          ),
        ),
      ),
    );
  }

  List<DataRow> buildRows(Map<String, Map<String, dynamic>> codeDetailes) {
    Map<String, Map<String, dynamic>> aggregatedData = {};

    for (var entry in codeDetailes.entries) {
      var data = entry.value;

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
    }

    return aggregatedData.entries.map((entry) {
      var data = entry.value;
      return DataRow(cells: [
        DataCell(Center(
          child: Text(data['type'].toString(),
              style: const TextStyle(color: Colors.black)),
        )),
        DataCell(Center(
          child: Text(data['color'].toString(),
              style: const TextStyle(color: Colors.black)),
        )),
        DataCell(Center(
            child: Text('${data['width']} mm',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['yarn_number']} D',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['quantity']} ${S().pcs}',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['length']} Mt',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['total_weight']} Kg',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text(data['scanned_data'].toString(),
                style: const TextStyle(color: Colors.black)))),
      ]);
    }).toList();
  }
}
