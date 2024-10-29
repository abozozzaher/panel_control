import 'package:cloud_firestore/cloud_firestore.dart';
import 'toasts.dart';

import '../generated/l10n.dart';
import '../model/clien.dart';

DateTime now = DateTime.now();
////0000
Future<void> saveDataProInv(
  List<Map<String, dynamic>> tableDataList,
  double finalTotal,
  ClienData? trader,
  double totalPrices,
  double taxWthiPrice,
  String tax,
  double dues,
  double shippingFees,
  String invoiceCode,
  String downloadUrlPdf,
  String shippingCompanyName,
  String shippingTrackingNumber,
  String packingBagsNumber,
  double totalWeightSum,
  double totalUnitSum,
) async {
  // استخراج البيانات من tableDataList
  final tableData = tableDataList.map((productData) {
    return [
      productData['type'].toString(),
      productData['color'].toString(),
      productData['yarn_number'].toString(),
      productData['totalLength'].toStringAsFixed(0),
      productData['totalWeight'].toStringAsFixed(2),
      productData['totalUnit'].toStringAsFixed(0),
      productData['allQuantity'].toString(),
      productData['price'].toStringAsFixed(2),
      productData['totalPrice'].toStringAsFixed(2),
    ];
  }).toList();

  // تحديد مرجع للمجموعة حيث تريد حفظ البيانات
  DocumentReference<Map<String, dynamic>> invoices =
      FirebaseFirestore.instance.collection('pro-invoices').doc(invoiceCode);

  // بناء مستند جديد بالبيانات المطلوبة
  try {
    await invoices.set({
      'invoiceCode': invoiceCode,
      'codeIdClien': trader!.codeIdClien,
      'fullNameArabic': trader.fullNameArabic,
      'fullNameEnglish': trader.fullNameEnglish,
      'country': trader.country,
      'finalTotal': finalTotal.toStringAsFixed(2),
      'totalPrices': totalPrices.toStringAsFixed(2),
      'taxWthiPrice': taxWthiPrice.toStringAsFixed(2),
      'tax': tax,
      'dues': dues.toStringAsFixed(2),
      'shippingFees': shippingFees.toStringAsFixed(2),
      'downloadUrlPdf': downloadUrlPdf,
      'shippingCompanyName': shippingCompanyName,
      'shippingTrackingNumber': shippingTrackingNumber,
      'packingBagsNumber': packingBagsNumber,
      'totalWeightSum': totalWeightSum.toStringAsFixed(0),
      'totalUnitSum': totalUnitSum.toStringAsFixed(0),
      'products': tableData
          .map((product) => {
                'type': product[0],
                'color': product[1],
                'yarn_number': product[2],
                'totalLength': product[3],
                'totalWeight': product[4],
                'totalUnit': product[5],
                'allQuantity': product[6],
                'price': product[7],
                'totalPrice': product[8],
              })
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
      // 'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
    });
    showToast(S().data_pro_invoice_saved_successfully);
  } catch (e) {
    showToast('${S().failed_to_save_data} $e');
    print("Failed to save data: $e");
  }
}
