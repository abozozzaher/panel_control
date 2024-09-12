import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow finalTotalForProInv(double finalTotal, onPressed) {
  return DataRow(cells: [
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Center(
        child: Text(S().final_total,
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: ElevatedButton(
            child: Text(S().click_to_calculate), onPressed: onPressed))),
    DataCell(Center(
        child: Text('\$${finalTotal.toStringAsFixed(2)}',
            style:
                TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    DataCell(Text('')),
  ]);
}
