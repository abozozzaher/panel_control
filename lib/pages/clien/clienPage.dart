import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart'; // تأكد من إضافة هذه الحزمة في pubspec.yaml

import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../service/toasts.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          client.fullNameArabic,
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        children: [
          dues < 0
              ? Container(
                  alignment: Alignment.center,
                  height: 30,
                  color: dues < 1 ? Colors.redAccent : Colors.greenAccent,
                  child: Text('\$${dues.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr))
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(S().data,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().value,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().negative_value,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().dues,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().invoice_code,
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
                //   final createdAt = DateFormat('dd/MM/yyyy') .format(DateTime.parse(clienDataAll['createdAt']));
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
                          child: Text(clienDataAll['createdAt'],
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text(
                              positiveValue != null
                                  ? positiveValue.toStringAsFixed(2)
                                  : '',
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text(
                              negativeValue != null
                                  ? negativeValue.toStringAsFixed(2)
                                  : '',
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text(dues.toStringAsFixed(2),
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center)),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            if (invoiceCode != 'No invoice' &&
                                downloadUrlPdf != null) {
                              showToast('You are directed to the invoice');
                              _launchURL(downloadUrlPdf);
                            } else {
                              showToast(S().no_invoice_available);
                            }
                          },
                          child: Text(
                            invoiceCode,
                            textDirection: TextDirection.ltr,
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
