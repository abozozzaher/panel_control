import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';

class InvoicePage extends StatefulWidget {
  final String? codeIdClien;
  final String? invoiceCode;

  InvoicePage({required this.codeIdClien, required this.invoiceCode});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    String linkUrl =
        "https://panel-control-company-zaher.web.app/${widget.codeIdClien}/invoices/${widget.invoiceCode}";
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    List<DataColumn> columns = DataLists().tableHeaders.map((title) {
      return DataColumn(
        label: Text(title),
      );
    }).toList();
    int index = 0;
    // تحقق من صحة معرف الفاتورة
    if (widget.invoiceCode == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S().invalid_invoice)),
        body: Center(child: Text(S().no_invoice_id_provided)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${S().invoice} ${S().details}'),
        leading: IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            Share.share('${S().check_out_my_invoice} $linkUrl',
                subject: S().look_what_i_have);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('cliens')
            .doc(widget.codeIdClien)
            .collection('invoices')
            .doc(widget.invoiceCode)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(child: Text(S().failed_to_load_invoice_details));
          }

          // استرجاع البيانات من المستند
          var data = snapshot.data!.data() as Map<String, dynamic>;

// Extract each inner map
          var traderMap = data["trader"] as Map<String, dynamic>;
          var aggregatedDataMap =
              data["aggregatedData"] as Map<String, dynamic>;

          return Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.symmetric(horizontal: 50),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //كلمة الفاتورة والتاريخ ورقم الفاتورة
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              height: 50,
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              // alignment: Alignment.centerLeft,
                              child: Text(
                                S().invoice,
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                  color: Colors.blueGrey),
                              padding: EdgeInsets.only(
                                  left: 40, top: 10, bottom: 10, right: 40),
                              alignment: Alignment.center,
                              height: 50,
                              child: DefaultTextStyle(
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(S().data),
                                        Text(_formatDate(
                                            DateTime.parse(data['createdAt'])))
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(S().invoice),
                                        Text(data['invoiceCode']),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // اللوغة
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // إضافةنص و خط فاصل
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide())),
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 4),
                              child: Text(
                                S().blue_textiles,
                                style:
                                    TextStyle(fontSize: 20, color: Colors.teal),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // اللوغو
                                Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(
                                        bottom: 8, left: 30),
                                    height: 100,
                                    child: Image(
                                        image:
                                            AssetImage('assets/img/logo.png'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // قيمة الفاتورة في الراس
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 40,
                          child: FittedBox(
                            child: Text(
                              ' ${S().final_total} : ${_formatCurrency(data['finalTotal'])}',
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ),
                      // معلومات المرسل اليه
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 10, right: 10),
                              height: 70,
                              child: Text(
                                '${S().invoice_to} :',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 70,
                                child: RichText(
                                    text: TextSpan(
                                        text: isRTL
                                            ? traderMap['fullNameArabic']
                                            : traderMap['fullNameEnglish'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 12),
                                        children: [
                                      const TextSpan(
                                        text: '\n',
                                        style: TextStyle(fontSize: 5),
                                      ),
                                      TextSpan(
                                        text:
                                            '${traderMap['country']}, ${traderMap['state']}, ${traderMap['city']},',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 10),
                                      ),
                                      const TextSpan(
                                        text: '\n',
                                        style: TextStyle(fontSize: 5),
                                      ),
                                      TextSpan(
                                        text: isRTL
                                            ? traderMap['addressArabic']
                                            : traderMap['addressEnglish'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 10),
                                      ),
                                    ])),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.amberAccent),
                      headingTextStyle: const TextStyle(
                          color:
                              Colors.black, // Change the text color to yellow
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      columns: columns,
                      rows: [
                        ...aggregatedDataMap.entries.map((entry) {
                          final rowData = entry.value;
                          return DataRow(cells: [
                            DataCell(Center(
                                child: Text((++index).toString(),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        rowData['type'].toString()),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        rowData['color'].toString()),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        '${rowData['yarn_number'].toString()}D'),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        '${rowData['length']} Mt'),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        '${rowData['total_weight'].toStringAsFixed(2)} Kg'),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        '${rowData['scanned_data']} ${S().unit}'),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        '${rowData['quantity']} ${S().pcs}'),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(
                                        _formatCurrency(rowData['price'])),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                            DataCell(Center(
                                child: Text(
                                    DataLists().translateType(_formatCurrency(
                                        rowData['totalLinePrices'])),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1))),
                          ]);
                        }).toList(),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 50),
                      // رسالة الشكر في نهاية الفاتورة
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S().thank_you_for_your_business,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20, bottom: 8),
                              child: Text(
                                '${S().payment_info} :',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '4509 Wiseman Street\nKnoxville, Tennessee(TN), 37929\n865-372-0425',
                              style: TextStyle(fontSize: 8, wordSpacing: 5),
                            ),
                          ],
                        ),
                      ),
                      // اجمالي الفاتورة
                      Expanded(
                        flex: 1,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 10,
                            // color: Colors.red,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${S().sub_total} :'),
                                  Text(
                                      _formatCurrency(data['grandTotalPrice'])),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${S().tax} :'),
                                  Text(
                                      '${(data['taxs'] * 100).toStringAsFixed(1)}%'),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${S().shipping_fees}:'),
                                  Text(_formatCurrency(data['shippingFees'])),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(data['previousDebts'] == 0
                                      ? '${S().no_dues} :'
                                      : data['previousDebts'] > -1
                                          ? '${S().previous_debt} :'
                                          : '${S().customer_balance} :'),
                                  Text(_formatCurrency(data['previousDebts'])),
                                ],
                              ),
                              Divider(color: Colors.blueGrey),
                              DefaultTextStyle(
                                style: TextStyle(
                                  color: Colors.teal,
                                  // fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().final_total} :'),
                                    Text(_formatCurrency(data['finalTotal'])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                  SizedBox(height: 50),
                  ElevatedButton.icon(
                    onPressed: () {
                      data['downloadUrlPdf'];
                    },
                    label: Text('Download a copy of the invoice in PDF'),
                    icon: Icon(Icons.print),
                  ),
                  SizedBox(height: 50)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
