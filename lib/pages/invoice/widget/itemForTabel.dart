import 'package:flutter/material.dart';

import '../../../data/data_lists.dart';
import '../../../generated/l10n.dart';
import '../../../provider/invoice_provider.dart';

DataRow itemForTabel(
    Map<String, dynamic> itemData,
    InvoiceProvider invoiceProvider,
    String groupKey,
    int index,
    Map<String, Map<String, dynamic>> aggregatedData,
    grandTotalPrice,
    selectedItem,
    ValueChanged<bool?> onChanged) {
  return DataRow(
    cells: [
      DataCell(Center(
        child: Text(DataLists().translateType(itemData['type'].toString()),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1),
      )),
      DataCell(Center(
        child: Text(DataLists().translateType(itemData['color'].toString()),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1),
      )),
      DataCell(Center(
        child: Text(
            '${DataLists().translateType(itemData['yarn_number'].toString())} D',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1),
      )),
      DataCell(Center(
        child: Text(
            '${DataLists().translateType(itemData['length'].toString())} Mt',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1),
      )),
      DataCell(Center(
        child: Text('${itemData['total_weight']} Kg',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1),
      )),
      DataCell(Center(
        child: Text('${itemData['scanned_data']} ${S().unit}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1),
      )),
      DataCell(Center(
        child: Text(
            '${DataLists().translateType(itemData['quantity'].toString())} ${S().pcs}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1),
      )),
      DataCell(Center(
        child: TextField(
          controller: invoiceProvider.getPriceController(groupKey),
          style: const TextStyle(
              color: Colors.redAccent, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          onChanged: (text) {
            double price = double.tryParse(text) ?? 0.00;
            double quantity =
                double.tryParse(itemData['quantity'].toString()) ?? 0.00;
            double totalWeight =
                double.tryParse(itemData['total_weight'].toString()) ?? 0.00;

            double totalPrice =
                selectedItem[index] ? price * totalWeight : price * quantity;
            // حفظ السعر الكلي في البروفايدر
            invoiceProvider.setPrice(groupKey, totalPrice);

            invoiceProvider.getTotalPriceNotifier(groupKey).value =
                totalPrice.toString();
            grandTotalPrice = invoiceProvider.calculateGrandTotalPrice();
          },
          decoration: const InputDecoration(
            prefixText: '\$',
            hintText: '0.00',
          ),
        ),
      )),
      DataCell(Center(
        child: ValueListenableBuilder(
          valueListenable: invoiceProvider.getTotalPriceNotifier(groupKey),
          builder: (context, value, child) {
            double totalPrice = double.parse(value.toString());

            return Text(
              '\$ ${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.redAccent),
            );
          },
        ),
      )),
    ],
    selected: selectedItem[index],
    onSelectChanged: onChanged,
  );
}
