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
              // عرض مربع حوار لتأكيد العملية
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('تأكيد العملية'),
                    content: Text(
                        'هل أنت متأكد من تسجيل البيانات وعرض ملف الـ PDF؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('تأكيد'),
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
                  final allPrices = aggregatedData.keys.map((groupKey) {
                    return invoiceProvider.getPrice(groupKey);
                  }).toList();
                  final total = grandTotalPriceTaxs +
                      previousDebtsNotifier.value +
                      shippingFeesNotifier.value;

                  // تسجيل البيانات في Firebase
                  await invoiceService.saveData(aggregatedData, total);

                  // إنشاء وعرض ملف الـ PDF
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
                } catch (e) {
                  // التعامل مع الأخطاء
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ: $e')),
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
