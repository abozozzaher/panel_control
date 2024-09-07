import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' as mat;

import 'package:panel_control/generated/l10n.dart';
import 'package:panel_control/model/clien.dart';
import 'package:panel_control/service/invoice_service.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:provider/provider.dart';

import '../../provider/trader_provider.dart';
import '../../service/account_service.dart';

Future<void> generatePdf(
    context,
    Map<String, dynamic> aggregatedData,
    double grandTotalPrice, // مجموع سعر البضاعة فقط
    double previousDebts, // الدين على العميل
    double shippingFees, // اجور الشحن
    List<double> prices, //سعر السطر
    List<double> totalLinePrices, // كل مجموع الاسعار
    double total, // الاجور النهائية
    double taxs, // الضريبة
    String invoiceCode,
    InvoiceService invoiceService,
    double grandTotalPriceTaxs) async {
  final fontTajBold = await PdfGoogleFonts.tajawalBold();
  final fontTajRegular = await PdfGoogleFonts.tajawalRegular();

  final svgFooter = await rootBundle.loadString('assets/img/footer.svg');
  final Uint8List imageLogo = await rootBundle
      .load('assets/img/logo.png')
      .then((data) => data.buffer.asUint8List());

  // Create a PDF document.
  final doc = pw.Document();
  final trader = Provider.of<TraderProvider>(context, listen: false).trader;
  final AccountService accountService = AccountService();

  final isRTL = mat.Directionality.of(context) == mat.TextDirection.rtl;

  doc.addPage(
    pw.MultiPage(
      pageTheme: _buildTheme(
          context, svgFooter, fontTajBold, fontTajRegular, invoiceCode),
      header: (context) =>
          _buildHeader(context, imageLogo, invoiceCode), // تمرير البيانات هنا

      footer: _buildFooter,
      build: (context) => [
        _contentHeader(context, total, isRTL, trader),
        _contentTable(context, aggregatedData, prices, totalLinePrices),
        pw.SizedBox(height: 20),
        _contentFooter(
            context, total, taxs, grandTotalPrice, previousDebts, shippingFees),
        pw.SizedBox(height: 20),
        _termsAndConditions(context, fontTajBold),
      ],
    ),
  );

  // Return the PDF file content
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save());
  final outputFile = await doc.save();

  // تحميل الملف إلى Firebase Storage
  final storageRef = FirebaseStorage.instance.ref().child(
      'invoices/${trader!.codeIdClien}/invoice_${DateTime.now().year}/$invoiceCode.pdf');
  await storageRef.putData(outputFile);
  // الحصول على رابط لتنزيل الملف من Firebase Storage
  final downloadUrlPdf = await storageRef.getDownloadURL();
  final valueAccount = (grandTotalPriceTaxs + shippingFees) * -1;

  accountService.saveValueToFirebase(
      trader.codeIdClien, valueAccount, invoiceCode, downloadUrlPdf);

  await invoiceService.saveData(
      aggregatedData,
      total,
      trader,
      grandTotalPrice,
      grandTotalPriceTaxs,
      taxs,
      previousDebts,
      shippingFees,
      invoiceCode,
      downloadUrlPdf);
}

// تصميم شكل الصفحة
pw.PageTheme _buildTheme(mat.BuildContext context, String svgFooter,
    pw.Font fontTajBold, pw.Font fontTajRegular, String invoiceCode) {
  final isRTL = mat.Directionality.of(context) == mat.TextDirection.rtl;
  double heighPdf = 50;
  double widthPdf = heighPdf * 3;
  return pw.PageTheme(
    theme: pw.ThemeData.withFont(base: fontTajBold).copyWith(
      defaultTextStyle:
          pw.TextStyle(font: fontTajBold, fontFallback: [fontTajRegular]),
      header0: pw.TextStyle(
          font: fontTajBold,
          fontFallback: [fontTajRegular],
          color: PdfColors.teal,
          fontWeight: pw.FontWeight.bold),
    ),
    buildBackground: (context) => pw.FullPage(
      ignoreMargins: true,
      // child: pw.SvgImage(svg: svgFooter),
      child: pw.Stack(alignment: pw.Alignment.bottomCenter, children: [
        pw.SvgImage(svg: svgFooter),
        // الباركود ال بي دي اف

        pw.Positioned(
          bottom: 10, // adjust the top position as needed
          right: 70, // adjust the left position as needed
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.pdf417(),
            data: invoiceCode,
            drawText: false,
            height: heighPdf,
            width: widthPdf,
          ),
        ),
      ]),
    ),
    textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
    margin: pw.EdgeInsets.all(20),
  );
}

// راس الفاتورة
pw.Widget _buildHeader(
    pw.Context context, Uint8List imageLogo, String invoiceCode) {
  return pw.Column(
    children: [
      pw.Row(
        //  crossAxisAlignment: pw.CrossAxisAlignment.end,
        //    mainAxisAlignment: pw.MainAxisAlignment.center,
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
                  decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                      color: PdfColors.blueGrey900),
                  padding: pw.EdgeInsets.only(
                      left: 40, top: 10, bottom: 10, right: 40),
                  alignment: pw.Alignment.center,
                  height: 50,
                  child: pw.DefaultTextStyle(
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
                    child: pw.GridView(
                      direction: pw.Axis.horizontal,
                      crossAxisCount: 2,
                      children: [
                        pw.Text(S().invoice),
                        pw.Text(invoiceCode),
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
                  decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide())),
                  padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                  child: pw.Text(
                    S().blue_textiles,
                    style: pw.TextStyle(fontSize: 20, color: PdfColors.teal),
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
                        data:
                            invoiceCode, // يمكنك استبدال هذا بالرابط الذي تريده
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
pw.Widget _buildFooter(pw.Context context) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      //  رقم الصفحة
      pw.Text(
        '${S().page} ${context.pageNumber}/${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 12,
          color: PdfColors.white,
        ),
      ),
    ],
  );
}

// الراس معلومات
pw.Widget _contentHeader(
    pw.Context context, total, bool isRTL, ClienData? trader) {
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
              '${S().total} : ${_formatCurrency(total)}',
              style: pw.TextStyle(
                color: PdfColors.teal,
                fontStyle: pw.FontStyle.italic,
              ),
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
    List<double> prices, List<double> totalLinePrices) {
  final tableHeaders = [
    S().type,
    S().color,
    S().yarn_number,
    S().length,
    S().total_weight,
    S().unit,
    S().price,
    S().quantity,
    S().total_price,
  ];

  // استخراج البيانات من aggregatedData
  final data = aggregatedData.entries.map((entry) {
    final productData = entry.value as Map<String, dynamic>;
    int index = aggregatedData.keys.toList().indexOf(entry.key);

    return [
      productData['type'].toString(),
      productData['color'].toString(),
      '${productData['yarn_number'].toString()}D',
      '${productData['length'].toString()}Mt',
      '${productData['total_weight'].toString()}Kg',
      '${productData['scanned_data'].toString()} ${S().unit}',
      _formatCurrency(prices[index]),
      '${productData['quantity'].toString()} ${S().pcs}',
      _formatCurrency(totalLinePrices[index]),
    ];
  }).toList();

  return pw.TableHelper.fromTextArray(
    border: null,
    cellAlignment: pw.Alignment.center,
    headerDecoration: pw.BoxDecoration(
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      color: PdfColors.teal,
    ),
    headerStyle: pw.TextStyle(
        color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
    cellStyle: const pw.TextStyle(fontSize: 10),
    rowDecoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(width: .5)),
    ),
    headers: List<String>.generate(
      tableHeaders.length,
      (col) => tableHeaders[col],
    ),
    data: data,
  );
}

// الذيل معلومات
pw.Widget _contentFooter(pw.Context context, total, taxs, grandTotalPrice,
    previousDebts, shippingFees) {
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
              '4509 Wiseman Street\nKnoxville, Tennessee(TN), 37929\n865-372-0425',
              style: pw.TextStyle(fontSize: 8, lineSpacing: 5),
            ),
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
                          : '${S().no_previous_religion} :'),
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
                    pw.Text('${S().total} :'),
                    pw.Text(_formatCurrency(total)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// سياسية الارجاع
pw.Widget _termsAndConditions(pw.Context context, pw.Font fontTajBold) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              decoration:
                  pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())),
              padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
              child: pw.Text(
                S().terms_conditions,
                style: pw.Theme.of(context).header0.copyWith(fontSize: 12),
              ),
            ),
            pw.Text(
              pw.LoremText().paragraph(40),
              textAlign: pw.TextAlign.justify,
              style:
                  pw.TextStyle(fontSize: 6, lineSpacing: 2, font: fontTajBold),
            ),
          ],
        ),
      ),
      pw.Expanded(
        child: pw.SizedBox(),
      ),
    ],
  );
}

String _formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

DateTime now = DateTime.now();

String _formatDate(DateTime date) {
  final format = now.day.toString().padLeft(2, '0') +
      '/' +
      now.month.toString().padLeft(2, '0') +
      '/' +
      now.year.toString();
  return format;
}
