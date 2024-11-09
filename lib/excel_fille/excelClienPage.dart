import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../data/data_lists.dart';
import '../generated/l10n.dart';
import '../model/clien.dart';

import '../service/toasts.dart';

import 'save_file_mobile.dart' if (dart.library.html) 'save_file_web.dart';

Future<void> saveDataToExcelClienPage(
    List<Map<String, dynamic>> allData, ClienData client) async {
  final now = DateTime.now();
  final formattedDateXlsx = '${now.day}-${now.month}-${now.year}';

  // فرز البيانات بناءً على تاريخ الإنشاء (createdAt)
  allData.sort((a, b) {
    DateTime dateA = DateTime.parse(a['createdAt']);
    DateTime dateB = DateTime.parse(b['createdAt']);
    return dateA.compareTo(dateB);
  });

  final xlsio.Workbook workbook = xlsio.Workbook();
  final xlsio.Worksheet sheet = workbook.worksheets[0];

// تطبيق التنسيق على كل عمود في السطر الأول دون دمج
  for (int i = 1; i <= 27; i++) {
    final xlsio.Range range =
        sheet.getRangeByIndex(1, i); // تحديد الخلية في السطر الأول لكل عمود
    range.cellStyle.backColor = '#FFFF00'; // تحديد لون الخلفية
    range.cellStyle.hAlign = xlsio.HAlignType.center; // محاذاة أفقية
    range.cellStyle.vAlign = xlsio.VAlignType.center; // محاذاة عمودية
    range.cellStyle.bold = true;
  }

// كتابة رؤوس الأعمدة

  sheet.getRangeByName('A1').setValue(S().data);
  sheet.getRangeByName('B1').setValue(S().type_of_operation);
  sheet.getRangeByName('C1').setValue(S().amount);
  sheet.getRangeByName('D1').setValue(S().customer_balance);
  sheet.getRangeByName('E1').setValue(S().invoice_code);
  sheet.getRangeByName('F1').setValue(S().type);
  sheet.getRangeByName('G1').setValue(S().color);
  sheet.getRangeByName('H1').setValue(S().length);
  sheet.getRangeByName('I1').setValue(S().yarn_number);
  sheet.getRangeByName('J1').setValue(S().width);
  sheet.getRangeByName('K1').setValue(S().total_weight);
  sheet.getRangeByName('L1').setValue(S().price);
  sheet.getRangeByName('M1').setValue(S().quantity);
  sheet.getRangeByName('N1').setValue(S().total_price);
  sheet.getRangeByName('O1').setValue(S().sub_total);
  sheet.getRangeByName('P1').setValue(S().tax);
  sheet.getRangeByName('Q1').setValue('${S().sub_total} ${S().tax}');
  sheet.getRangeByName('R1').setValue(S().previous_debt);
  sheet.getRangeByName('S1').setValue(S().shipping_company_name);
  sheet.getRangeByName('T1').setValue(S().shipping_fees);
  sheet.getRangeByName('U1').setValue(S().shipping_tracking_number);
  sheet.getRangeByName('V1').setValue(S().packing_bags_number);
  sheet.getRangeByName('W1').setValue(S().final_total);
  sheet.getRangeByName('X1').setValue(S().total_length);
  sheet.getRangeByName('Y1').setValue(S().total_quantity);
  sheet.getRangeByName('Z1').setValue(S().total_weight);
  sheet.getRangeByName('AA1').setValue(S().PDF_download_link);

  int rowIndex = 2;

  // معالجة البيانات من مجموعة account
  for (var account in allData) {
    String invoiceCode = account['invoiceCode'] ?? '';
    var value = account['value'] ?? 0;
    var dues = account['dues'] ?? 0;
    String createdAt = account['createdAt'] ?? '';
    DateTime dateTime = DateTime.parse(createdAt);
    String formattedDate = DateFormat('dd/MM/yyyy', 'en_US').format(dateTime);

    final Uri downloadUrlPdf = Uri.parse(account['downloadUrlPdf']);

    if (value > 0) {
      // إدخال
      sheet.getRangeByName('A$rowIndex').setValue(formattedDate);
      sheet.getRangeByName('B$rowIndex').setValue(S().input);
      sheet.getRangeByName('B$rowIndex').cellStyle.fontColor = '#0000FF';
      sheet.getRangeByName('B$rowIndex').cellStyle.bold = true;
      sheet.getRangeByName('C$rowIndex').setNumber(value);
      sheet.getRangeByName('C$rowIndex').cellStyle.bold = true;
      sheet.getRangeByName('D$rowIndex').setNumber(dues);
      sheet.getRangeByName('D$rowIndex').cellStyle.bold = true;
      sheet.getRangeByName('E$rowIndex').setValue(invoiceCode);
      sheet.getRangeByName('E$rowIndex').cellStyle.fontColor = '#FFFFFF';
      rowIndex++;
    } else if (value < 0) {
      // إخراج
      sheet.getRangeByName('A$rowIndex').setValue(formattedDate);
      if (invoiceCode == 'No invoice') {
        sheet.getRangeByName('A$rowIndex').setValue(formattedDate);
        sheet.getRangeByName('B$rowIndex').setValue(S().output);
        sheet.getRangeByName('B$rowIndex').cellStyle.fontColor = '#FF0000';
        sheet.getRangeByName('B$rowIndex').cellStyle.bold = true;
        sheet.getRangeByName('C$rowIndex').setNumber(value);
        sheet.getRangeByName('C$rowIndex').cellStyle.bold = true;
        sheet.getRangeByName('D$rowIndex').setNumber(dues);
        sheet.getRangeByName('D$rowIndex').cellStyle.bold = true;
        sheet.getRangeByName('E$rowIndex').setValue(invoiceCode);
        sheet.getRangeByName('E$rowIndex').cellStyle.fontColor = '#FFFFFF';

        rowIndex++;
      } else if (invoiceCode.isNotEmpty) {
        // استرجاع بيانات الفاتورة
        Map<String, dynamic>? aggregatedData =
            await fetchInvoiceData(client.codeIdClien, invoiceCode);

        if (aggregatedData != null) {
          // التعامل مع البيانات المتغيرة داخل aggregatedData
          var grandTotalPrice = aggregatedData['grandTotalPrice'];
          var taxs = aggregatedData['taxs'];
          var grandTotalPriceTaxs = aggregatedData['grandTotalPriceTaxs'];
          var previousDebts = aggregatedData['previousDebts'];
          var shippingCompanyName = aggregatedData['shippingCompanyName'];
          var shippingFees = aggregatedData['shippingFees'];
          var shippingTrackingNumber = aggregatedData['shippingTrackingNumber'];
          var packingBagsNumber = aggregatedData['packingBagsNumber'];
          var finalTotal = aggregatedData['finalTotal'];
          var totalLength = aggregatedData['totalLength'];
          var totalQuantity = aggregatedData['totalQuantity'];
          var totalWeight = aggregatedData['totalWeight'];
          sheet.getRangeByName('E$rowIndex').setValue(invoiceCode);
          sheet.getRangeByName('E$rowIndex').cellStyle.fontColor = '#FF0000';
          sheet.getRangeByName('E$rowIndex').cellStyle.bold = true;
          sheet.getRangeByName('O$rowIndex').setNumber(grandTotalPrice);
          sheet.getRangeByName('O$rowIndex').cellStyle.bold = true;
          sheet.getRangeByName('P$rowIndex').setNumber(taxs);
          sheet.getRangeByName('Q$rowIndex').setNumber(grandTotalPriceTaxs);
          sheet.getRangeByName('R$rowIndex').setNumber(previousDebts);
          sheet.getRangeByName('R$rowIndex').cellStyle.bold = true;
          sheet.getRangeByName('S$rowIndex').setValue(shippingCompanyName);
          sheet.getRangeByName('S$rowIndex').cellStyle.fontColor = '#FF0000';
          sheet.getRangeByName('S$rowIndex').cellStyle.bold = true;
          sheet.getRangeByName('T$rowIndex').setNumber(shippingFees);
          sheet.getRangeByName('U$rowIndex').setValue(shippingTrackingNumber);
          sheet.getRangeByName('V$rowIndex').setValue(packingBagsNumber);
          sheet.getRangeByName('W$rowIndex').setNumber(finalTotal);
          sheet.getRangeByName('X$rowIndex').setNumber(totalLength);
          sheet.getRangeByName('Y$rowIndex').setNumber(totalQuantity);
          sheet.getRangeByName('Z$rowIndex').setNumber(totalWeight);
          sheet
              .getRangeByName('AA$rowIndex')
              .setValue(downloadUrlPdf.toString());
          if (aggregatedData.containsKey('aggregatedData')) {
            Map<String, dynamic> aggregatedDatasa =
                aggregatedData['aggregatedData'];
            aggregatedDatasa.forEach((key, invoiceData) {
              if (invoiceData is Map<String, dynamic>) {
                sheet.getRangeByName('A$rowIndex').setValue(formattedDate);
                sheet.getRangeByName('B$rowIndex').setValue(S().output);
                sheet.getRangeByName('B$rowIndex').cellStyle.fontColor =
                    '#FF0000';
                sheet.getRangeByName('B$rowIndex').cellStyle.bold = true;
                sheet.getRangeByName('C$rowIndex').setNumber(value);
                sheet.getRangeByName('C$rowIndex').cellStyle.bold = true;
                sheet.getRangeByName('D$rowIndex').setNumber(dues);
                sheet.getRangeByName('D$rowIndex').cellStyle.bold = true;
                // كتابة ترجمة الكلمة حسب لغة المستخدم
                sheet.getRangeByName('F$rowIndex').setValue(
                    DataLists().translateType(invoiceData['type'].toString()));
                sheet.getRangeByName('G$rowIndex').setValue(
                    DataLists().translateType(invoiceData['color'].toString()));
                sheet
                    .getRangeByName('H$rowIndex')
                    .setNumber(invoiceData['length']);
                sheet.getRangeByName('I$rowIndex').setNumber(
                    double.tryParse(invoiceData['yarn_number'].toString()) ??
                        0);
                sheet.getRangeByName('J$rowIndex').setNumber(
                    double.tryParse(invoiceData['width'].toString()) ?? 0);
                sheet
                    .getRangeByName('K$rowIndex')
                    .setNumber(invoiceData['total_weight']);

                sheet
                    .getRangeByName('L$rowIndex')
                    .setNumber(invoiceData['price']);

                sheet
                    .getRangeByName('M$rowIndex')
                    .setNumber(invoiceData['quantity']);
                sheet.getRangeByName('M$rowIndex').cellStyle.bold = true;

                sheet
                    .getRangeByName('N$rowIndex')
                    .setNumber(invoiceData['totalLinePrices']);

                rowIndex++;
              }
            });
          }
        }
      }
    }
  }

  // حفظ الملف
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  final fileName = 'client_page_$formattedDateXlsx.xlsx';

  await saveAndLaunchFile(bytes, fileName);
  showToast('${S().excel_file_saved} $fileName');
}

// دالة استرجاع بيانات aggregatedData
Future<Map<String, dynamic>?> fetchInvoiceData(
    String clientCode, String invoiceCode) async {
  final String path = '/cliens/$clientCode/invoices/$invoiceCode';
  final DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.doc(path).get();
  if (docSnapshot.exists) {
    Map<String, dynamic> invoiceData =
        docSnapshot.data() as Map<String, dynamic>;

    return invoiceData;
  } else {
    throw Exception("الوثيقة غير موجودة");
  }
}
