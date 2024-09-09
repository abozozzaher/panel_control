// data_row_utils.dart

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

/*
 temporaryRow = createTemporaryRow(
                        setState: setState,
                        allQuantity: allQuantity,
                        selectedType: selectedType,
                        selectedColor: selectedColor,
                        selectedYarnNumber: selectedYarnNumber,
                        selectedLength: selectedLength,
                        selectedWeight: selectedWeight,
                        selectedQuantity: selectedQuantity,
                        price: price,
                        confirmedRows: confirmedRows,
                        temporaryRow: temporaryRow,
                        priceController: priceController,
                        allQuantityController: allQuantityController,
                      );
                      */
DataRow createTemporaryRow({
  required void Function(VoidCallback fn) setState,
  required String? allQuantity,
  required String? selectedType,
  required String? selectedColor,
  required String? selectedYarnNumber,
  required String? selectedLength,
  required String? selectedWeight,
  required String? selectedQuantity,
  required double price,
  required List<DataRow> confirmedRows,
  required DataRow? temporaryRow,
  required TextEditingController priceController,
  required TextEditingController allQuantityController,
}) {
  double totalLength = (double.tryParse(allQuantity ?? '0') ?? 0) *
      (double.tryParse(selectedLength ?? '0') ?? 0);

  double totalWight = (double.tryParse(allQuantity ?? '0') ?? 0) *
      ((double.tryParse(selectedWeight ?? '0') ?? 0) / 1000);

  double totalUnit = (double.tryParse(allQuantity ?? '0') ?? 0) /
      (double.tryParse(selectedQuantity ?? '0') ?? 0);

  String totalPrice = (price * (double.tryParse(allQuantity.toString()) ?? 0))
      .toStringAsFixed(2);

  return DataRow(cells: [
    DataCell(Center(
        child: Text(selectedType ?? "",
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child: Text(selectedColor ?? "",
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child: Text(selectedYarnNumber ?? "",
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child: Text('${totalLength.toString()} Mt',
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child: Text('${totalWight.toStringAsFixed(2)} Kg',
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child: Text('${totalUnit.toStringAsFixed(0)} ${S().unit}',
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child: Text('$allQuantity ${S().pcs}',
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child: Text('\$${price..toStringAsFixed(2)}',
            textAlign: TextAlign.center, maxLines: 1))),
    DataCell(Center(
        child:
            Text('\$$totalPrice', textAlign: TextAlign.center, maxLines: 1))),
    // زر التعديل
    DataCell(IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        setState(() {
          // استرداد البيانات المدخلة إلى الحقول للتعديل
          selectedType = selectedType;
          selectedColor = selectedColor;
          selectedYarnNumber = selectedYarnNumber;
          selectedLength = selectedLength;
          selectedWeight = selectedWeight;
          selectedQuantity = selectedQuantity;
          priceController.text = price.toString();
          allQuantityController.text = allQuantity!;
          temporaryRow = null; // حذف السطر المؤقت عند التعديل
        });
      },
    )),
    // زر الحذف
    DataCell(IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {
        setState(() {
          confirmedRows.remove(temporaryRow);
          temporaryRow = null; // حذف السطر المؤقت عند الحذف
        });
      },
    )),
  ]);
}
