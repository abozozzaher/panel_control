import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow subTotalPriceForProInv(double totalPrices) {
  return DataRow(cells: [
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Center(child: Text(S().total_price))),
    DataCell(Text('')),
    DataCell(Center(
        child: Text('\$${totalPrices.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    DataCell(Text('')),
  ]);
}
