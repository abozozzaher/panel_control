import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow finalTotalForProInv(double finalTotal, onPressed) {
  return DataRow(cells: [
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    DataCell(Center(
        child: Text(S().final_total,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: ElevatedButton(
            onPressed: onPressed, child: Text(S().click_to_calculate)))),
    DataCell(Center(
        child: Text('\$${finalTotal.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    const DataCell(Text('')),
  ]);
}
