import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../service/invoice_service.dart';
import '../../../service/trader_service.dart';

DataRow rowForPreviousDebts(
    double grandTotalPriceTaxs,
    TextEditingController previousDebtController,
    String Function(String text) convertArabicToEnglish,
    ValueNotifier<double> shippingFeesNotifier,
    ValueNotifier<double> previousDebtsNotifier,
    String codeIdClien,
    InvoiceService invoiceService) {
  final TraderService traderService = TraderService();

  return DataRow(
    cells: [
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      DataCell(
        Center(
            child: Text(
          previousDebtsNotifier.value == 0
              ? S().no_dues
              : previousDebtsNotifier.value < -1
                  ? S().previous_debt
                  : S().customer_balance,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: previousDebtsNotifier.value == 0
                  ? Colors.black
                  : previousDebtsNotifier.value < 1
                      ? Colors.redAccent
                      : Colors.green),
        )),
      ),
      DataCell(
        Center(
          child: FutureBuilder<double>(
            future: traderService.fetchLastDues(codeIdClien),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator
                    .adaptive(); // يمكن عرض مؤشر تحميل أثناء انتظار البيانات
              } else if (snapshot.hasError) {
                return const Text('Error'); // عرض رسالة خطأ في حالة وجود خطأ
              } else {
                double lastDues = snapshot.data ?? 0.0;
                previousDebtsNotifier.value = lastDues;

                return Text(
                  '\$${lastDues.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: lastDues == 0
                          ? Colors.black
                          : lastDues < 0
                              ? Colors.redAccent
                              : Colors.green,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                );
              }
            },
          ),
        ),
      ),

// عرض النتيجة
      DataCell(
        Center(
          child: ValueListenableBuilder<double>(
            valueListenable: previousDebtsNotifier,
            builder: (context, value, child) {
              return Text(
                '\$ ${value != 0 ? (value - shippingFeesNotifier.value - grandTotalPriceTaxs).toStringAsFixed(2) : 0}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: value == 0
                        ? Colors.black
                        : value < -1
                            ? Colors.redAccent
                            : Colors.green),
              );
            },
          ),
        ),
      ),
    ],
  );
}
