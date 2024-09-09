import 'package:flutter/material.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import 'widget/buildDropdownProInv.dart';

class DataTabelFetcherForProInv extends StatefulWidget {
  final String? invoiceCode;

  DataTabelFetcherForProInv(this.invoiceCode);

  @override
  _DataTabelFetcherForProInvState createState() =>
      _DataTabelFetcherForProInvState();
}

class _DataTabelFetcherForProInvState extends State<DataTabelFetcherForProInv> {
  final DataLists dataLists = DataLists();
  String? selectedType;
  String? selectedColor;
  String? selectedYarnNumber;
  String? selectedLength;
  String? selectedWeight;
  String? selectedQuantity;

  TextEditingController priceController = TextEditingController();
  TextEditingController allQuantityController = TextEditingController();

  double price = 0.0;
  String? allQuantity = '0';

  // قائمة لتخزين الصفوف المؤكدة
  List<DataRow> confirmedRows = [];

  // سطر البيانات المؤقت
  DataRow? temporaryRow;

  DataRow createTemporaryRow() {
    double totalLength = (double.tryParse(allQuantity ?? '0') ?? 0) *
        (double.tryParse(selectedLength ?? '0') ?? 0);

    double totalWight = (double.tryParse(allQuantity ?? '0') ?? 0) *
        ((double.tryParse(selectedWeight ?? '0') ?? 0) / 1000);

    double totalUnit = (double.tryParse(allQuantity ?? '0') ?? 0) /
        (double.tryParse(selectedQuantity ?? '0') ?? 0);

    String totalPrice = (price * (double.tryParse(allQuantity.toString()) ?? 0))
        .toStringAsFixed(2);

    return DataRow(cells: [
      DataCell(Center(child: Text(selectedType ?? ""))),
      DataCell(Center(child: Text(selectedColor ?? ""))),
      DataCell(Center(child: Text(selectedYarnNumber ?? ""))),
      DataCell(Center(child: Text('${totalLength.toString()} Mt'))),
      DataCell(Center(child: Text('${totalWight.toStringAsFixed(2)} Kg'))),
      DataCell(
          Center(child: Text('${totalUnit.toStringAsFixed(0)} ${S().unit}'))),
      DataCell(Center(child: Text('$allQuantity ${S().pcs}'))),
      DataCell(Center(child: Text('\$${price.toStringAsFixed(2)}'))),
      DataCell(Center(child: Text('\$$totalPrice'))),
      // زر التعديل
      DataCell(IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            if (temporaryRow != null) {
              selectedType = temporaryRow!.cells[0].child is Text
                  ? (temporaryRow!.cells[0].child as Text).data
                  : null;
              selectedColor = temporaryRow!.cells[1].child is Text
                  ? (temporaryRow!.cells[1].child as Text).data
                  : null;
              selectedYarnNumber = temporaryRow!.cells[2].child is Text
                  ? (temporaryRow!.cells[2].child as Text).data
                  : null;
              selectedLength = (temporaryRow!.cells[3].child as Text)
                  .data
                  ?.replaceAll(' Mt', '');
              selectedWeight = (temporaryRow!.cells[4].child as Text)
                  .data
                  ?.replaceAll(' Kg', '');
              selectedQuantity =
                  (temporaryRow!.cells[5].child as Text).data?.split(' ')[0];
              priceController.text = (temporaryRow!.cells[7].child as Text)
                      .data
                      ?.replaceAll('\$', '') ??
                  '';
              allQuantityController.text =
                  (temporaryRow!.cells[6].child as Text).data?.split(' ')[0] ??
                      '';
              temporaryRow = null; // حذف السطر المؤقت عند التعديل
            }
          });
        },
      )),
      // زر الحذف
      DataCell(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          setState(() {
            if (temporaryRow != null) {
              confirmedRows.remove(temporaryRow);
              temporaryRow = null;
            } else {
              confirmedRows.removeWhere((row) {
                return row.cells[0].child is Text &&
                    (row.cells[0].child as Text).data == selectedType &&
                    row.cells[1].child is Text &&
                    (row.cells[1].child as Text).data == selectedColor &&
                    row.cells[2].child is Text &&
                    (row.cells[2].child as Text).data == selectedYarnNumber &&
                    (row.cells[3].child as Text).data?.replaceAll(' Mt', '') ==
                        selectedLength &&
                    (row.cells[4].child as Text).data?.replaceAll(' Kg', '') ==
                        selectedWeight &&
                    (row.cells[5].child as Text).data?.split(' ')[0] ==
                        selectedQuantity &&
                    (row.cells[6].child as Text).data?.split(' ')[0] ==
                        allQuantity;
              });
            }
          });
        },
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<DataColumn> columns = dataLists.columnTitlesForProInv.map((title) {
      return DataColumn(
        label: Center(child: Text(title)),
      );
    }).toList();

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                Container(
                  width: 100,
                  child: TextField(
                    controller: allQuantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: S().total_quantity),
                    onChanged: (value) {
                      setState(() {
                        allQuantity = value;
                      });
                    },
                  ),
                ),
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // إنشاء السطر المؤقت بناءً على القيم المدخلة
                      temporaryRow = createTemporaryRow();
                    });
                  },
                  child: Text(S().add_to_table),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (temporaryRow != null) {
                        confirmedRows.add(temporaryRow!);
                        temporaryRow = null;

                        // تفريغ الحقول لإدخال سطر جديد
                        selectedType = null;
                        selectedColor = null;
                        selectedYarnNumber = null;
                        selectedLength = null;
                        selectedWeight = null;
                        selectedQuantity = null;
                        priceController.clear();
                        allQuantityController.clear();
                        price = 0.0;
                        allQuantity = '0';
                      }
                    });
                  },
                  child: Text(S().confirm),
                ),
              ],
            ),
            DataTable(
                columns: columns,
                rows: [
                  // عرض السطر المؤقت إن وجد
                  if (temporaryRow != null) temporaryRow!,
                  // عرض الصفوف المؤكدة
                  ...confirmedRows,
                ],
                headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.amberAccent)),
          ],
        ),
      ),
    );
  }
}
