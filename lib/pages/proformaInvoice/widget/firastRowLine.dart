import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow firastRowLine(
    double totalLength,
    double totalWight,
    double totalUnit,
    String totalPrice,
    String? selectedType,
    String? selectedColor,
    String? selectedYarnNumber,
    String? allQuantity,
    double price) {
  return DataRow(cells: [
    const DataCell(Text('0')),
    DataCell(Center(
        child: Text(selectedType ?? "",
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text(selectedColor ?? "",
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text('${selectedYarnNumber}D',
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text('${totalLength.toStringAsFixed(0)} Mt',
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text('${totalWight.toStringAsFixed(2)} Kg',
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text('${totalUnit.toStringAsFixed(0)} ${S().unit}',
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text('$allQuantity ${S().pcs}',
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text('\$${price.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),
    DataCell(Center(
        child: Text('\$$totalPrice',
            textAlign: TextAlign.center,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)))),

    // زر الحذف
    const DataCell(Text('')),
  ]);
}
