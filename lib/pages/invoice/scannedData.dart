import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../service/scan_item_service.dart';

class ScannedDataList extends StatelessWidget {
  final List<String> scannedData;
  final List<DocumentSnapshot> documentSnapshots;

  ScannedDataList({required this.scannedData, required this.documentSnapshots});

  final ScanItemService scanItemService = ScanItemService();

  @override
  Widget build(BuildContext context) {
    print('object1');
    print(scannedData);
    print('object2');
    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text('Scanned Data')),
          DataColumn(label: Text('Created By')),
        ],
        rows: scannedData.map((data) {
          int index = scannedData.indexOf(data);
          List<dynamic> scannedDataList =
              documentSnapshots[index]['scannedData'];

          List<Future<void>> transformedCodes = scannedDataList.map((code) {
            String prefix = code.substring(0, 4);
            String middle = code.substring(4, 6);

            // Construct the transformed code
            String transformedCode =
                'https://panel-control-company-zaher.web.app/$prefix-$middle/$scannedDataList';

            //  return transformedCode;

            return scanItemService
                .fetchDataFromFirebaseForInvoice(transformedCode)
                .then((data) {
              print('Fetched data: $data معلومات الكود');
              print('Fetched data: $transformedCode  بس كود مع الرابط');
              print('Fetched data: $scannedDataList بس كود');
            });
          }).toList();
          String scannedDataString = transformedCodes.join('\n\n');
// المشكلة هنا 44444
          return DataRow(
            cells: [
              DataCell(Text(data)),
              DataCell(Text(scannedDataString)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
