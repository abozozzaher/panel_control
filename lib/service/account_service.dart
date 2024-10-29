import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../generated/l10n.dart';
import 'exchangeRate_service.dart';
import 'toasts.dart';

class AccountService {
  bool _isSaving = false; // حالة لمعرفة إذا كانت العملية جارية

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
  Future<void> saveValueToFirebase(String traderId, double value,
      String invoiceCode, String downloadUrlPdf) async {
    // تحقق مما إذا كانت العملية جارية بالفعل
    if (_isSaving) {
      print('عملية جارية بالفعل.');
      return;
    }
    // تعيين الحالة إلى true لمنع العمليات المتكررة
    _isSaving = true;

    try {
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

        currentDues = (lastDuesDoc.data()['dues'] ?? 0).toDouble();
      }

      // حساب المجموع الجديد
      double newDues = currentDues + value;

      // إعداد المستند الجديد
      String docId = traderAccountCollection.doc().id;
      //   try {
      await traderAccountCollection.doc(docId).set({
        'value': value,
        'createdAt': formattedCreatedAt,
        'docId': docId,
        'exchangeRate': '$exchangeRateTR TRY',
        'invoiceCode': invoiceCode,
        'downloadUrlPdf': downloadUrlPdf,
        'dues': newDues, // تخزين المجموع الجديد
      });
      // التحقق من حالة الشبكة
      bool isOnline = await isNetworkAvailable();
      if (!isOnline) {
        showToast(
            S().data_will_be_recorded_when_internet_connection_is_restored);
      }
    } catch (error) {
      showToast('${S().an_error_occurred_while_adding_data} $error');
    } finally {
      // تعيين الحالة إلى false بعد انتهاء العملية
      _isSaving = false;
    }
  }
}
