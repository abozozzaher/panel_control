// Add a row for totals المجموع الاول
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowForTotals(int totalLength, double totalWeight, int totalScannedData,
    int totalQuantity, grandTotalPrice) {
  return DataRow(
    cells: [
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      DataCell(Center(
        child: Text(
          '$totalLength Mt',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(
        child: Text(
          '$totalWeight Kg',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(
        child: Text(
          '$totalScannedData ${S().unit}',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(
        child: Text(
          '$totalQuantity ${S().pcs}',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Center(child: Text('${S().total}  ${S().invoice}'))),
      DataCell(Center(
        child: Text(
          '\$ ${grandTotalPrice.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              fontSize: 18),
        ),
      )),
    ],
  );
}
