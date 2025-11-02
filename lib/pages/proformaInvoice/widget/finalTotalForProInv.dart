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
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    const DataCell(Text('')),
    DataCell(Center(
        child: Text(S().final_total,
            style: TextStyle(
                color: finalTotal > 1 ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: ElevatedButton(
            onPressed: onPressed, child: Text(S().click_to_calculate)))),
    DataCell(Center(
        child: Text('\$${finalTotal.toStringAsFixed(2)}',
            style: TextStyle(
                color: finalTotal > 1 ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    const DataCell(Text('')),
    const DataCell(Text('')),
  ]);
}
