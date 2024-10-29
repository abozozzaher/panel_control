import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../model/clien.dart';
import '../../../service/trader_service.dart';

DataRow duesForProInv(
    ClienData? trader, ValueNotifier<double> previousDebtsController) {
  return DataRow(
    cells: [
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      const DataCell(Center(child: Text(''))),
      DataCell(
        Center(
            child: Text(
          previousDebtsController.value == 0
              ? S().no_dues
              : previousDebtsController.value < -1
                  ? S().previous_debt
                  : S().customer_balance,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: previousDebtsController.value == 0
                  ? Colors.green
                  : previousDebtsController.value < 1
                      ? Colors.redAccent
                      : Colors.green),
        )),
      ),
      DataCell(
        Center(
          child: FutureBuilder<double>(
            future: TraderService().fetchLastDues(trader!.codeIdClien),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              } else if (snapshot.hasError) {
                return Text(S().error);
              } else {
                double lastDues = snapshot.data ?? 0.0;
                previousDebtsController.value = lastDues;

                return Text('\$${lastDues.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: lastDues == 0
                            ? Colors.green
                            : lastDues < 0
                                ? Colors.redAccent
                                : Colors.green,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    maxLines: 1);
              }
            },
          ),
        ),
      ),
      DataCell(
        Center(
          child: ValueListenableBuilder<double>(
            valueListenable: previousDebtsController,
            builder: (context, value, child) {
              return Text('\$ ${value != 0 ? (value).toStringAsFixed(2) : 0}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: value == 0
                          ? Colors.green
                          : value < -1
                              ? Colors.redAccent
                              : Colors.green),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  maxLines: 1);
            },
          ),
        ),
      ),
      const DataCell(Text('')),
    ],
  );
}
