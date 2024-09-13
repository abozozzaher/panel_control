import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow taxForProInv(double tax, TextEditingController taxController) {
  return DataRow(cells: [
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Center(
        child: Text('${S().tax} (%)',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    DataCell(Center(
      child: Container(
        width: 50,
        child: TextField(
          controller: taxController,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            //   setState(() {});
          },
        ),
      ),
    )),
    DataCell(Center(
        child: Text('\$${tax.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    DataCell(Text('')),
  ]);
}
