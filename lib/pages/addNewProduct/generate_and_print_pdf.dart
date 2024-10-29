import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../data/data_lists.dart';
import '../../provider/user_provider.dart';
import 'helper.dart';

Future<void> generateAndPrintPDF(
    BuildContext context,
    String Function(String text) convertArabicToEnglish,
    Future<Uint8List> Function(String data, {int size}) generateQRCodeImage,
    String productId,
    String? imageUrl,
    String? englishYearMonth,
    String? selectedType,
    String? selectedColor,
    String? selectedWidth,
    String? selectedWeight,
    String? selectedYarnNumber,
    String? selectedShift,
    String? selectedQuantity,
    String? selectedLength) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userData = userProvider.user;
  final pdf = pw.Document();
  String englishProductId = convertArabicToEnglish(productId);
  String documentPath =
      'productsForAllMonths/$englishYearMonth/$englishProductId';

  String productUrl =
      "https://admin.bluedukkan.com/$englishYearMonth/$englishProductId"; // Replace with your product URL

  final ttfTr = await rootBundle.load('assets/fonts/Beiruti.ttf');
  final fontBe = pw.Font.ttf(ttfTr);
  final fontRo = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal/Tajawal-Bold.ttf'));

  DateTime now = DateTime.now();

  String englishDataTime =
      '${now.year} - ${now.month.toString().padLeft(2, '0')} - ${now.day.toString().padLeft(2, '0')}';
  final profileImage = pw.MemoryImage(
    (await rootBundle.load('assets/img/logo.png')).buffer.asUint8List(),
  );
  // Generate QR code image
  final qrCodeImage = await generateQRCodeImage(productUrl);
  double heighPdf = 80;
  double widthPdf = heighPdf * 3;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a6.copyWith(
          marginBottom: 5.0, marginLeft: 5.0, marginTop: 5.0, marginRight: 5.0),
      build: (pw.Context context) {
        return pw.Column(
          //    crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    alignment: pw.Alignment.topLeft,
                    margin: const pw.EdgeInsets.all(5.0),
                    child: pw.Image(profileImage),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    height: 50,
                    alignment: pw.Alignment.center,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Blue textiles',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4), // إضافة مساحة بين النصين
                        pw.Text(
                          'المنسوجات الزرقاء',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal,
                            font: fontBe,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    alignment: pw.Alignment.topRight,
                    margin: const pw.EdgeInsets.all(5.0),
                    child: pw.Image(pw.MemoryImage(qrCodeImage)),
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 0.1),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5.0), // 5mm margin around text
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.max,
                children: [
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Ürün Bilgisi',
                        style: pw.TextStyle(
                            font: fontBe,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'معلومات المنتج :',
                        style: pw.TextStyle(
                            font: fontBe,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('ID Kodu : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        englishProductId,
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(
                            font: fontRo, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'كود المنتج :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tip : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        DataLists().translateType('$selectedType'.toString()),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: fontRo),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'النوع :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Renk : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        DataLists().translateType('$selectedColor'.toString()),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: fontRo),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'اللون :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Genişlik : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        '$selectedWidth' 'mm',
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: fontRo),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'العرض :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Ağırlık : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        '$selectedWeight'
                        'g'
                        '/'
                        '${(double.parse(selectedWeight.toString()) * double.parse(selectedQuantity.toString())) / 1000}'
                        'Kg',
                        //  textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: fontRo),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'الوزن :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('İplik Density : ',
                          style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        '$selectedYarnNumber'
                        'D',
                        //   textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: fontRo),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'نمرة الخيط :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Uzunluk : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        '$selectedLength'
                        'MT',
                        //  textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: fontRo),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'الطول :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Adet : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(
                        '$selectedQuantity'
                        'Pcs',
                        //    textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: fontRo),
                      ),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'العدد :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tarih : ', style: pw.TextStyle(font: fontBe)),
                      pw.Text(englishDataTime,
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo)),
                      pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'التاريخ :',
                        style: pw.TextStyle(font: fontBe),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Center(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.all(2),
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.pdf417(),
                        data: productUrl,
                        width: widthPdf,
                        height: heighPdf,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Center(
              child: pw.Text(
                'ZAHİR LOJİSTİK TEKSTİL SANAYİ VE TİCARET LİMİTED ŞİRKETİ',
                style: pw.TextStyle(
                    font: fontBe, fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Türkiye Gaziantep Sanayi MAH. 60092',
                style: pw.TextStyle(
                  fontSize: 6,
                  font: fontBe,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Made in Türkiye',
                style: pw.TextStyle(
                  fontSize: 6,
                  font: fontBe,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());

  final outputFile = await pdf.save();

  // تحميل الملف إلى Firebase Storage
  final storageRef = FirebaseStorage.instance.ref().child(
      'BarkodQR/Print_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}/CodeQR-$englishProductId.pdf');
  await storageRef.putData(outputFile);
  // الحصول على رابط لتنزيل الملف من Firebase Storage
  final docmentQRUrlPdf = await storageRef.getDownloadURL();

// حفظ رابط الـ PDF في SharedPreferences
  await saveFileUrl(docmentQRUrlPdf);
  // Save data to Firestore
  FirebaseFirestore.instance.collection('products').doc(documentPath).set({
    'type': selectedType,
    'color': selectedColor,
    'width': selectedWidth,
    'weight': selectedWeight,
    'total_weight': (double.parse(selectedWeight.toString()) *
            double.parse(selectedQuantity.toString())) /
        1000,
    'yarn_number': selectedYarnNumber,
    'productId': englishProductId,
    'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(DateTime.now()),
    'shift': selectedShift,
    'quantity': selectedQuantity,
    'length': selectedLength,
    'created_by': userData!.id,
    'sale_status': false,
    'image_url': imageUrl ?? '',
    'docmentQRUrlPdf': docmentQRUrlPdf,
  });
}
