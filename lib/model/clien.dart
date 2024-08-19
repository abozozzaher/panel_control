import 'package:intl/intl.dart';

class ClienData {
  String fullNameArabic;
  String fullNameEnglish;
  String address;
  String phoneNumber;
  DateTime createdAt;
  String codeIdClien;

  ClienData({
    required this.fullNameArabic,
    required this.fullNameEnglish,
    required this.address,
    required this.phoneNumber,
    required this.createdAt,
    required this.codeIdClien,
  });

  // تحويل البيانات إلى شكل يمكن رفعه إلى Firebase
  Map<String, dynamic> toMap() {
    String formattedCreatedAt =
        DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(createdAt);

    return {
      'fullNameArabic': fullNameArabic,
      'fullNameEnglish': fullNameEnglish,
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': formattedCreatedAt,
      'codeIdClien': codeIdClien,
    };
  }
}
