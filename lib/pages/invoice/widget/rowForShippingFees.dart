import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowForShippingFees(
    double grandTotalPriceTaxs,
    TextEditingController shippingFeeController,
    String Function(String text) convertArabicToEnglish,
    ValueNotifier<double> shippingFeesNotifier) {
  return DataRow(
    cells: [
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(
          Center(child: Text(S().shipping_fees, textAlign: TextAlign.center))),

// TextField
      DataCell(
        Center(
          child: TextField(
            controller: shippingFeeController,
            keyboardType: TextInputType.number,
            style: TextStyle(
                color: shippingFeesNotifier.value > -1
                    ? Colors.redAccent
                    : Colors.green,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            onChanged: (text) {
              if (text.isNotEmpty) {
                String englishNumbers = convertArabicToEnglish(text);
                shippingFeesNotifier.value = double.parse(englishNumbers);
              } else {
                shippingFeesNotifier.value = 0.0;
              }
            },
            decoration: InputDecoration(
              prefixText: '\$',
              hintText: '0.00',
            ),
          ),
        ),
      ),

// Display the total
      DataCell(
        Center(
          child: ValueListenableBuilder<double>(
            valueListenable: shippingFeesNotifier,
            builder: (context, value, child) {
              return Text(
                '\$ ${value != 0 ? (value + grandTotalPriceTaxs) : 0}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: value > -1 ? Colors.redAccent : Colors.green,
                  fontSize: 18,
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}
