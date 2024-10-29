import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow rowForShippingFees(
    double grandTotalPriceTaxs,
    TextEditingController shippingFeeController,
    String Function(String text) convertArabicToEnglish,
    ValueNotifier<double> shippingFeesNotifier,
    TextEditingController shippingCompanyNameController,
    TextEditingController shippingTrackingNumberController,
    TextEditingController packingBagsNumberController) {
  return DataRow(
    cells: [
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      DataCell(Text(S().shipping_information)),
      DataCell(Center(
        child: SizedBox(
          width: 100,
          child: TextField(
            controller: shippingCompanyNameController,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S()
                  .shipping_company_name, // النص الظاهر فوق الحقل عند التفاعل
              hintText:
                  S().enter_shipping_company_name, // النص التوضيحي داخل الحقل
            ),
            onChanged: (value) {
              //   setState(() {});
            },
          ),
        ),
      )),
      DataCell(Center(
        child: SizedBox(
          width: 100,
          child: TextField(
            controller: shippingTrackingNumberController,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S().shipping_tracking_number,
              // النص الظاهر فوق الحقل عند التفاعل
              hintText: S().enter_shipping_tracking_number,
              // النص التوضيحي داخل الحقل
            ),
            onChanged: (value) {
              //   setState(() {});
            },
          ),
        ),
      )),
      DataCell(Center(
        child: SizedBox(
          width: 100,
          child: TextField(
            controller: packingBagsNumberController,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S().packing_bags_number,
              // النص الظاهر فوق الحقل عند التفاعل
              hintText: S().enter_packing_bags_number,
              // النص التوضيحي داخل الحقل
            ),
            onChanged: (value) {
              //   setState(() {});
            },
          ),
        ),
      )),

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
            textDirection: TextDirection.ltr,
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
              hintText: S().enter_shipping_fees,
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
                '\$ ${value != 0 ? (value + grandTotalPriceTaxs).toStringAsFixed(2) : 0}',
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
