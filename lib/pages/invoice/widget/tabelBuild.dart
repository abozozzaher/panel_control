import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../provider/invoice_provider.dart';
import '../../../provider/trader_provider.dart';
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
  final trader = Provider.of<TraderProvider>(context).trader;
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
              // عرض مربع حوار لتأكيد العملية
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(S().confirm_the_process),
                    content: Text(S()
                        .are_you_sure_you_want_to_record_the_data_and_view_the_pdf_file),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(S().cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(S().confirm),
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
                  final total = grandTotalPriceTaxs +
                      previousDebtsNotifier.value +
                      shippingFeesNotifier.value;
                  final taxs = taxsNotifier.value;
                  final previousDebts = previousDebtsNotifier.value;
                  final shippingFees = shippingFeesNotifier.value;

                  // تسجيل البيانات في Firebase
                  await invoiceService.saveData(
                      aggregatedData,
                      total,
                      trader,
                      grandTotalPrice,
                      grandTotalPriceTaxs,
                      taxs,
                      previousDebts,
                      shippingFees);

                  // إنشاء وعرض ملف الـ PDF
                  await generatePdf(
                      context,
                      aggregatedData,
                      grandTotalPrice,
                      previousDebtsNotifier.value,
                      shippingFeesNotifier.value,
                      prices,
                      totalLinePrices,
                      total,
                      taxsNotifier.value);
                  context.go('/');
                  // تفريغ الجدول من البيانات
                  invoiceProvider.clear(); // تفريغ الـ
                  traderClean.clearTrader();

                  print('aaaaa ${invoiceProvider}');

                  // إعادة بناء الواجهة لتحديث الجدول
                } catch (e) {
                  // التعامل مع الأخطاء
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Center(child: Text('${S().error} : $e'))),
                  );
                }
              }
            },
            icon: Icon(Icons.picture_as_pdf),
            label: Text(S().view_invoice),
          ),
        ],
      ),
    ),
  );
}
