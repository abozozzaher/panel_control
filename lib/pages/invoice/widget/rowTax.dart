import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowTax(
    TextEditingController taxController,
    String Function(String text) convertArabicToEnglish,
    ValueNotifier<double> taxsNotifier) {
  return DataRow(
    cells: [
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      DataCell(
          Center(child: Text('${S().tax} :', textAlign: TextAlign.center))),
      DataCell(
        Center(
          child: TextField(
            controller: taxController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            onChanged: (text) {
              if (text.isNotEmpty) {
                String englishNumbers = convertArabicToEnglish(text);
                double inputValue = double.parse(englishNumbers);
                taxsNotifier.value = inputValue / 100;
              } else {
                taxsNotifier.value = 0.00;
              }
            },
            decoration: const InputDecoration(
              prefixText: '%',
              hintText: '0.0',
            ),
          ),
        ),
      ),
      DataCell(
        Center(
          child: ValueListenableBuilder<double>(
            valueListenable: taxsNotifier,
            builder: (context, value, child) {
              return Text(
                '${value.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
