import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../provider/invoice_provider.dart';
import '../../../provider/trader_provider.dart';
import '../../../service/invoice_service.dart';
import '../../../service/toasts.dart';
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
  TextEditingController shippingCompanyNameController,
  TextEditingController shippingTrackingNumberController,
  TextEditingController packingBagsNumberController,
  ValueNotifier<double> taxsNotifier,
  String? invoiceCode,
  double totalWeight,
  int totalQuantity,
  int totalLength,
  int totalScannedData,
) {
  //final trader = Provider.of<TraderProvider>(context).trader;
  final traderClean = Provider.of<TraderProvider>(context);

  return Directionality(
    textDirection: TextDirection.ltr,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          DataTable(
              columns: columns,
              rows: dataRows,
              headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.amberAccent)),
          const SizedBox(height: 20),
          // عمل شكل فاتورة

          ElevatedButton.icon(
            onPressed: () async {
              // عرض مربع حوار لتأكيد العملية
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(S().confirm_the_process),
                    content: Text(S()
                        .are_you_sure_you_want_to_record_the_data_and_view_the_pdf_file),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.redAccent),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text(
                                S().cancel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5, width: 5),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.greenAccent),
                              child: Text(S().confirm,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              onPressed: () async {
                                Navigator.of(context)
                                    .pop(true); // Close the dialog
                                showToast(S()
                                    .the_invoice_will_be_recorded_in_the_database);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );

              // إذا تم تأكيد العملية
              if (confirmed == true) {
                try {
                  final aggregatedData = await invoiceService.fetchData();

                  // قائمة لجمع جميع الأسعار
                  final prices = aggregatedData.keys.map((groupKey) {
                    return double.tryParse(invoiceProvider
                            .getPriceController(groupKey)
                            .text) ??
                        0.00;
                  }).toList();

                  // جلب جميع الأسعار من البروفايدر
                  final totalLinePrices = aggregatedData.keys.map((groupKey) {
                    return invoiceProvider.getPrice(groupKey);
                  }).toList();
                  final taxs = taxsNotifier.value;
                  final previousDebts = previousDebtsNotifier.value;
                  final shippingFees = shippingFeesNotifier.value;
                  final shippingCompanyName =
                      shippingCompanyNameController.text;
                  final shippingTrackingNumber =
                      shippingTrackingNumberController.text;
                  final packingBagsNumber = packingBagsNumberController.text;

                  final total =
                      (grandTotalPriceTaxs + shippingFees) - previousDebts;

                  // إنشاء وعرض ملف الـ PDF
                  await generatePdf(
                    context,
                    aggregatedData,
                    grandTotalPrice,
                    previousDebts,
                    shippingFees,
                    prices,
                    totalLinePrices,
                    total,
                    taxs,
                    invoiceCode!,
                    invoiceService,
                    grandTotalPriceTaxs,
                    shippingCompanyName,
                    shippingTrackingNumber,
                    packingBagsNumber,
                    totalWeight,
                    totalQuantity,
                    totalLength,
                    totalScannedData,
                  );

                  context.go('/');
                  // تفريغ الجدول من البيانات
                  invoiceProvider.clear(); // تفريغ الـ
                  traderClean.clearTrader();

                  // إعادة بناء الواجهة لتحديث الجدول
                } catch (e) {
                  // التعامل مع الأخطاء

                  showToast('${S().error} : $e');
                }
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(S().view_invoice),
          ),
        ],
      ),
    ),
  );
}
