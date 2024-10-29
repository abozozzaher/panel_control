import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:html' as html;

import '../../data/data_lists.dart';

Future<void> exportToExcel(List<String> columnHeaders,
    Map<String, Map<String, dynamic>> aggregatedData) async {
  final now = DateTime.now();
  final formattedDateXlsx = '${now.day}-${now.month}-${now.year}';

  final xlsio.Workbook workbook = xlsio.Workbook();
  final xlsio.Worksheet sheet = workbook.worksheets[0];

  // إضافة العناوين للعمود الأول في Excel
  for (int i = 0; i < columnHeaders.length; i++) {
    var cell = sheet.getRangeByIndex(1, i + 1);
    cell.setText(columnHeaders[i]);
    cell.cellStyle.bold = true;
    cell.cellStyle.fontColor = '#FF0000';
  }

  // إضافة البيانات في الصفوف التالية
  int row = 2; // البدء من الصف الثاني حيث أن الصف الأول هو للعناوين
  aggregatedData.entries.forEach((entry) {
    final itemData = entry.value;
    sheet
        .getRangeByIndex(row, 1)
        .setText(DataLists().translateType(itemData['type'].toString()));
    sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
    sheet
        .getRangeByIndex(row, 2)
        .setText(DataLists().translateType(itemData['color'].toString()));
    sheet.getRangeByIndex(row, 2).cellStyle.bold = true;
    sheet
        .getRangeByIndex(row, 3)
        .setNumber(double.tryParse(itemData['width'].toString()) ?? 0);

    sheet
        .getRangeByIndex(row, 4)
        .setNumber(double.tryParse(itemData['yarn_number'].toString()) ?? 0);
    sheet.getRangeByIndex(row, 5).setNumber(itemData['quantity']);
    sheet
        .getRangeByIndex(row, 6)
        .setNumber(double.tryParse(itemData['length'].toString()) ?? 0);
    sheet.getRangeByIndex(row, 7).setNumber(itemData['total_length']);
    sheet.getRangeByIndex(row, 8).setNumber(itemData['total_weight']);
    sheet.getRangeByIndex(row, 9).setNumber(itemData['scanned_data']);
    row++;
  });

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  // تنزيل الملف على الويب
  final blob = html.Blob([bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'products_all_data$formattedDateXlsx.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}
