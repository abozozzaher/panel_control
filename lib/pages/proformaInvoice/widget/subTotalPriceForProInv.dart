import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow subTotalPriceForProInv(double totalPrices) {
  return DataRow(cells: [
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    DataCell(Center(child: Text(S().total_price))),
    const DataCell(Text('')),
    DataCell(Center(
        child: Text('\$${totalPrices.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    const DataCell(Text('')),
  ]);
}
