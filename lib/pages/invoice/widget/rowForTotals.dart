// Add a row for totals المجموع الاول
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowForTotals(int totalLength, double totalWeight, int totalScannedData,
    int totalQuantity, grandTotalPrice) {
  return DataRow(
    cells: [
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(
        child: Text(
          '$totalLength Mt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(
        child: Text(
          '$totalWeight Kg',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(
        child: Text(
          '$totalScannedData ${S().unit}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(
        child: Text(
          '$totalQuantity ${S().pcs}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(child: Text('${S().total}  ${S().invoice}'))),
      DataCell(Center(
        child: Text(
          '\$ $grandTotalPrice',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              fontSize: 18),
        ),
      )),
    ],
  );
}
