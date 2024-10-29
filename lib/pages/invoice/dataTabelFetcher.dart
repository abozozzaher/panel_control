import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/trader_provider.dart';
import '../../service/invoice_service.dart';
import 'widget/itemForTabel.dart';
import 'widget/rowForAllTotals.dart';
import 'widget/rowForPreviousDebts.dart';
import 'widget/rowForShippingFees.dart';
import 'widget/rowForTotals.dart';
import 'widget/rowTax.dart';
import 'widget/tabelBuild.dart';

class DataTabelFetcher extends StatefulWidget {
  final String? invoiceCode; // Define a class variable to store the invoiceCode

  const DataTabelFetcher(this.invoiceCode,
      {super.key}); // Store the invoiceCode in the class variable

  @override
  _DataTabelFetcherState createState() => _DataTabelFetcherState();
}

class _DataTabelFetcherState extends State<DataTabelFetcher> {
  final DataLists dataLists = DataLists();
  double grandTotalPrice = 0.0; // تعريف المتغير هنا

  List<bool> _selectedItem = [];

  TextEditingController taxController = TextEditingController();
  TextEditingController previousDebtController = TextEditingController();
  TextEditingController shippingFeeController = TextEditingController();
  TextEditingController shippingCompanyNameController = TextEditingController();
  TextEditingController shippingTrackingNumberController =
      TextEditingController();
  TextEditingController packingBagsNumberController = TextEditingController();

  final ValueNotifier<double> taxsNotifier =
      ValueNotifier<double>(0.0); // الضريبة
  final ValueNotifier<double> previousDebtsNotifier =
      ValueNotifier<double>(0.0); // المجموع السعر مع الدين
  final ValueNotifier<double> shippingFeesNotifier = ValueNotifier<double>(0.0);

  /// تحويل الأرقام العربية إلى أرقام إنجليزية
  String convertArabicToEnglish(String text) {
    return text.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trader = Provider.of<TraderProvider>(context).trader;

    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final InvoiceService invoiceService =
        InvoiceService(context, invoiceProvider);
    grandTotalPrice = invoiceProvider.calculateGrandTotalPrice();

    List<DataColumn> columns = dataLists.columnTitles.map((title) {
      return DataColumn(
        label: Text(title),
      );
    }).toList();
    return trader == null
        ? Center(child: Text(S().no_trader_selected))
        : Center(
            child: FutureBuilder<Map<String, Map<String, dynamic>>>(
              future: invoiceService.fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else if (snapshot.hasError) {
                  return Center(child: Text('${S().error}: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final aggregatedData = snapshot.data;

                  // Initialize totals
                  double totalWeight = 0.0;
                  int totalQuantity = 0;
                  int totalLength = 0;
                  int totalScannedData = 0;

                  List<DataRow> dataRows = aggregatedData!.entries.map((entry) {
                    final itemData = entry.value;
                    final groupKey = entry.key;
                    final index = aggregatedData.keys
                        .toList()
                        .indexOf(groupKey); // احصل على الفهرس هنا
                    // تحديث حالة التحديد بناءً على البروفيدر
                    _selectedItem = aggregatedData.keys.map((key) {
                      return invoiceProvider.getSelectionState(key) ?? false;
                    }).toList();

                    // Accumulate totals
                    totalWeight += itemData['total_weight'] as double;
                    totalQuantity += itemData['quantity'] as int;
                    totalLength +=
                        itemData['length'] * itemData['quantity'] as int;
                    totalScannedData += itemData['scanned_data'] as int;

                    return itemForTabel(
                      itemData,
                      invoiceProvider,
                      groupKey,
                      index,
                      aggregatedData,
                      grandTotalPrice,
                      _selectedItem,
                      (bool? selectedItem) {
                        setState(() {
                          if (selectedItem != null) {
                            _selectedItem[index] = selectedItem;
                            // تحديث حالة التحديد في البروفيدر
                            final key = aggregatedData.keys.toList()[index];
                            invoiceProvider.updateSelectionState(
                                key, selectedItem);
                            invoiceProvider.getPriceController(key).clear();
                            invoiceProvider
                                .getTotalPriceNotifier(groupKey)
                                .value = '0.00';
                          }
                        });
                      },
                    );
                  }).toList();
                  // Add a row for totals المجموع الاول
                  dataRows.add(rowForTotals(totalLength, totalWeight,
                      totalScannedData, totalQuantity, grandTotalPrice));

                  // Add a row for totals Tax الضريبة
                  dataRows.add(rowTax(
                      taxController, convertArabicToEnglish, taxsNotifier));
                  final taxValue = 1 + taxsNotifier.value;

                  // حساب السعر مع الضريبة
                  final grandTotalPriceTaxs = grandTotalPrice * taxValue;

                  // Add a row for shippingFees اجور الشحن
                  dataRows.add(
                    rowForShippingFees(
                        grandTotalPriceTaxs,
                        shippingFeeController,
                        convertArabicToEnglish,
                        shippingFeesNotifier,
                        shippingCompanyNameController,
                        shippingTrackingNumberController,
                        packingBagsNumberController),
                  );
// Add a row for previousDebts الدين السابق
                  dataRows.add(rowForPreviousDebts(
                      grandTotalPriceTaxs,
                      previousDebtController,
                      convertArabicToEnglish,
                      shippingFeesNotifier,
                      previousDebtsNotifier,
                      trader.codeIdClien,
                      invoiceService));
                  final totalAllMoney = grandTotalPriceTaxs +
                      shippingFeesNotifier.value -
                      previousDebtsNotifier.value;

                  // Add a row for all totals قيمة الفاتورة
                  dataRows.add(rowForAllTotals(totalAllMoney, () {
                    setState(() {});
                  }));

                  return tableBuilld(
                      columns,
                      dataRows,
                      invoiceService,
                      invoiceProvider,
                      grandTotalPriceTaxs,
                      context,
                      grandTotalPrice,
                      previousDebtsNotifier,
                      shippingFeesNotifier,
                      shippingCompanyNameController,
                      shippingTrackingNumberController,
                      packingBagsNumberController,
                      taxsNotifier,
                      widget.invoiceCode,
                      totalWeight,
                      totalQuantity,
                      totalLength,
                      totalScannedData);
                } else {
                  return Center(
                      child:
                          Text(S().no_data_found, textAlign: TextAlign.center));
                }
              },
            ),
          );
  }

  @override
  void dispose() {
    taxController.dispose();
    previousDebtController.dispose();
    shippingFeeController.dispose();
    shippingCompanyNameController.dispose();
    shippingTrackingNumberController.dispose();
    packingBagsNumberController.dispose();
    super.dispose();
  }
}
