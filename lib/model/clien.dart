import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory ClienData.fromMap(Map<String, dynamic> data) {
    return ClienData(
      fullNameArabic: data['fullNameArabic'],
      fullNameEnglish: data['fullNameEnglish'],
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      createdAt:
          DateFormat('yyyy-MM-dd HH:mm:ss', 'en').parse(data['createdAt']),
      codeIdClien: data['codeIdClien'],
    );
  }
}
