import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

DataRow shippingFeesForProInv(
  double totalPricesAndTaxAndShippingFee,
  TextEditingController shippingController,
  TextEditingController shippingCompanyNameController,
  TextEditingController shippingTrackingNumberController,
  TextEditingController packingBagsNumberController,
  double totalWeightSum,
  double totalUnitSum,
) {
  return DataRow(cells: [
    const DataCell(Text('')),
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
            labelText:
                S().shipping_company_name, // النص الظاهر فوق الحقل عند التفاعل
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
    DataCell(Text(
      '${totalWeightSum.toStringAsFixed(0)} Kg',
      textDirection: TextDirection.ltr,
    )),
    DataCell(Text(
      '${totalUnitSum.toStringAsFixed(0)} ${S().unit}',
      textDirection: TextDirection.ltr,
    )),
    DataCell(Center(child: Text(S().shipping_fees))),
    DataCell(Center(
      child: SizedBox(
        width: 100,
        child: TextField(
          controller: shippingController,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S().shipping_fees, // النص الظاهر فوق الحقل عند التفاعل
            hintText: S().enter_shipping_fees, // النص التوضيحي داخل الحقل
          ),
          onChanged: (value) {
            //   setState(() {});
          },
        ),
      ),
    )),
    DataCell(Center(
        child: Text('\$${totalPricesAndTaxAndShippingFee.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 1))),
    const DataCell(Text('')),
  ]);
}
