import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من إضافة هذه الحزمة في pubspec.yaml

import '../../model/clien.dart';

class ClienPage extends StatelessWidget {
  final ClienData client;
  final List<Map<String, dynamic>> allData;
  final double dues;

  ClienPage({required this.client, required this.dues, required this.allData});

  // دالة لتحميل الفاتورة
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // دالة لعرض رسالة Toast عند عدم وجود فاتورة
  void _showNoInvoiceToast() {
    Fluttertoast.showToast(
        msg: 'No invoice available', toastLength: Toast.LENGTH_SHORT);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${client.fullNameArabic} ,  ${dues.toStringAsFixed(0)}',
          textAlign: TextAlign.center,
        ),
      ),
      ////45454545
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Date',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Value',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Negative Value',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Dues',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Invoice Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allData.length,
              itemBuilder: (context, index) {
                final sortedData = List.from(allData);
                sortedData.sort((a, b) {
                  final dateA = DateTime.parse(a['createdAt']);
                  final dateB = DateTime.parse(b['createdAt']);
                  return dateA.compareTo(dateB);
                });

                final clienDataAll = sortedData[index];
                final createdAt = DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(clienDataAll['createdAt']));
                final positiveValue =
                    clienDataAll['value'] >= 0 ? clienDataAll['value'] : null;
                final negativeValue =
                    clienDataAll['value'] < 0 ? clienDataAll['value'] : null;
                final dues = clienDataAll['dues'];
                final invoiceCode = clienDataAll['invoiceCode'];
                final downloadUrlPdf = clienDataAll['downloadUrlPdf'];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(createdAt, textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text(
                              positiveValue != null
                                  ? positiveValue.toStringAsFixed(2)
                                  : '',
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text(
                              negativeValue != null
                                  ? negativeValue.toStringAsFixed(2)
                                  : '',
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text(dues.toStringAsFixed(2),
                              textAlign: TextAlign.center)),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            if (invoiceCode != 'No invoice' &&
                                downloadUrlPdf != null) {
                              _launchURL(downloadUrlPdf);
                              print('Print invoice available');
                            } else {
                              // يمكنك إضافة إشعار أو رسالة هنا إذا كان رقم الفاتورة غير موجود
                              print('No invoice available');
                              _showNoInvoiceToast();
                            }
                          },
                          child: Text(
                            invoiceCode,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
