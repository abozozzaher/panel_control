import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowForAllTotals(double totalAllMoney, VoidCallback onPressed) {
  return DataRow(
    cells: [
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(
          child: Text(S().invoice_amount_due, textAlign: TextAlign.center))),
      DataCell(Center(
          child: ElevatedButton(
              child: Text('Click to calculate'), onPressed: onPressed))),
      DataCell(
        Center(
            child: Text(
          '\$ ${totalAllMoney.toStringAsFixed(2)}',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              fontSize: 18),
        )),
      ),
    ],
  );
}
