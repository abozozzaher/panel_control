import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';

import '../../provider/trader_provider.dart';
import '../../service/trader_service.dart';

import 'widget/buildDropdownProInv.dart';
import 'widget/duesForProInv.dart';
import 'widget/finalTotalForProInv.dart';
import 'widget/firastRowLine.dart';
import 'widget/pdf_ProInv.dart';
import 'widget/shippingFeesForProInv.dart';
import 'widget/subTotalPriceForProInv.dart';
import 'widget/taxForProInv.dart';

class DataTabelFetcherForProInv extends StatefulWidget {
  final String? invoiceCode;

  const DataTabelFetcherForProInv(this.invoiceCode, {super.key});

  @override
  _DataTabelFetcherForProInvState createState() =>
      _DataTabelFetcherForProInvState();
}

class _DataTabelFetcherForProInvState extends State<DataTabelFetcherForProInv> {
  final DataLists dataLists = DataLists();
  final TraderService traderService = TraderService();

  String? selectedType;
  String? selectedColor;
  String? selectedYarnNumber;
  String? selectedLength;
  String? selectedWeight;
  String? selectedQuantity;

  List<List<String>>? types;
  List<List<String>>? widths;
  List<List<String>>? weights;
  List<List<String>>? colors;
  List<List<String>>? yarnNumbers;
  List<List<String>>? shift;
  List<List<String>>? quantity;
  List<List<String>>? length;

  TextEditingController priceController = TextEditingController();
  TextEditingController allQuantityController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController shippingController = TextEditingController();
  TextEditingController shippingCompanyNameController = TextEditingController();
  TextEditingController shippingTrackingNumberController =
      TextEditingController();
  TextEditingController packingBagsNumberController = TextEditingController();

  ValueNotifier<double> previousDebtsController = ValueNotifier<double>(0.0);

  int lineCounter = 1;
  double price = 0.0;
  String? allQuantity = '0';
  bool isManualWeightEntry = false;

  List<Map<String, dynamic>> tableData = [];

  double get totalPrices {
    return tableData.fold(0.0, (sum, row) => sum + (row['totalPrice'] ?? 0.0));
  }

  double get tax {
    return totalPrices *
        (1 + (double.tryParse(taxController.text) ?? 0.0) / 100);
  }

  double get shippingFees {
    return double.tryParse(shippingController.text) ?? 0.0;
  }

  double get finalTotal {
    return tax + shippingFees - previousDebtsController.value;
  }

  @override
  void initState() {
    super.initState();
    loadDefaultValues();
    priceController.text = '2.65'; // القيمة الافتراضية
  }

  Future<void> loadDefaultValues() async {
    types = dataLists.types;
    weights = dataLists.weights;
    colors = dataLists.colors;
    yarnNumbers = dataLists.yarnNumbers;
    quantity = dataLists.quantity;
    length = dataLists.length;
    setState(() {
      selectedType = types!.isNotEmpty ? types![0][0] : null;
      selectedWeight = weights!.isNotEmpty ? weights![0][0] : null;
      selectedColor = colors!.isNotEmpty ? colors![0][0] : null;
      selectedYarnNumber = yarnNumbers!.isNotEmpty ? yarnNumbers![1][0] : null;
      selectedLength = length!.isNotEmpty ? length![2][0] : null;
      selectedQuantity = quantity!.isNotEmpty ? quantity![2][0] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trader = Provider.of<TraderProvider>(context).trader;

    List<DataColumn> columns = dataLists.columnTitlesForProInv.map((title) {
      return DataColumn(
        label: Center(child: Text(title)),
      );
    }).toList();

    double totalLength = (double.tryParse(allQuantity ?? '0') ?? 0) *
        (double.tryParse(selectedLength ?? '0') ?? 0);

    double totalWight = isManualWeightEntry
        ? double.tryParse(allQuantity ?? '0') ?? 0
        : (double.tryParse(allQuantity ?? '0') ?? 0) *
            ((double.tryParse(selectedWeight ?? '0') ?? 0) / 1000);

    double totalUnit = (double.tryParse(allQuantity ?? '0') ?? 0) /
        (double.tryParse(selectedQuantity ?? '0') ?? 0);

    // حساب مجموع 'totalWeight' لكل صف في الجدول
    double totalWeightSum = tableData.fold(0.0, (sum, rowData) {
      return sum + (rowData['totalWeight'] ?? 0.0);
    });
    // حساب مجموع 'totalUnit' لكل صف في الجدول
    double totalUnitSum = tableData.fold(0.0, (sum, rowData) {
      return sum + (rowData['totalUnit'] ?? 0.0);
    });

    String totalPrice = (price * (double.tryParse(allQuantity.toString()) ?? 0))
        .toStringAsFixed(2);
    final totalPricesAndTaxAndShippingFee = tax + shippingFees;
    return trader == null
        ? Center(child: Text(S().no_trader_selected))
        : Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // عناصر الإدخال
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      buildDropdownProInv(
                        context,
                        setState,
                        hint: '${S().select} ${S().type}',
                        selectedValue: selectedType,
                        itemsList: dataLists.types,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                      buildDropdownProInv(
                        context,
                        setState,
                        hint: '${S().select} ${S().color}',
                        selectedValue: selectedColor,
                        itemsList: dataLists.colors,
                        onChanged: (value) {
                          setState(() {
                            selectedColor = value;
                          });
                        },
                      ),
                      buildDropdownProInv(
                        context,
                        setState,
                        hint: '${S().select} ${S().yarn_number}',
                        selectedValue: selectedYarnNumber,
                        itemsList: dataLists.yarnNumbers,
                        onChanged: (value) {
                          setState(() {
                            selectedYarnNumber = value;
                          });
                        },
                      ),
                      buildDropdownProInv(
                        context,
                        setState,
                        hint: '${S().select} ${S().length}',
                        selectedValue: selectedLength,
                        itemsList: dataLists.length,
                        onChanged: (value) {
                          setState(() {
                            selectedLength = value;
                          });
                        },
                      ),
                      buildDropdownProInv(
                        context,
                        setState,
                        hint: '${S().select} ${S().weight}',
                        selectedValue: selectedWeight,
                        itemsList: dataLists.weights,
                        onChanged: (value) {
                          setState(() {
                            selectedWeight = value;
                          });
                        },
                      ),
                      buildDropdownProInv(
                        context,
                        setState,
                        hint: '${S().select} ${S().quantity}',
                        selectedValue: selectedQuantity,
                        itemsList: dataLists.quantity,
                        onChanged: (value) {
                          setState(() {
                            selectedQuantity = value;
                          });
                        },
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isManualWeightEntry = !isManualWeightEntry;
                          });
                        },
                        child: Text(isManualWeightEntry
                            ? S().switch_to_quantity
                            : S().switch_to_weight),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: allQuantityController,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: isManualWeightEntry
                                  ? S().enter_weight
                                  : S().total_quantity,
                              hintTextDirection: TextDirection.ltr,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center),
                          onChanged: (value) {
                            setState(() {
                              allQuantity = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: priceController,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: S().price,
                              hintTextDirection: TextDirection.ltr,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center),
                          onChanged: (value) {
                            setState(() {
                              price = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            price =
                                double.tryParse(priceController.text) ?? 0.0;
                            tableData.add({
                              'type': selectedType,
                              'color': selectedColor,
                              'yarn_number': selectedYarnNumber,
                              'totalLength': totalLength,
                              'totalWeight': totalWight,
                              'totalUnit': totalUnit,
                              'allQuantity': allQuantity,
                              'price': price,
                              'totalPrice': price *
                                  (double.tryParse(allQuantity.toString()) ?? 0)
                            });
                            allQuantityController.clear();
                            priceController.text = '2.65';
                            selectedType =
                                types!.isNotEmpty ? types![0][0] : null;
                            selectedWeight =
                                weights!.isNotEmpty ? weights![0][0] : null;
                            selectedColor =
                                colors!.isNotEmpty ? colors![0][0] : null;
                            selectedYarnNumber = yarnNumbers!.isNotEmpty
                                ? yarnNumbers![1][0]
                                : null;
                            selectedLength =
                                length!.isNotEmpty ? length![2][0] : null;
                            selectedQuantity =
                                quantity!.isNotEmpty ? quantity![2][0] : null;
                          });
                        },
                        child: Text(S().add_to_table),
                      ),
                    ],
                  ),

                  DataTable(
                    columns: columns,
                    rows: [
                      firastRowLine(
                          totalLength,
                          totalWight,
                          totalUnit,
                          totalPrice,
                          selectedType,
                          selectedColor,
                          selectedYarnNumber,
                          allQuantity,
                          price),
                      ...tableData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final rowData = entry.value;
                        return DataRow(cells: [
                          DataCell(Center(
                              child: Text((index + 1).toString(),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      rowData['type'].toString()),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      rowData['color'].toString()),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      '${rowData['yarn_number'].toString()}D'),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      '${rowData['totalLength'].toStringAsFixed(0)} Mt'),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      '${rowData['totalWeight'].toStringAsFixed(2)} Kg'),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      '${rowData['totalUnit'].toStringAsFixed(0)} ${S().unit}'),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      '${rowData['allQuantity']} ${S().pcs}'),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      '\$${rowData['price'].toStringAsFixed(2)}'),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(Center(
                              child: Text(
                                  dataLists.translateType(
                                      '\$${rowData['totalPrice'].toStringAsFixed(2)}'),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1))),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                tableData.remove(rowData);
                              });
                            },
                          )),
                        ]);
                      }),

                      // إضافة صفوف الحسابات
                      subTotalPriceForProInv(totalPrices),

                      taxForProInv(tax, taxController),
                      shippingFeesForProInv(
                          totalPricesAndTaxAndShippingFee,
                          shippingController,
                          shippingCompanyNameController,
                          shippingTrackingNumberController,
                          packingBagsNumberController,
                          totalWeightSum,
                          totalUnitSum),

                      duesForProInv(trader, previousDebtsController),

                      finalTotalForProInv(finalTotal, () {
                        setState(() {});
                      }),
                    ],
                    headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.amberAccent),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await generatePdfProInv(
                          context,
                          tableData,
                          widget.invoiceCode,
                          totalPrices,
                          taxController.text,
                          tax,
                          shippingFees,
                          previousDebtsController.value,
                          finalTotal,
                          shippingCompanyNameController.text,
                          shippingTrackingNumberController.text,
                          packingBagsNumberController.text,
                          totalWeightSum,
                          totalUnitSum);
                      setState(() {
                        selectedType = null;
                        selectedColor = null;
                        selectedYarnNumber = null;
                        selectedLength = null;
                        selectedWeight = null;
                        selectedQuantity = null;
                        allQuantityController.clear();
                        priceController.clear();
                        taxController.clear();
                        shippingController.clear();
                        shippingCompanyNameController.clear();
                        shippingTrackingNumberController.clear();
                        packingBagsNumberController.clear();

                        tableData.clear();
                      });
                      context.go('/');
                    },
                    label: Text(S().add_proforma_invoice),
                    icon: const Icon(Icons.print_outlined),
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          );
  }
}
