import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' as mat;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/trader_provider.dart';
import '../../service/account_service.dart';
import '../../service/invoice_service.dart';

Future<void> generatePdf(
  context,
  Map<String, dynamic> aggregatedData,
  double grandTotalPrice, // مجموع سعر البضاعة فقط
  double previousDebts, // الدين على العميل
  double shippingFees, // اجور الشحن
  List<double> prices, //سعر السطر
  List<double> totalLinePrices, // كل مجموع الاسعار
  double finalTotal, // الاجور النهائية
  double taxs, // الضريبة
  String invoiceCode,
  InvoiceService invoiceService,
  double grandTotalPriceTaxs,
  String shippingCompanyName,
  String shippingTrackingNumber,
  String packingBagsNumber,
  double totalWeight,
  int totalQuantity,
  int totalLength,
  int totalScannedData,
) async {
  final svgFooter = await rootBundle.loadString('assets/img/footer.svg');
  final Uint8List imageLogo = await rootBundle
      .load('assets/img/logo.png')
      .then((data) => data.buffer.asUint8List());
  final fontBeiruti =
      pw.Font.ttf(await rootBundle.load('assets/fonts/Beiruti.ttf'));
  final fontTajBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal/Tajawal-Bold.ttf'));

  final fontTajRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal/Tajawal-Regular.ttf'));
  // Create a PDF document.
  final doc = pw.Document();
  final trader = Provider.of<TraderProvider>(context, listen: false).trader;
  final AccountService accountService = AccountService();

  String linkUrl =
      "https://admin.bluedukkan.com/${trader!.codeIdClien}/invoices/$invoiceCode";
  final isRTL = mat.Directionality.of(context) == mat.TextDirection.rtl;

  doc.addPage(
    pw.MultiPage(
      pageTheme:
          _buildTheme(context, svgFooter, fontTajBold, fontTajRegular, isRTL),
      header: (context) =>
          _buildHeader(context, imageLogo, linkUrl, invoiceCode),
      footer: (context) => _buildFooter(context, linkUrl),
      build: (context) => [
        _contentHeader(context, finalTotal, isRTL, trader, fontTajRegular),
        _contentTable(context, aggregatedData, prices, totalLinePrices, isRTL),
        pw.SizedBox(height: 20),
        _contentFooter(
          context,
          finalTotal,
          taxs,
          grandTotalPrice,
          previousDebts,
          shippingFees,
          fontBeiruti,
          isRTL,
          shippingCompanyName,
          shippingTrackingNumber,
          packingBagsNumber,
          totalWeight,
          totalQuantity,
          totalLength,
          totalScannedData,
        ),
        pw.SizedBox(height: 20),
        _termsAndConditions(context, fontTajBold),
      ],
    ),
  );

  // Return the PDF file content
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save());

  final valueAccount = (grandTotalPriceTaxs + shippingFees) * -1;

  final outputFile = await doc.save();

  // تحميل الملف إلى Firebase Storage
  final storageRef = FirebaseStorage.instance.ref().child(
      'invoices/${trader.codeIdClien}/invoice_${DateTime.now().year}/INV-$invoiceCode.pdf');

  await storageRef.putData(outputFile);
  // الحصول على رابط لتنزيل الملف من Firebase Storage
  final downloadUrlPdf = await storageRef.getDownloadURL();

  accountService.saveValueToFirebase(
      trader.codeIdClien, valueAccount, invoiceCode, downloadUrlPdf);

  await invoiceService.saveData(
    aggregatedData,
    finalTotal,
    trader,
    grandTotalPrice,
    grandTotalPriceTaxs,
    taxs,
    previousDebts,
    shippingFees,
    invoiceCode,
    downloadUrlPdf,
    shippingCompanyName,
    shippingTrackingNumber,
    packingBagsNumber,
    totalWeight,
    totalQuantity,
    totalLength,
    totalScannedData,
  );
}

// تصميم شكل الصفحة
pw.PageTheme _buildTheme(mat.BuildContext context, String svgFooter,
    pw.Font fontTajBold, pw.Font fontTajRegular, bool isRTL) {
  return pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    theme: pw.ThemeData.withFont(base: fontTajRegular, bold: fontTajBold)
        .copyWith(
            defaultTextStyle:
                pw.TextStyle(font: fontTajBold, fontFallback: [fontTajRegular]),
            header0: pw.TextStyle(
                font: fontTajBold,
                fontFallback: [fontTajRegular],
                color: PdfColors.teal,
                fontWeight: pw.FontWeight.bold)),
    buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child:
            pw.SvgImage(svg: svgFooter, alignment: pw.Alignment.bottomCenter)),
    textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
    margin: const pw.EdgeInsets.all(20),
  );
}

// راس الفاتورة
pw.Widget _buildHeader(pw.Context context, Uint8List imageLogo, String linkUrl,
    String invoiceCode) {
  return pw.Column(
    children: [
      pw.Row(
        children: [
          //كلمة الفاتورة والتاريخ ورقم الفاتورة
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.max,
              children: [
                pw.Container(
                  height: 50,
                  padding: const pw.EdgeInsets.only(left: 20, right: 20),
                  //      alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    S().invoice,
                    style: pw.Theme.of(context).header0.copyWith(fontSize: 40),
                  ),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                      color: PdfColors.blueGrey900),
                  padding: const pw.EdgeInsets.only(
                      left: 40, top: 10, bottom: 10, right: 40),
                  alignment: pw.Alignment.center,
                  height: 50,
                  child: pw.DefaultTextStyle(
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 12),
                    child: pw.GridView(
                      direction: pw.Axis.horizontal,
                      crossAxisCount: 2,
                      children: [
                        pw.Text(S().invoice),
                        pw.Text('INV-$invoiceCode'),
                        pw.Text(S().data),
                        pw.Text(_formatDate(DateTime.now())),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // اللوغة
          pw.Expanded(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                // إضافةنص و خط فاصل
                pw.Container(
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide())),
                  padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                  child: pw.Text(
                    S().blue_textiles,
                    style:
                        const pw.TextStyle(fontSize: 20, color: PdfColors.teal),
                  ),
                ),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  //       mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,

                  children: [
                    // اللوغو
                    pw.Container(
                      alignment: pw.Alignment.topLeft,
                      padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
                      height: 100,
                      child: pw.Image(
                        pw.MemoryImage(imageLogo),
                      ),
                    ),
                    // QR Code
                    pw.Container(
                      alignment: pw.Alignment.topRight,
                      padding: const pw.EdgeInsets.only(top: 10),
                      height: 72,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: linkUrl, // يمكنك استبدال هذا بالرابط الذي تريده
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      if (context.pageNumber > 1) pw.SizedBox(height: 20)
    ],
  );
}

// الذيل
pw.Widget _buildFooter(pw.Context context, String linkUrl) {
  double heighPdf = 50;
  double widthPdf = heighPdf * 5;
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Container(
            height: heighPdf,
            width: widthPdf,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.pdf417(),
              data: linkUrl,
              drawText: false,
            ),
          ),
          if (context.pagesCount < 2)
            pw.Text('')
          else
            pw.Text(
              '${S().page} ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.white,
              ),
            )
        ],
      ));
}

// الراس معلومات
pw.Widget _contentHeader(pw.Context context, finalTotal, bool isRTL,
    ClienData? trader, pw.Font fontTajRegular) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // قيمة الفاتورة في الراس
      pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 5),
          height: 40,
          child: pw.FittedBox(
            child: pw.Text(
              ' ${S().final_total} : ${_formatCurrency(finalTotal)}',
              style: pw.TextStyle(
                  color: PdfColors.teal,
                  fontStyle: pw.FontStyle.italic,
                  font: fontTajRegular),
            ),
          ),
        ),
      ),
// معلومات المرسل اليه
      pw.Expanded(
        child: pw.Row(
          children: [
            pw.Container(
              margin: const pw.EdgeInsets.only(left: 10, right: 10),
              height: 70,
              child: pw.Text(
                '${S().invoice_to} :',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  // fontSize: 12,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                height: 70,
                child: pw.RichText(
                    text: pw.TextSpan(
                        text: isRTL
                            ? trader!.fullNameArabic
                            : trader!.fullNameEnglish,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                      const pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(
                          fontSize: 5,
                        ),
                      ),
                      pw.TextSpan(
                        text:
                            '${trader.country}, ${trader.state}, ${trader.city},',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                      const pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(
                          fontSize: 5,
                        ),
                      ),
                      pw.TextSpan(
                        text: isRTL
                            ? trader.addressArabic
                            : trader.addressEnglish,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                    ])),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// عنوين راس الجدول
pw.Widget _contentTable(pw.Context context, Map<String, dynamic> aggregatedData,
    List<double> prices, List<double> totalLinePrices, bool isRTL) {
  final tableHeaders = DataLists().tableHeaders;
  final headers = isRTL ? tableHeaders.reversed.toList() : tableHeaders;
  int lineCounter = 1;

  // استخراج البيانات من aggregatedData
  final data = aggregatedData.entries.map((entry) {
    final productData = entry.value as Map<String, dynamic>;
    int index = aggregatedData.keys.toList().indexOf(entry.key);

    final row = [
      lineCounter.toString(), // إضافة عداد الأسطر هنا
      DataLists().translateType(productData['type'].toString()),
      DataLists().translateType(
        productData['color'].toString(),
      ),
      DataLists().translateType('${productData['yarn_number'].toString()}D'),
      DataLists()
          .translateType('${productData['length'].toStringAsFixed(0)}Mt'),
      DataLists()
          .translateType('${productData['total_weight'].toStringAsFixed(2)}Kg'),
      DataLists().translateType(
          '${productData['scanned_data'].toStringAsFixed(0)} ${S().unit}'),
      DataLists()
          .translateType('${productData['quantity'].toString()} ${S().pcs}'),
      _formatCurrency(prices[index]),
      _formatCurrency(totalLinePrices[index]),
    ];
    lineCounter++;
    return isRTL ? row.reversed.toList() : row;
  }).toList();

  return pw.TableHelper.fromTextArray(
    border: null,
    cellAlignment: pw.Alignment.center,
    headerDecoration: const pw.BoxDecoration(
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
      color: PdfColors.teal,
    ),
    headerStyle: pw.TextStyle(
        color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
    cellStyle: const pw.TextStyle(fontSize: 10),
    rowDecoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(width: .5)),
    ),
    headers: headers,
    data: data,
  );
}

// الذيل معلومات
pw.Widget _contentFooter(
    pw.Context context,
    finalTotal,
    taxs,
    grandTotalPrice,
    previousDebts,
    shippingFees,
    pw.Font fontBeiruti,
    bool isRTL,
    String shippingCompanyName,
    String shippingTrackingNumber,
    String packingBagsNumber,
    double totalWeight,
    int totalQuantity,
    int totalLength,
    int totalScannedData) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // رسالة الشكر في نهاية الفاتورة
      pw.Expanded(
        flex: 2,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              S().thank_you_for_your_business,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 20, bottom: 8),
              child: pw.Text(
                '${S().payment_info} :',
                style: pw.TextStyle(
                  color: PdfColors.teal,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Text(
              'ZAHiR LOJiSTiK TEKSTiL SANAYi VE TiCARET LiMiTED ŞiRKETi\n${S().company_payment_info}\nSANAYİ MAH. 60092 NOLU CAD. NO: 43 ŞEHİTKAMİL / GAZİANTEP\n 9961355399 ZIP CODE: 27110',
              style:
                  pw.TextStyle(fontSize: 8, lineSpacing: 5, font: fontBeiruti),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide())),
                        padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                        child: pw.Text(
                          S().terms_conditions,
                          style: pw.Theme.of(context)
                              .header0
                              .copyWith(fontSize: 12),
                        ),
                      ),
                      pw.Text(
                        S().terms_and_conditions,
                        textAlign: pw.TextAlign.justify,
                        style: const pw.TextStyle(fontSize: 4, lineSpacing: 2),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(child: pw.SizedBox()),
              ],
            )
          ],
        ),
      ),
      // اجمالي الفاتورة
      pw.Expanded(
        flex: 1,
        child: pw.DefaultTextStyle(
          style: const pw.TextStyle(
            fontSize: 10,
            // color: PdfColors.red,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().sub_total} :'),
                  pw.Text(_formatCurrency(grandTotalPrice)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().tax} :'),
                  pw.Text('${(taxs * 100).toStringAsFixed(1)}%'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().shipping_fees}:'),
                  pw.Text(_formatCurrency(shippingFees)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(previousDebts == 0
                      ? '${S().no_dues} :'
                      : previousDebts > -1
                          ? '${S().previous_debt} :'
                          : '${S().customer_balance} :'),
                  pw.Text(_formatCurrency(previousDebts)),
                ],
              ),
              pw.Divider(color: PdfColors.blueGrey900),
              pw.DefaultTextStyle(
                style: pw.TextStyle(
                  color: PdfColors.teal,
                  // fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${S().final_total} :'),
                    pw.Text(_formatCurrency(finalTotal)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                  child: pw.Text(
                S().shipping_information,
                style: pw.TextStyle(
                  color: PdfColors.teal,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              )),
              pw.Divider(color: PdfColors.blueGrey900),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().shipping_company_name} :'),
                  pw.Text(shippingCompanyName),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().shipping_tracking_number} :'),
                  pw.Text(shippingTrackingNumber),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().packing_bags_number} :'),
                  pw.Text('${packingBagsNumber} ${S().bags}'),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().total_weight} :'),
                  pw.Text('${totalWeight.toStringAsFixed(0)} kg'),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().total_roll} :'),
                  pw.Text('$totalQuantity ${S().roll}'),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().total_unit} :'),
                  pw.Text('${totalScannedData.toStringAsFixed(0)} ${S().unit}'),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().total_length} :'),
                  //pw.Text('$totalLength MT'),
                  pw.Text('${formatNumber(totalLength)} MT'),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

String formatNumber(int num) {
  if (num >= 1000000000) {
    return (num / 1000000000).toStringAsFixed(1) + 'B'; // مليار
  } else if (num >= 1000000) {
    return (num / 1000000).toStringAsFixed(1) + 'M'; // مليون
  } else if (num >= 1000) {
    return (num / 1000).toStringAsFixed(1) + 'k'; // ألف
  } else {
    return num.toStringAsFixed(1); // أقل من ألف
  }
}

// سياسية الارجاع
pw.Widget _termsAndConditions(pw.Context context, pw.Font fontTajBold) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      /*
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide())),
              padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
              child: pw.Text(
                S().terms_conditions,
                style: pw.Theme.of(context).header0.copyWith(fontSize: 12),
              ),
            ),
            pw.Text(
              S().terms_and_conditions,
              textAlign: pw.TextAlign.justify,
              style: const pw.TextStyle(fontSize: 4, lineSpacing: 1),
            ),
          ],
        ),
      ),
      pw.Expanded(
        child: pw.SizedBox(),
      ),
      */
    ],
  );
}

String _formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

DateTime now = DateTime.now();

String _formatDate(DateTime date) {
  final format =
      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  return format;
}
