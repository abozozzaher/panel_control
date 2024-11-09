import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../excel_fille/excelClienPage.dart';
import '../../service/toasts.dart';

class ClienPage extends StatelessWidget {
  final ClienData client;
  final List<Map<String, dynamic>> allData;
  final double dues;

  const ClienPage(
      {super.key,
      required this.client,
      required this.dues,
      required this.allData});

  // دالة لتحميل الفاتورة
  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showToast('${S().could_not_launch_url} : #207 $url');
      throw '${S().could_not_launch_url} : $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(client.fullNameArabic, textAlign: TextAlign.center)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              alignment: Alignment.center,
              height: 30,
              color: dues < 0 ? Colors.redAccent : Colors.greenAccent,
              child: Text('\$${dues.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  textDirection: ui.TextDirection.ltr)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              onPressed: () {
                saveDataToExcelClienPage(allData, client);
              },
              icon: Icon(Icons.shuffle_outlined),
              label: Text(S().download_data_in_excel_format),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // عرض الزر بشكل كامل
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(S().data,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().input,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().output,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().dues,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text(S().invoice_code,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
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
                final positiveValue =
                    clienDataAll['value'] >= 0 ? clienDataAll['value'] : null;
                final negativeValue =
                    clienDataAll['value'] < 0 ? clienDataAll['value'] : null;
                final dues = clienDataAll['dues'];
                final invoiceCode = clienDataAll['invoiceCode'];
                final Uri downloadUrlPdf =
                    Uri.parse(clienDataAll['downloadUrlPdf']);
                final Uri linkUrl = Uri.parse(
                    "https://admin.bluedukkan.com/${client.codeIdClien}/invoices/$invoiceCode");

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                              DateFormat('dd/MM/yyyy').format(
                                  DateTime.parse(clienDataAll['createdAt'])),
                              textDirection: ui.TextDirection.ltr,
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text(
                              positiveValue != null
                                  ? '+${positiveValue.toStringAsFixed(2)}'
                                  : '',
                              textDirection: ui.TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text(
                              negativeValue != null
                                  ? negativeValue.toStringAsFixed(2)
                                  : '',
                              textDirection: ui.TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text(dues.toStringAsFixed(2),
                              textDirection: ui.TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            if (invoiceCode != 'No invoice') {
                              showToast(S().you_are_directed_to_the_invoice);
                              _launchURL(linkUrl);
                            } else {
                              showToast(S().no_invoice_available);
                            }
                          },
                          onLongPress: () {
                            if (invoiceCode != 'No invoice') {
                              showToast(S().you_are_directed_to_the_invoice);
                              _launchURL(downloadUrlPdf);
                            } else {
                              showToast(S().no_invoice_available);
                            }
                          },
                          child: Text(
                            invoiceCode,
                            textDirection: ui.TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
