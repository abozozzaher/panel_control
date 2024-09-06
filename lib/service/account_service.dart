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

  String formattedCreatedAt =
      DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(DateTime.now());
  String docId = DateFormat('yyyyMMddHHmmsss').format(DateTime.now());
  // التاريخ سعر الصرف هل القيمة ايجابية او سلبية
  Future<void> saveValueToFirebase(
      String traderId, double value, String invoiceCode) async {
    double? exchangeRateTR = await fetchExchangeRateTR();

    FirebaseFirestore.instance
        .collection('cliens')
        .doc(traderId)
        .collection('account')
        .doc(docId)
        .set({
      'value': value,
      'createdAt': formattedCreatedAt,
      'docId': docId,
      'exchangeRate': '$exchangeRateTR TRY',
      'invoiceCode': invoiceCode,
    });
  }
}
