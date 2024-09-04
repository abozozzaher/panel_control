import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowForPreviousDebts(
    double grandTotalPriceTaxs,
    TextEditingController previousDebtController,
    String Function(String text) convertArabicToEnglish,
    ValueNotifier<double> previousDebtsNotifier) {
  return DataRow(
    cells: [
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(Center(child: Text(''))),
      DataCell(
        Center(
            child: Text(
          previousDebtsNotifier.value == 0
              ? S().no_dues
              : previousDebtsNotifier.value > -1
                  ? S().previous_debt
                  : S().no_previous_religion,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: previousDebtsNotifier.value == 0
                  ? Colors.black
                  : previousDebtsNotifier.value > 1
                      ? Colors.redAccent
                      : Colors.green),
        )),
      ),
      DataCell(
        Center(
          child: TextField(
            controller: previousDebtController,
            keyboardType: TextInputType.number,
            style: TextStyle(
                color: previousDebtsNotifier.value == 0
                    ? Colors.black
                    : previousDebtsNotifier.value > -1
                        ? Colors.redAccent
                        : Colors.green,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            onChanged: (text) {
              if (text.isNotEmpty) {
                String englishNumbers = convertArabicToEnglish(text);
                previousDebtsNotifier.value = double.parse(englishNumbers);
              } else {
                previousDebtsNotifier.value = 0.0;
              }
            },
            decoration: InputDecoration(
              prefixText: '\$',
              hintText: '0.00',
            ),
          ),
        ),
      ),

// عرض النتيجة
      DataCell(
        Center(
          child: ValueListenableBuilder<double>(
            valueListenable: previousDebtsNotifier,
            builder: (context, value, child) {
              return Text(
                '\$ ${value != 0 ? (value + grandTotalPriceTaxs).toStringAsFixed(2) : 0}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: value == 0
                        ? Colors.black
                        : value > -1
                            ? Colors.redAccent
                            : Colors.green),
              );
            },
          ),
        ),
      ),
    ],
  );
}
