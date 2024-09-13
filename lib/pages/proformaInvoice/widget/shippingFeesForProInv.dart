import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow shippingFeesForProInv(double totalPricesAndTaxAndShippingFee,
    TextEditingController shippingController) {
  return DataRow(cells: [
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Text('')),
    DataCell(Center(child: Text(S().shipping_fees))),
    DataCell(Center(
      child: Container(
        width: 100,
        child: TextField(
          controller: shippingController,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            //  setState(() {});
          },
        ),
      ),
    )),
    DataCell(Center(
        child: Text('\$${totalPricesAndTaxAndShippingFee.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    DataCell(Text('')),
  ]);
}
