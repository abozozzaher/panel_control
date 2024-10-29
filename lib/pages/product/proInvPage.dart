import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../service/toasts.dart';

class ProInvoicePage extends StatefulWidget {
  final String? invoiceCode;

  const ProInvoicePage({super.key, required this.invoiceCode});

  @override
  State<ProInvoicePage> createState() => _ProInvoicePageState();
}

class _ProInvoicePageState extends State<ProInvoicePage> {
  String _formatCurrency(String amount) {
    return '\$$amount';
  }

  @override
  Widget build(BuildContext context) {
    String linkUrl =
        "https://admin.bluedukkan.com/pro-invoices/${widget.invoiceCode}";
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
        title: Text(S().pro_invoice_details),
        leading: IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            Share.share('${S().check_out_my_invoice} $linkUrl',
                subject: S().look_what_i_have);
          },
        ),
      ),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('pro-invoices')
              .doc(widget.invoiceCode)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(child: Text(S().failed_to_load_invoice_details));
            }

            // استرجاع البيانات من المستند
            var data = snapshot.data!.data() as Map<String, dynamic>;
            final aggregatedDataList = data["products"] as List<dynamic>;
            Timestamp? timestamp = data['createdAt'];

            DateTime dateTime = timestamp!.toDate();

            String formattedDate =
                '${dateTime.day}/${dateTime.month}/${dateTime.year}';

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 980,
                alignment: Alignment.topCenter,
                //  margin: const EdgeInsets.symmetric(horizontal: 50),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  // alignment: Alignment.centerLeft,
                                  child: Text(
                                    S().pro_invoice,
                                    style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40),
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(2)),
                                      color: Colors.blueGrey),
                                  padding: const EdgeInsets.only(
                                      left: 40, top: 10, bottom: 10, right: 40),
                                  alignment: Alignment.center,
                                  height: 60,
                                  child: DefaultTextStyle(
                                    style: const TextStyle(
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
                                            Text(formattedDate)
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(S().invoice),
                                            Text('INV-${data['invoiceCode']}'),
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
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide())),
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 4),
                                  child: Text(
                                    S().blue_textiles,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.teal),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // اللوغو
                                    Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(10),
                                        height: 90,
                                        width: 90,
                                        child: const Image(
                                            image: AssetImage(
                                                'assets/img/logoPage.png'))),
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().final_total} :',
                                        style: const TextStyle(
                                            color: Colors.teal,
                                            fontStyle: FontStyle.italic)),
                                    Text(_formatCurrency(data['finalTotal']),
                                        textDirection: TextDirection.ltr,
                                        style: const TextStyle(
                                            color: Colors.teal,
                                            fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // معلومات المرسل اليه
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  height: 70,
                                  child: Text(
                                    '${S().invoice_to} :',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 70,
                                    child: RichText(
                                        text: TextSpan(
                                            text: isRTL
                                                ? '${data['fullNameArabic'][0]}*****'
                                                : '${data['fullNameEnglish'][0]}*****',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                            .brightness ==
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
                                            text: '${data['country']}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Theme.of(context)
                                                            .brightness ==
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
                                                ? '${data['fullNameArabic'][2]}*****'
                                                : '${data['fullNameEnglish'][1]}*****',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Theme.of(context)
                                                            .brightness ==
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
                              color: Colors
                                  .black, // Change the text color to yellow
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          columns: columns,
                          rows: [
                            ...aggregatedDataList.map((rowData) {
                              // final rowData = entry.value;
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
                                            '${rowData['totalLength']} Mt'),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.ltr,
                                        maxLines: 1))),
                                DataCell(Center(
                                    child: Text(
                                        DataLists().translateType(
                                            '${_formatCurrency(rowData['totalWeight'])} Kg'),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.ltr,
                                        maxLines: 1))),
                                DataCell(Center(
                                    child: Text(
                                        DataLists().translateType(
                                            '${rowData['totalUnit']} ${S().unit}'),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.ltr,
                                        maxLines: 1))),
                                DataCell(Center(
                                    child: Text(
                                        DataLists().translateType(
                                            '${rowData['allQuantity']} ${S().pcs}'),
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
                                        DataLists().translateType(
                                            _formatCurrency(
                                                rowData['totalPrice'])),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.ltr,
                                        maxLines: 1))),
                              ]);
                            }),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 30),
                          // رسالة الشكر في نهاية الفاتورة
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S().thank_you_for_your_business,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 20, bottom: 8),
                                  child: Text(
                                    '${S().payment_info} :',
                                    style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  'ZAHiR LOJiSTiK TEKSTiL SANAYi VE TiCARET LiMiTED ŞiRKETi\n${S().company_payment_info}\nSANAYİ MAH. 60092 NOLU CAD. NO: 43 ŞEHİTKAMİL / GAZİANTEP\n 9961355399 ZIP CODE: 27110',
                                  style: const TextStyle(
                                      fontSize: 12, wordSpacing: 5),
                                ),
                              ],
                            ),
                          ),
                          // اجمالي الفاتورة
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().sub_total} :'),
                                    Text(_formatCurrency(data['totalPrices']),
                                        textDirection: TextDirection.ltr)
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().tax} :'),
                                    Text('${(data['tax'])}%',
                                        textDirection: TextDirection.ltr)
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().shipping_fees}:'),
                                    Text(_formatCurrency(data['shippingFees']),
                                        textDirection: TextDirection.ltr),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().customer_balance} :'),
                                    Text('\$${data['dues']}',
                                        textDirection: TextDirection.ltr),
                                  ],
                                ),
                                const Divider(color: Colors.blueGrey),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().final_total} :',
                                        style: const TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold)),
                                    Text(_formatCurrency(data['finalTotal']),
                                        style: const TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold),
                                        textDirection: TextDirection.ltr),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Center(
                                    child: Text(
                                  S().shipping_information,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                                Divider(color: Colors.blueGrey),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().shipping_company_name} :'),
                                    Text(data['shippingCompanyName']),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().shipping_tracking_number} :'),
                                    Text(data['shippingTrackingNumber']),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().packing_bags_number} :'),
                                    Text(
                                        '${data['packingBagsNumber']} ${S().bags}'),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().total_weight} :'),
                                    Text('${data['totalWeightSum']} kg'),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${S().total_unit} :'),
                                    Text('${data['totalUnitSum']} ${S().unit}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url =
                              Uri.parse('https://textile.bluedukkan.com');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            showToast('${S().could_not_launch_url} #201 $url');
                            throw 'Could not launch $url';
                          }
                        },
                        label: Text(
                          S().visit_our_website_and_search_for_more_modern_designs_and_models,
                          textAlign: TextAlign.center,
                        ),
                        icon: const Icon(Icons.plagiarism_outlined),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(data['downloadUrlPdf']);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            showToast('${S().could_not_launch_url} #204 $url');
                            throw 'Could not launch $url';
                          }
                        },
                        label: Text(S().download_a_copy_of_the_invoice_in_pdf),
                        icon: const Icon(Icons.print),
                      ),
                      const SizedBox(height: 50)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
