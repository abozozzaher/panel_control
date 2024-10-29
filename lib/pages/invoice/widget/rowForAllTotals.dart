import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowForAllTotals(double totalAllMoney, VoidCallback onPressed) {
  return DataRow(
    cells: [
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      DataCell(Center(
          child: Text(S().invoice_amount_due, textAlign: TextAlign.center))),
      DataCell(Center(
          child: ElevatedButton(
              onPressed: onPressed, child: Text(S().click_to_calculate)))),
      DataCell(
        Center(
            child: Text(
          '\$ ${totalAllMoney.toStringAsFixed(2)}',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              fontSize: 18),
        )),
      ),
    ],
  );
}
