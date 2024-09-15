import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'exchangeRate_service.dart';

class AccountService {
  String generateCode() {
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmss');
    String date = formatter.format(now);
    return date; // Dynamic serial number should be updated
  }

  // String docId = DateFormat('yyyyMMddHHmmsss').format(DateTime.now());
  String formattedCreatedAt =
      DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(DateTime.now());
  // التاريخ سعر الصرف هل القيمة ايجابية او سلبية
  ///55555 تخفيف عدد مرات القراءة
  Future<void> saveValueToFirebase(String traderId, double value,
      String invoiceCode, String downloadUrlPdf) async {
    double? exchangeRateTR = await fetchExchangeRateTR();

    final traderAccountCollection = FirebaseFirestore.instance
        .collection('cliens')
        .doc(traderId)
        .collection('account');

    // البحث عن المستند الأخير بناءً على حقل dues
    final lastDuesSnapshot = await traderAccountCollection
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    double currentDues = 0;

    if (lastDuesSnapshot.docs.isNotEmpty) {
      final lastDuesDoc = lastDuesSnapshot.docs.first;

      currentDues = lastDuesDoc.data()['dues'] ?? 0;
    }

    // حساب المجموع الجديد
    double newDues = currentDues + value;

    // إعداد المستند الجديد
    String docId = traderAccountCollection.doc().id;

    await traderAccountCollection.doc(docId).set({
      'value': value,
      'createdAt': formattedCreatedAt,
      'docId': docId,
      'exchangeRate': '$exchangeRateTR TRY',
      'invoiceCode': invoiceCode,
      'downloadUrlPdf': downloadUrlPdf,
      'dues': newDues, // تخزين المجموع الجديد
    });
  }
}
