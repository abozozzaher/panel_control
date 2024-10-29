import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../../service/toasts.dart';

String yearMonth = DateFormat('yyyy-MM').format(DateTime.now());

/// تحويل الأرقام العربية إلى أرقام إنجليزية
String convertArabicToEnglish(String text) {
  return text.replaceAllMapped(
    RegExp(r'[٠-٩]'),
    (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString(),
  );
}

///  تحويل الأرقام العربية إلى أرقام إنجليزية للشهر
String convertArabicToEnglishForMonth(String text) {
  return text.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) =>
          String.fromCharCode(match.group(0)!.codeUnitAt(0) - 1632 + 48));
}

String generateCode() {
  DateTime now = DateTime.now();
  var formatter = DateFormat('yyyyMMddHHmmssssssss');
  String date = formatter.format(now);
  return date; // Dynamic serial number should be updated
}

Future<Uint8List> generateQRCodeImage(String data, {int size = 400}) async {
  final qrValidationResult = QrValidator.validate(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );

  if (qrValidationResult.status == QrValidationStatus.valid) {
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: true,
    );

    // Create an image with the specified size (default is 400)
    final ui.Image image = await painter.toImage(size.toDouble());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  } else {
    throw Exception('Could not generate QR code');
  }
}

Future<String> uploadImageToStorage(
  XFile? selectedImage,
  String productId,
  Uint8List? webImage,
) async {
  String englishYearMonth = convertArabicToEnglishForMonth(yearMonth);
  String englishProductId = convertArabicToEnglish(productId);
  String day = '${DateTime.now().day}';

  Reference storageReference = FirebaseStorage.instance
      .ref()
      .child('productsImage/$englishYearMonth/$day/$englishProductId.jpg');
  SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

  UploadTask uploadTask;

  if (selectedImage != null) {
    // قراءة الصورة كـ Uint8List لتتمكن من ضغطها
    Uint8List imageBytes = await selectedImage.readAsBytes();

    // تصغير الصورة
    Uint8List? compressedImageBytes =
        await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: 800,
      minWidth: 800,
      quality: 85,
    );

    // رفع الصورة المصغرة
    uploadTask = storageReference.putData(compressedImageBytes, metadata);
  } else {
    uploadTask = storageReference.putData(webImage!, metadata);
  }

  await uploadTask;
  return await storageReference.getDownloadURL();
}

// حفظ رابط الملف في SharedPreferences
Future<void> saveFileUrl(String url) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('pdfFileUrl', url); // حفظ الرابط تحت مفتاح 'pdfFileUrl'
}

// استرجاع رابط الملف من SharedPreferences
Future<String?> getFileUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('pdfFileUrl'); // استرجاع الرابط المحفوظ
}

// فتح رابط الـ PDF في المتصفح أو عارض PDF
Future<void> openPdf(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showToast('${S().could_not_launch_url} : #208 $url');
    throw '${S().could_not_launch_url} : $url';
  }
}
