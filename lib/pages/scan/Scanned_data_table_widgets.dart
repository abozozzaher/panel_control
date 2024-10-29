import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../provider/scan_item_provider.dart';
import '../../service/scan_item_service.dart';

class ScanDataTableWidgets {
  final ScanItemService scanItemService = ScanItemService();

  Container scrollViewScannedDataTableWidget(BuildContext context) {
    final provider = Provider.of<ScanItemProvider>(context);
    final codeDetailes = provider.codeDetails;

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
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
              DataColumn(
                  label: Text(S().color,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
              DataColumn(
                  label: Text(S().width,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
              DataColumn(
                  label: Text(S().yarn_number,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
              DataColumn(
                  label: Text(S().quantity,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
              DataColumn(
                  label: Text(S().length,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
              DataColumn(
                  label: Text('${S().weight} ${S().total}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
              DataColumn(
                  label: Text(S().scanned,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent))),
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
          child: Text(DataLists().translateType(data['type'].toString()),
              textAlign: TextAlign.center, textDirection: TextDirection.ltr),
        )),
        DataCell(Center(
          child: Text(DataLists().translateType(data['color'].toString()),
              textAlign: TextAlign.center, textDirection: TextDirection.ltr),
        )),
        DataCell(Center(
            child: Text('${data['width']} mm',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr))),
        DataCell(Center(
            child: Text('${data['yarn_number']} D',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr))),
        DataCell(Center(
            child: Text('${data['quantity']} ${S().pcs}',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr))),
        DataCell(Center(
            child: Text('${data['length']} Mt',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr))),
        DataCell(Center(
            child: Text('${data['total_weight']} Kg',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr))),
        DataCell(Center(
            child: Text(data['scanned_data'].toString(),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr))),
      ]);
    }).toList();
  }
}
