import 'package:flutter/material.dart';

import '../../../data/data_lists.dart';
import '../../../generated/l10n.dart';
import '../../../provider/invoice_provider.dart';

DataRow itemForTabelProInv(InvoiceProvider invoiceProvider) {
  final dataLists = DataLists();
  String _selectedType = ''; // القيمة الافتراضية

  return DataRow(
    cells: [
      DataCell(Center(
        child: Text(dataLists.types[0][1]), // الحصول على نوع المنتج
      )),
      DataCell(Center(
        child: Text(dataLists.colors[0][1]), // الحصول على اللون
      )),
      DataCell(Center(
        child: Text('${dataLists.yarnNumbers[0][1]} D'), // الحصول على رقم الخيط
      )),
      DataCell(Center(
        child: Text('${dataLists.length[0][1]} Mt'), // الحصول على الطول
      )),
      DataCell(Center(
        child: Text('${dataLists.weights[0][1]} Kg'), // الحصول على الوزن
      )),
      DataCell(Center(
        child: Text(' للحذف ${S().unit}'), // البيانات الممسوحة
      )),
      DataCell(Center(
        child: Text('${dataLists.quantity[0][1]} ${S().pcs}'), // الكمية
      )),
      DataCell(Center(
        child: Text('${dataLists.quantity[0][1]} ${S().pcs}'), // الكمية
      )),
      DataCell(Center(
        child: Text('${dataLists.quantity[0][1]} ${S().pcs}'), // الكمية
      )),
    ],
  );
}
