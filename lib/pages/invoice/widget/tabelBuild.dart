import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../provider/invoice_provider.dart';
import '../../../service/invoice_service.dart';
import '../pdf_Inv.dart';

Directionality tableBuilld(
    List<DataColumn> columns,
    List<DataRow> dataRows,
    InvoiceService invoiceService,
    InvoiceProvider invoiceProvider,
    double grandTotalPriceTaxs,
    BuildContext context,
    double grandTotalPrice,
    ValueNotifier<double> previousDebtsNotifier,
    ValueNotifier<double> shippingFeesNotifier,
    ValueNotifier<double> taxsNotifier) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          DataTable(
            columns: columns,
            rows: dataRows,
            headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent,
                decorationThickness: 100),
            headingRowColor:
                WidgetStateProperty.resolveWith((states) => Colors.black),
            dataTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decorationThickness: 100),
          ),
          SizedBox(height: 20),
          // عمل شكل فاتورة

          ElevatedButton.icon(
            onPressed: () async {
              final aggregatedData = await invoiceService.fetchData();

              // قائمة لجمع جميع الأسعار
              final prices = aggregatedData.keys.map((groupKey) {
                return double.tryParse(
                        invoiceProvider.getPriceController(groupKey).text) ??
                    0.00;
              }).toList();

              // جلب جميع الأسعار من البروفايدر
              final allPrices = aggregatedData.keys.map((groupKey) {
                return invoiceProvider.getPrice(groupKey);
              }).toList();
              final total = grandTotalPriceTaxs +
                  previousDebtsNotifier.value +
                  shippingFeesNotifier.value;

              await generatePdf(
                  context,
                  aggregatedData,
                  grandTotalPrice,
                  previousDebtsNotifier.value,
                  shippingFeesNotifier.value,
                  prices,
                  allPrices,
                  total,
                  taxsNotifier.value);
            },
            icon: Icon(Icons.picture_as_pdf),
            label: Text(S().view_invoice),
          ),
        ],
      ),
    ),
  );
}
