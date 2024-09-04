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
    _selectedItem,
    ValueChanged<bool?> onChanged) {
  return DataRow(
    cells: [
      DataCell(Center(
        child: Text(DataLists().translateType(itemData['type'].toString())),
      )),
      DataCell(Center(
        child: Text(DataLists().translateType(itemData['color'].toString())),
      )),
      DataCell(Center(
        child: Text(
            '${DataLists().translateType(itemData['yarn_number'].toString())} D'),
      )),
      DataCell(Center(
        child: Text(
            '${DataLists().translateType(itemData['length'].toString())} Mt'),
      )),
      DataCell(Center(
        child: Text('${itemData['total_weight']} Kg'),
      )),
      DataCell(Center(
        child: Text('${itemData['scanned_data']} ${S().unit}'),
      )),
      DataCell(Center(
        child: Text(
            '${DataLists().translateType(itemData['quantity'].toString())} ${S().pcs}'),
      )),
      DataCell(Center(
        child: TextField(
          controller: invoiceProvider.getPriceController(groupKey),
          style:
              TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: (text) {
            double price = double.tryParse(text) ?? 0.00;
            double quantity =
                double.tryParse(itemData['quantity'].toString()) ?? 0.00;
            double totalWeight =
                double.tryParse(itemData['total_weight'].toString()) ?? 0.00;

            double totalPrice =
                _selectedItem[index] ? price * totalWeight : price * quantity;
            // حفظ السعر الكلي في البروفايدر
            invoiceProvider.setPrice(groupKey, totalPrice);

            invoiceProvider.getTotalPriceNotifier(groupKey).value =
                totalPrice.toString();
            grandTotalPrice = invoiceProvider.calculateGrandTotalPrice();
          },
          decoration: InputDecoration(
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
              style: TextStyle(color: Colors.redAccent),
            );
          },
        ),
      )),
    ],
    selected: _selectedItem[index],
    onSelectChanged: onChanged,

    /*
    onSelectChanged: (bool? selectedItem) {
      setState(() {
        if (selectedItem != null) {
          _selectedItem[index] = selectedItem;
          // تحديث حالة التحديد في البروفيدر
          final key = aggregatedData.keys.toList()[index];
          invoiceProvider.updateSelectionState(key, selectedItem);
          invoiceProvider.getPriceController(key).clear();
          invoiceProvider.getTotalPriceNotifier(groupKey).value = '0.00';
        }
      });
    },
    */
  );
}
