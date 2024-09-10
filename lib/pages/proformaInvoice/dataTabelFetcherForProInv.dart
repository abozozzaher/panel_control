import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';

import '../../provider/trader_provider.dart';
import '../../service/trader_service.dart';

import 'widget/buildDropdownProInv.dart';
import 'widget/firastRowLine.dart';
import 'widget/pdf_ProInv.dart';

class DataTabelFetcherForProInv extends StatefulWidget {
  final String? invoiceCode;

  DataTabelFetcherForProInv(this.invoiceCode);

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
  ValueNotifier<double> previousDebtsController = ValueNotifier<double>(0.0);

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
      selectedQuantity = quantity!.isNotEmpty ? quantity![1][0] : null;
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

    String totalPrice = (price * (double.tryParse(allQuantity.toString()) ?? 0))
        .toStringAsFixed(2);
    final totalPricesAndTaxAndShippingFee = tax + shippingFees;
    return Center(
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
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: TextField(
                    controller: allQuantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isManualWeightEntry
                          ? S().enter_weight
                          : S().total_quantity,
                    ),
                    onChanged: (value) {
                      setState(() {
                        allQuantity = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: TextField(
                    controller: priceController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: S().price),
                    onChanged: (value) {
                      setState(() {
                        price = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tableData.add({
                        'type': selectedType,
                        'color': selectedColor,
                        'yarnNumber': selectedYarnNumber,
                        'totalLength': totalLength,
                        'totalWeight': totalWight,
                        'totalUnit': totalUnit,
                        'allQuantity': allQuantity,
                        'price': price,
                        'totalPrice': price *
                            (double.tryParse(allQuantity.toString()) ?? 0),
                      });

                      selectedType = null;
                      selectedColor = null;
                      selectedYarnNumber = null;
                      selectedLength = null;
                      selectedWeight = null;
                      selectedQuantity = null;
                      allQuantityController.clear();
                      priceController.clear();
                    });
                    setState(() {
                      selectedType = types!.isNotEmpty ? types![0][0] : null;
                      selectedWeight =
                          weights!.isNotEmpty ? weights![0][0] : null;
                      selectedColor = colors!.isNotEmpty ? colors![0][0] : null;
                      selectedYarnNumber =
                          yarnNumbers!.isNotEmpty ? yarnNumbers![1][0] : null;
                      selectedLength =
                          length!.isNotEmpty ? length![2][0] : null;
                      selectedQuantity =
                          quantity!.isNotEmpty ? quantity![1][0] : null;
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
                ...tableData.map((rowData) {
                  return DataRow(cells: [
                    DataCell(Center(
                        child: Text(rowData['type'] ?? "",
                            textAlign: TextAlign.center, maxLines: 1))),
                    DataCell(Center(
                        child: Text(rowData['color'] ?? "",
                            textAlign: TextAlign.center, maxLines: 1))),
                    DataCell(Center(
                        child: Text(rowData['yarnNumber'] ?? "",
                            textAlign: TextAlign.center, maxLines: 1))),
                    DataCell(Center(
                        child: Text(
                            '${rowData['totalLength'].toStringAsFixed(0)} Mt',
                            textAlign: TextAlign.center,
                            maxLines: 1))),
                    DataCell(Center(
                        child: Text(
                            '${rowData['totalWeight'].toStringAsFixed(2)} Kg',
                            textAlign: TextAlign.center,
                            maxLines: 1))),
                    DataCell(Center(
                        child: Text(
                            '${rowData['totalUnit'].toStringAsFixed(0)} ${S().unit}',
                            textAlign: TextAlign.center,
                            maxLines: 1))),
                    DataCell(Center(
                        child: Text('${rowData['allQuantity']} ${S().pcs}',
                            textAlign: TextAlign.center, maxLines: 1))),
                    DataCell(Center(
                        child: Text('\$${rowData['price'].toStringAsFixed(2)}',
                            textAlign: TextAlign.center, maxLines: 1))),
                    DataCell(Center(
                        child: Text(
                            '\$${rowData['totalPrice'].toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            maxLines: 1))),
                    DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          tableData.remove(rowData);
                        });
                      },
                    )),
                  ]);
                }).toList(),
                // إضافة صفوف الحسابات
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Center(child: Text(S().total_price))),
                  DataCell(Text('')),
                  DataCell(Center(child: Text('\$${totalPrices.toString()}'))),
                  DataCell(Text('')),
                ]),

                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Center(child: Text('${S().tax} (%)'))),
                  DataCell(Center(
                    child: Container(
                      width: 50,
                      child: TextField(
                        controller: taxController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  )),
                  DataCell(Center(child: Text('\$${tax.toStringAsFixed(2)}'))),
                  DataCell(Text('')),
                ]),
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Center(child: Text(S().shipping_fees))),
                  DataCell(Center(
                    child: Container(
                      width: 100,
                      child: TextField(
                        controller: shippingController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  )),
                  DataCell(Center(
                      child: Text(
                          '\$${totalPricesAndTaxAndShippingFee.toStringAsFixed(2)}'))),
                  DataCell(Text('')),
                ]),

                DataRow(
                  cells: [
                    DataCell(Center(child: Text(''))),
                    DataCell(Center(child: Text(''))),
                    DataCell(Center(child: Text(''))),
                    DataCell(Center(child: Text(''))),
                    DataCell(Center(child: Text(''))),
                    DataCell(Center(child: Text(''))),
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
                                ? Colors.black
                                : previousDebtsController.value < 1
                                    ? Colors.redAccent
                                    : Colors.green),
                      )),
                    ),
                    DataCell(
                      Center(
                        child: FutureBuilder<double>(
                          future:
                              traderService.fetchLastDues(trader!.codeIdClien),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator.adaptive();
                            } else if (snapshot.hasError) {
                              return Text(S().error);
                            } else {
                              double lastDues = snapshot.data ?? 0.0;
                              previousDebtsController.value = lastDues;

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
                    DataCell(
                      Center(
                        child: ValueListenableBuilder<double>(
                          valueListenable: previousDebtsController,
                          builder: (context, value, child) {
                            return Text(
                              '\$ ${value != 0 ? (value).toStringAsFixed(2) : 0}',
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
                    DataCell(Text('')),
                  ],
                ),

                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Center(
                      child: Text(S().final_total,
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)))),
                  DataCell(Text('')),
                  DataCell(Center(
                      child: Text('\$${finalTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)))),
                  DataCell(Text('')),
                ]),
              ],
              headingRowColor: MaterialStateProperty.resolveWith(
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
                    finalTotal);
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
                  tableData.clear();
                });
                context.go('/');
              },
              label: Text(S().add_proforma_invoice),
              icon: Icon(Icons.print_outlined),
            )
          ],
        ),
      ),
    );
  }
}
