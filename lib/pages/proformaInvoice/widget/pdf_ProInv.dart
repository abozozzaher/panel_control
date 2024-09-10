import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' as mat;

import 'package:panel_control/generated/l10n.dart';
import 'package:panel_control/model/clien.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:provider/provider.dart';

import '../../../provider/trader_provider.dart';
import '../../../service/pro_inv_service.dart';

Future<void> generatePdfProInv(
  context,
  List<Map<String, dynamic>> tableData,
  invoiceCode,
  double totalPrices,
  String tax,
  double taxWthiPrice,
  double shippingFees,
  double dues,
  double finalTotal,
) async {
  final fontTajBold = await PdfGoogleFonts.tajawalBold();
  final fontTajRegular = await PdfGoogleFonts.tajawalRegular();
  String linkUrl =
      "https://panel-control-company-zaher.web.app/pro-invoices/$invoiceCode";
  final svgFooter = await rootBundle.loadString('assets/img/footer.svg');
  final Uint8List imageLogo = await rootBundle
      .load('assets/img/logo.png')
      .then((data) => data.buffer.asUint8List());

  // Create a PDF document.
  final doc = pw.Document();
  final trader = Provider.of<TraderProvider>(context, listen: false).trader;
//  final AccountService accountService = AccountService();

  final isRTL = mat.Directionality.of(context) == mat.TextDirection.rtl;

  doc.addPage(
    pw.MultiPage(
      pageTheme:
          _buildTheme(context, svgFooter, fontTajBold, fontTajRegular, linkUrl),
      header: (context) => _buildHeader(
          context, imageLogo, linkUrl, invoiceCode), // تمرير البيانات هنا

      footer: _buildFooter,
      build: (context) => [
        _contentHeader(context, finalTotal, isRTL, trader),
        _contentTable(context, tableData),
        pw.SizedBox(height: 20),
        _contentFooter(
            context, finalTotal, tax, totalPrices, dues, shippingFees),
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
      'invoices/${trader!.codeIdClien}/invoice_${DateTime.now().year}/INV-$invoiceCode.pdf');
  await storageRef.putData(outputFile);
  // الحصول على رابط لتنزيل الملف من Firebase Storage
  final downloadUrlPdf = await storageRef.getDownloadURL();

  await saveDataProInv(tableData, finalTotal, trader, totalPrices, taxWthiPrice,
      tax, dues, shippingFees, invoiceCode, downloadUrlPdf);
}

// تصميم شكل الصفحة
pw.PageTheme _buildTheme(mat.BuildContext context, String svgFooter,
    pw.Font fontTajBold, pw.Font fontTajRegular, String linkUrl) {
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
            data: linkUrl,
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
                    S().pro_invoice,
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
                        data: linkUrl,
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
    pw.Context context, finalTotal, bool isRTL, ClienData? trader) {
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
              '${S().final_total} : ${_formatCurrency(finalTotal)}',
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

pw.Widget _contentTable(
    pw.Context context, List<Map<String, dynamic>> tableDataList) {
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

  // استخراج البيانات من tableDataList
  final data = tableDataList.asMap().entries.map((entry) {
    // final index = entry.key;
    final productData = entry.value;

    return [
      productData['type'].toString(),
      productData['color'].toString(),
      '${productData['yarnNumber'].toString()}D',
      '${productData['totalLength'].toStringAsFixed(0)}Mt',
      '${productData['totalWeight'].toStringAsFixed(2)}Kg',
      '${productData['totalUnit'].toStringAsFixed(0)} ${S().unit}',
      '${productData['allQuantity'].toString()} ${S().pcs}',
      '\$${productData['price'].toStringAsFixed(2)}',
      '\$${productData['totalPrice'].toStringAsFixed(2)}',
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
pw.Widget _contentFooter(
    pw.Context context, finalTotal, tax, totalPrices, dues, shippingFees) {
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
                  pw.Text(_formatCurrency(totalPrices)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${S().tax} :'),
                  pw.Text('${tax}%'),
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
                  pw.Text(dues == 0
                      ? '${S().no_dues} :'
                      : dues > -1
                          ? '${S().previous_debt} :'
                          : '${S().customer_balance} :'),
                  pw.Text(_formatCurrency(dues)),
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

String _formatCurrency(double? amount) {
  return '\$${amount!.toStringAsFixed(2)}';
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
